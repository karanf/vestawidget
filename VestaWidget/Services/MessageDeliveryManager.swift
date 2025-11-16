//
//  MessageDeliveryManager.swift
//  VestaWidget
//
//  Orchestrates message delivery with conflict detection, retry logic, and status tracking
//  Ensures reliable, immediate message delivery to Vestaboard
//  Handles concurrent sends, network failures, and background processing
//

import Foundation
import WidgetKit
import Combine

/// Manages the entire message delivery lifecycle from queue to confirmation
/// Implements retry logic with exponential backoff and conflict detection
@MainActor
class MessageDeliveryManager: ObservableObject {

    // MARK: - Published Properties

    /// Whether delivery is currently in progress
    @Published private(set) var isDelivering: Bool = false

    /// Current delivery status message
    @Published private(set) var statusMessage: String?

    /// Most recent error
    @Published private(set) var lastError: Error?

    /// Current queue state
    @Published private(set) var queueState: QueueState = .idle

    // MARK: - Properties

    /// Message queue for managing pending messages
    private let messageQueue: MessageQueue

    /// API service for communicating with Vestaboard
    private let api: VestaboardAPI

    /// Keychain for credential storage
    private let keychain: KeychainService

    /// App Group storage for shared data
    private let storage: AppGroupStorage

    /// Network monitor for connectivity status
    private let networkMonitor: NetworkMonitor

    /// Delivery strategy to use
    private var strategy: MessageDeliveryStrategy

    /// Background task for queue processing
    private var processingTask: Task<Void, Never>?

    /// Timer for periodic queue checking
    private var queueCheckTimer: Timer?

    /// Cancellables for Combine subscriptions
    private var cancellables = Set<AnyCancellable>()

    /// Delegate for delivery events
    weak var delegate: MessageDeliveryDelegate?

    // MARK: - Initialization

    /// Creates a new message delivery manager
    /// - Parameters:
    ///   - messageQueue: Queue for managing messages (defaults to new instance)
    ///   - api: API service (defaults to new instance)
    ///   - keychain: Keychain service (defaults to shared)
    ///   - storage: App Group storage (defaults to shared)
    ///   - networkMonitor: Network monitor (defaults to shared)
    ///   - strategy: Delivery strategy (defaults to queuedDelivery)
    init(
        messageQueue: MessageQueue = MessageQueue(),
        api: VestaboardAPI = VestaboardAPI(),
        keychain: KeychainService = .shared,
        storage: AppGroupStorage = .shared,
        networkMonitor: NetworkMonitor = .shared,
        strategy: MessageDeliveryStrategy = QueuedDeliveryStrategy()
    ) {
        self.messageQueue = messageQueue
        self.api = api
        self.keychain = keychain
        self.storage = storage
        self.networkMonitor = networkMonitor
        self.strategy = strategy

        setupQueueObserver()
        setupNetworkObserver()
        startQueueProcessing()
    }

    deinit {
        stopQueueProcessing()
    }

    // MARK: - Public Methods - Message Sending

    /// Queues a message for delivery
    /// - Parameter text: Message text to send
    /// - Returns: Result with queued message ID or error
    @discardableResult
    func sendMessage(_ text: String) async -> Result<UUID, Error> {
        // Create VestaboardMessage
        var message = VestaboardMessage(text: text, status: .draft)

        // Validate message
        guard message.isValid else {
            let error = DeliveryError.invalidMessage("Message contains unsupported characters")
            lastError = error
            return .failure(error)
        }

        // Create queued message
        let queuedMessage = QueuedMessage(message: message)

        // Add to queue
        let result = messageQueue.enqueue(queuedMessage)

        switch result {
        case .success:
            // Trigger immediate processing
            processQueue()
            return .success(queuedMessage.id)

        case .failure(let error):
            lastError = error
            return .failure(error)
        }
    }

    /// Sends a VestaboardMessage directly
    /// - Parameter message: Message to send
    /// - Returns: Result with queued message ID or error
    @discardableResult
    func sendMessage(_ message: VestaboardMessage) async -> Result<UUID, Error> {
        let queuedMessage = QueuedMessage(message: message)
        let result = messageQueue.enqueue(queuedMessage)

        switch result {
        case .success:
            processQueue()
            return .success(queuedMessage.id)

        case .failure(let error):
            lastError = error
            return .failure(error)
        }
    }

    /// Cancels a queued message
    /// - Parameter messageID: ID of message to cancel
    func cancelMessage(_ messageID: UUID) {
        messageQueue.cancel(messageID)
        delegate?.deliveryManager(self, didCancelMessage: messageID)
    }

    /// Retries a failed message
    /// - Parameter messageID: ID of message to retry
    func retryMessage(_ messageID: UUID) {
        messageQueue.retry(messageID)
        processQueue()
    }

    /// Clears all failed messages from queue
    func clearFailedMessages() {
        messageQueue.clearFailed()
    }

    // MARK: - Public Methods - Queue Management

    /// Returns all queued messages
    var queuedMessages: [QueuedMessage] {
        return messageQueue.allMessages
    }

    /// Returns pending messages
    var pendingMessages: [QueuedMessage] {
        return messageQueue.pendingMessages
    }

    /// Returns failed messages
    var failedMessages: [QueuedMessage] {
        return messageQueue.failedMessages
    }

    /// Number of pending messages
    var pendingCount: Int {
        return messageQueue.pendingCount
    }

    /// Number of failed messages
    var failedCount: Int {
        return messageQueue.failedCount
    }

    // MARK: - Private Methods - Queue Processing

    /// Sets up observer for queue changes
    private func setupQueueObserver() {
        messageQueue.onQueueChanged = { [weak self] in
            Task { @MainActor [weak self] in
                self?.updateQueueState()
            }
        }
    }

    /// Sets up observer for network changes
    private func setupNetworkObserver() {
        networkMonitor.$isConnected
            .sink { [weak self] isConnected in
                if isConnected {
                    Task { @MainActor [weak self] in
                        // Network restored - process queue
                        self?.processQueue()
                    }
                }
            }
            .store(in: &cancellables)
    }

    /// Starts periodic queue processing
    private func startQueueProcessing() {
        // Process immediately
        processQueue()

        // Set up periodic check every 10 seconds
        queueCheckTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.processQueue()
            }
        }
    }

    /// Stops queue processing
    private func stopQueueProcessing() {
        queueCheckTimer?.invalidate()
        queueCheckTimer = nil
        processingTask?.cancel()
        processingTask = nil
    }

    /// Processes the message queue
    private func processQueue() {
        // Don't start new processing if already running
        guard !isDelivering else { return }

        // Check for pending messages
        guard messageQueue.hasPendingMessages else {
            updateQueueState()
            return
        }

        // Start processing
        processingTask = Task {
            await processNextMessage()
        }
    }

    /// Processes the next message in the queue
    private func processNextMessage() async {
        // Check network connectivity
        guard networkMonitor.isConnected else {
            statusMessage = "Waiting for network connection..."
            queueState = .waitingForNetwork
            return
        }

        // Get next message
        guard let queuedMessage = messageQueue.dequeue() else {
            isDelivering = false
            updateQueueState()
            return
        }

        isDelivering = true
        statusMessage = "Sending message..."
        queueState = .delivering

        // Notify delegate
        delegate?.deliveryManager(self, willSendMessage: queuedMessage)

        // Execute delivery with strategy
        let result = await deliverMessage(queuedMessage)

        // Handle result
        switch result {
        case .success:
            handleDeliverySuccess(queuedMessage)

        case .failure(let error):
            handleDeliveryFailure(queuedMessage, error: error)
        }

        isDelivering = false

        // Continue processing if more messages exist
        if messageQueue.hasPendingMessages {
            // Small delay to avoid overwhelming the API
            try? await Task.sleep(seconds: 1)
            await processNextMessage()
        } else {
            updateQueueState()
        }
    }

    /// Delivers a single message using the configured strategy
    /// - Parameter queuedMessage: Message to deliver
    /// - Returns: Result of delivery attempt
    private func deliverMessage(_ queuedMessage: QueuedMessage) async -> Result<Void, Error> {
        do {
            // Get credentials
            let config = try keychain.retrieve()

            // Check for conflicts (read-before-write)
            if strategy.shouldCheckConflicts {
                let currentContent = try await api.getCurrentMessage(
                    apiKey: config.apiKey,
                    apiSecret: config.apiSecret
                )

                // Check if content has changed since last known state
                let lastKnownContent = storage.retrieveContent()

                if let lastKnown = lastKnownContent,
                   currentContent != lastKnown,
                   strategy.shouldPreventConflicts {
                    // Conflict detected - handle according to strategy
                    let shouldContinue = await handleConflict(
                        queuedMessage: queuedMessage,
                        currentContent: currentContent,
                        lastKnownContent: lastKnown
                    )

                    guard shouldContinue else {
                        return .failure(DeliveryError.conflictDetected)
                    }
                }
            }

            // Send the message
            try await api.postMessage(
                text: queuedMessage.message.text,
                apiKey: config.apiKey,
                apiSecret: config.apiSecret
            )

            // Fetch updated content for widgets
            let updatedContent = try await api.getCurrentMessage(
                apiKey: config.apiKey,
                apiSecret: config.apiSecret
            )

            // Save to shared storage
            try storage.saveContent(updatedContent)
            storage.saveLastSync(Date())

            // Update widgets immediately
            WidgetCenter.shared.reloadAllTimelines()

            return .success(())

        } catch {
            return .failure(error)
        }
    }

    /// Handles successful message delivery
    /// - Parameter queuedMessage: Message that was delivered
    private func handleDeliverySuccess(_ queuedMessage: QueuedMessage) {
        // Remove from queue
        messageQueue.markAsSent(queuedMessage.id)

        // Save to history with sent status
        var historyMessage = queuedMessage.message
        historyMessage.markAsSent()

        do {
            try storage.addToHistory(historyMessage)
        } catch {
            print("⚠️ Failed to save message to history: \(error)")
        }

        // Update status
        statusMessage = "Message sent successfully!"
        lastError = nil

        // Notify delegate
        delegate?.deliveryManager(self, didSendMessage: queuedMessage)

        // Haptic feedback
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
    }

    /// Handles failed message delivery
    /// - Parameters:
    ///   - queuedMessage: Message that failed
    ///   - error: Error that occurred
    private func handleDeliveryFailure(_ queuedMessage: QueuedMessage, error: Error) {
        // Determine if we should retry
        let shouldRetry = shouldRetryError(error)

        // Update queue with failure
        messageQueue.markAsFailed(
            queuedMessage.id,
            error: error,
            shouldRetry: shouldRetry
        )

        // Update status
        if shouldRetry && queuedMessage.retryCount < AppConstants.maxRetryAttempts {
            statusMessage = "Delivery failed. Retrying..."
        } else {
            statusMessage = "Delivery failed after \(queuedMessage.retryCount) attempts."
        }

        lastError = error

        // Notify delegate
        delegate?.deliveryManager(self, didFailMessage: queuedMessage, error: error)

        // Haptic feedback
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
        #endif
    }

    /// Handles conflict detection
    /// - Parameters:
    ///   - queuedMessage: Message being sent
    ///   - currentContent: Current board content from API
    ///   - lastKnownContent: Last known board content from cache
    /// - Returns: Whether to continue with send
    private func handleConflict(
        queuedMessage: QueuedMessage,
        currentContent: VestaboardContent,
        lastKnownContent: VestaboardContent
    ) async -> Bool {
        // For now, use last-write-wins strategy
        // In future, this could show user dialog for resolution

        print("⚠️ Conflict detected - board content changed since last read")
        print("  Last known: \(lastKnownContent.displayText.prefix(50))")
        print("  Current: \(currentContent.displayText.prefix(50))")

        // Update our cached content to current state
        try? storage.saveContent(currentContent)

        // Notify delegate
        delegate?.deliveryManager(
            self,
            didDetectConflictForMessage: queuedMessage,
            currentContent: currentContent
        )

        // Continue with send (last-write-wins)
        return true
    }

    /// Determines if an error should trigger a retry
    /// - Parameter error: Error to evaluate
    /// - Returns: true if error is retryable
    private func shouldRetryError(_ error: Error) -> Bool {
        // Network errors - retry
        if error is URLError {
            return true
        }

        // API errors - check type
        if let apiError = error as? APIError {
            switch apiError {
            case .rateLimited:
                return true  // Retry after backoff

            case .serverError:
                return true  // Server errors are retryable

            case .unauthorized:
                return false  // Don't retry auth errors

            case .invalidMessage:
                return false  // Don't retry validation errors

            case .networkError:
                return true

            default:
                return false
            }
        }

        // Unknown errors - don't retry
        return false
    }

    /// Updates the queue state
    private func updateQueueState() {
        if isDelivering {
            queueState = .delivering
        } else if messageQueue.hasPendingMessages {
            if networkMonitor.isConnected {
                queueState = .pending
            } else {
                queueState = .waitingForNetwork
            }
        } else if messageQueue.failedCount > 0 {
            queueState = .hasFailed
        } else {
            queueState = .idle
        }
    }
}

// MARK: - Queue State

extension MessageDeliveryManager {
    enum QueueState {
        case idle                   // No messages in queue
        case pending                // Messages waiting to send
        case delivering             // Currently sending
        case waitingForNetwork      // Waiting for connection
        case hasFailed              // Has failed messages

        var description: String {
            switch self {
            case .idle:
                return "No messages queued"
            case .pending:
                return "Messages pending"
            case .delivering:
                return "Sending message..."
            case .waitingForNetwork:
                return "Waiting for network"
            case .hasFailed:
                return "Some messages failed"
            }
        }
    }
}

// MARK: - Delivery Errors

enum DeliveryError: LocalizedError {
    case invalidMessage(String)
    case conflictDetected
    case queueFull
    case notConfigured

    var errorDescription: String? {
        switch self {
        case .invalidMessage(let reason):
            return "Invalid message: \(reason)"
        case .conflictDetected:
            return "Another message was sent to the board. Conflict detected."
        case .queueFull:
            return "Message queue is full. Please try again later."
        case .notConfigured:
            return "Vestaboard is not configured. Please add your credentials."
        }
    }
}

// MARK: - Delivery Delegate

/// Delegate protocol for delivery events
protocol MessageDeliveryDelegate: AnyObject {
    func deliveryManager(_ manager: MessageDeliveryManager, willSendMessage message: QueuedMessage)
    func deliveryManager(_ manager: MessageDeliveryManager, didSendMessage message: QueuedMessage)
    func deliveryManager(_ manager: MessageDeliveryManager, didFailMessage message: QueuedMessage, error: Error)
    func deliveryManager(_ manager: MessageDeliveryManager, didCancelMessage messageID: UUID)
    func deliveryManager(_ manager: MessageDeliveryManager, didDetectConflictForMessage message: QueuedMessage, currentContent: VestaboardContent)
}

// Default implementations (all optional)
extension MessageDeliveryDelegate {
    func deliveryManager(_ manager: MessageDeliveryManager, willSendMessage message: QueuedMessage) {}
    func deliveryManager(_ manager: MessageDeliveryManager, didSendMessage message: QueuedMessage) {}
    func deliveryManager(_ manager: MessageDeliveryManager, didFailMessage message: QueuedMessage, error: Error) {}
    func deliveryManager(_ manager: MessageDeliveryManager, didCancelMessage messageID: UUID) {}
    func deliveryManager(_ manager: MessageDeliveryManager, didDetectConflictForMessage message: QueuedMessage, currentContent: VestaboardContent) {}
}
