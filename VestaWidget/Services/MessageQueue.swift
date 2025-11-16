//
//  MessageQueue.swift
//  VestaWidget
//
//  Thread-safe, persistent FIFO message queue for reliable message delivery
//  Handles queueing messages with automatic persistence to App Group storage
//  Supports concurrent access from multiple app instances and widgets
//

import Foundation

/// A thread-safe, persistent FIFO queue for managing pending Vestaboard messages
/// Automatically persists queue state to shared storage for cross-process access
/// Implements serial queue pattern to ensure thread safety
class MessageQueue {

    // MARK: - Properties

    /// Serial dispatch queue for thread-safe operations
    private let queue = DispatchQueue(label: "com.vestawidget.messagequeue", qos: .userInitiated)

    /// Storage service for persistence
    private let storage: AppGroupStorage

    /// In-memory array of queued messages
    private var messages: [QueuedMessage] = []

    /// Maximum number of messages that can be queued
    private let maxQueueSize: Int

    /// Maximum age for messages before they're considered stale
    private let maxMessageAge: TimeInterval

    /// Callback triggered when queue state changes
    var onQueueChanged: (() -> Void)?

    // MARK: - Initialization

    /// Creates a new message queue
    /// - Parameters:
    ///   - storage: Storage service for persistence (defaults to shared instance)
    ///   - maxQueueSize: Maximum queue capacity (defaults to 50)
    ///   - maxMessageAge: Maximum message age in seconds (defaults to 24 hours)
    init(
        storage: AppGroupStorage = .shared,
        maxQueueSize: Int = AppConstants.maxQueueSize,
        maxMessageAge: TimeInterval = AppConstants.maxMessageAge
    ) {
        self.storage = storage
        self.maxQueueSize = maxQueueSize
        self.maxMessageAge = maxMessageAge

        // Load persisted queue on initialization
        loadQueue()

        // Clean up stale messages
        cleanupStaleMessages()
    }

    // MARK: - Public Methods - Queue Operations

    /// Adds a message to the end of the queue
    /// - Parameter message: Message to enqueue
    /// - Returns: Success status and optional error
    @discardableResult
    func enqueue(_ message: QueuedMessage) -> Result<Void, QueueError> {
        return queue.sync {
            // Check queue capacity
            guard messages.count < maxQueueSize else {
                return .failure(.queueFull)
            }

            // Check for duplicates based on message content
            if messages.contains(where: { $0.message.text == message.message.text && $0.status == .pending }) {
                return .failure(.duplicateMessage)
            }

            // Add to queue
            messages.append(message)

            // Persist immediately
            persist()

            // Notify observers
            notifyQueueChanged()

            return .success(())
        }
    }

    /// Removes and returns the first pending message from the queue
    /// - Returns: The next message to process, or nil if queue is empty
    func dequeue() -> QueuedMessage? {
        return queue.sync {
            // Find first pending message
            guard let index = messages.firstIndex(where: { $0.status == .pending }) else {
                return nil
            }

            // Update status to sending
            var message = messages[index]
            message.status = .sending
            message.lastAttemptDate = Date()
            messages[index] = message

            // Persist state
            persist()

            // Notify observers
            notifyQueueChanged()

            return message
        }
    }

    /// Returns the next pending message without removing it
    /// - Returns: The next message to process, or nil if queue is empty
    func peek() -> QueuedMessage? {
        return queue.sync {
            return messages.first(where: { $0.status == .pending })
        }
    }

    /// Marks a message as successfully sent and removes it from queue
    /// - Parameter messageID: ID of the message that was sent
    func markAsSent(_ messageID: UUID) {
        queue.sync {
            if let index = messages.firstIndex(where: { $0.id == messageID }) {
                messages.remove(at: index)
                persist()
                notifyQueueChanged()
            }
        }
    }

    /// Marks a message as failed and updates retry count
    /// - Parameters:
    ///   - messageID: ID of the message that failed
    ///   - error: The error that occurred
    ///   - shouldRetry: Whether the message should be retried
    func markAsFailed(_ messageID: UUID, error: Error, shouldRetry: Bool) {
        queue.sync {
            guard let index = messages.firstIndex(where: { $0.id == messageID }) else {
                return
            }

            var message = messages[index]
            message.retryCount += 1
            message.lastError = error.localizedDescription
            message.lastAttemptDate = Date()

            // Determine if we should retry based on retry count and error type
            let shouldAttemptRetry = shouldRetry && message.retryCount < AppConstants.maxRetryAttempts

            if shouldAttemptRetry {
                // Calculate exponential backoff delay
                let backoffDelay = AppConstants.retryBaseDelay * pow(2.0, Double(message.retryCount - 1))
                message.nextRetryDate = Date().addingTimeInterval(backoffDelay)
                message.status = .pending  // Back to pending for retry
            } else {
                // Max retries exceeded or non-retryable error
                message.status = .failed
            }

            messages[index] = message
            persist()
            notifyQueueChanged()
        }
    }

    /// Cancels a queued message
    /// - Parameter messageID: ID of the message to cancel
    func cancel(_ messageID: UUID) {
        queue.sync {
            messages.removeAll(where: { $0.id == messageID })
            persist()
            notifyQueueChanged()
        }
    }

    /// Retries a failed message
    /// - Parameter messageID: ID of the message to retry
    func retry(_ messageID: UUID) {
        queue.sync {
            guard let index = messages.firstIndex(where: { $0.id == messageID }) else {
                return
            }

            var message = messages[index]
            message.status = .pending
            message.retryCount = 0
            message.lastError = nil
            message.nextRetryDate = nil

            messages[index] = message
            persist()
            notifyQueueChanged()
        }
    }

    /// Clears all messages from the queue
    func clear() {
        queue.sync {
            messages.removeAll()
            persist()
            notifyQueueChanged()
        }
    }

    /// Removes all failed messages from the queue
    func clearFailed() {
        queue.sync {
            messages.removeAll(where: { $0.status == .failed })
            persist()
            notifyQueueChanged()
        }
    }

    // MARK: - Public Methods - Queue State

    /// Returns all messages in the queue (thread-safe copy)
    var allMessages: [QueuedMessage] {
        return queue.sync {
            return messages
        }
    }

    /// Returns only pending messages
    var pendingMessages: [QueuedMessage] {
        return queue.sync {
            return messages.filter { $0.status == .pending && isReadyForRetry($0) }
        }
    }

    /// Returns only failed messages
    var failedMessages: [QueuedMessage] {
        return queue.sync {
            return messages.filter { $0.status == .failed }
        }
    }

    /// Returns only sending messages
    var sendingMessages: [QueuedMessage] {
        return queue.sync {
            return messages.filter { $0.status == .sending }
        }
    }

    /// Number of messages in queue
    var count: Int {
        return queue.sync {
            return messages.count
        }
    }

    /// Number of pending messages
    var pendingCount: Int {
        return pendingMessages.count
    }

    /// Number of failed messages
    var failedCount: Int {
        return failedMessages.count
    }

    /// Whether the queue is empty
    var isEmpty: Bool {
        return count == 0
    }

    /// Whether the queue has pending messages ready to send
    var hasPendingMessages: Bool {
        return !pendingMessages.isEmpty
    }

    // MARK: - Private Methods

    /// Persists the queue to shared storage
    private func persist() {
        do {
            try storage.saveMessageQueue(messages)
        } catch {
            print("❌ Failed to persist message queue: \(error)")
        }
    }

    /// Loads the queue from shared storage
    private func loadQueue() {
        messages = storage.retrieveMessageQueue()

        // Reset any messages stuck in "sending" state (app was killed during send)
        for index in messages.indices {
            if messages[index].status == .sending {
                messages[index].status = .pending
            }
        }

        persist()
    }

    /// Removes stale messages that are too old
    private func cleanupStaleMessages() {
        queue.sync {
            let cutoffDate = Date().addingTimeInterval(-maxMessageAge)
            messages.removeAll { message in
                message.enqueuedDate < cutoffDate && message.status != .sending
            }
            persist()
        }
    }

    /// Checks if a message is ready for retry (past its backoff period)
    /// - Parameter message: Message to check
    /// - Returns: true if ready to retry or no retry date set
    private func isReadyForRetry(_ message: QueuedMessage) -> Bool {
        guard let nextRetryDate = message.nextRetryDate else {
            return true  // No retry date means ready to send
        }
        return Date() >= nextRetryDate
    }

    /// Notifies observers that the queue has changed
    private func notifyQueueChanged() {
        DispatchQueue.main.async { [weak self] in
            self?.onQueueChanged?()
        }
    }
}

// MARK: - QueuedMessage Model

/// Represents a message in the delivery queue with metadata
struct QueuedMessage: Codable, Identifiable {

    /// Unique identifier for this queue entry
    let id: UUID

    /// The Vestaboard message to send
    var message: VestaboardMessage

    /// Current status in the queue
    var status: QueueStatus

    /// Number of times delivery has been attempted
    var retryCount: Int

    /// Date when message was added to queue
    let enqueuedDate: Date

    /// Date of last delivery attempt
    var lastAttemptDate: Date?

    /// Date when next retry should be attempted
    var nextRetryDate: Date?

    /// Error message from last failed attempt
    var lastError: String?

    /// Priority level (for future enhancement)
    var priority: Priority

    /// Optional user-provided metadata
    var metadata: [String: String]?

    // MARK: - Nested Types

    enum QueueStatus: String, Codable {
        case pending    // Waiting to be sent
        case sending    // Currently being sent
        case failed     // Failed after max retries
    }

    enum Priority: Int, Codable, Comparable {
        case low = 0
        case normal = 1
        case high = 2

        static func < (lhs: Priority, rhs: Priority) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }
    }

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        message: VestaboardMessage,
        status: QueueStatus = .pending,
        retryCount: Int = 0,
        enqueuedDate: Date = Date(),
        priority: Priority = .normal,
        metadata: [String: String]? = nil
    ) {
        self.id = id
        self.message = message
        self.status = status
        self.retryCount = retryCount
        self.enqueuedDate = enqueuedDate
        self.priority = priority
        self.metadata = metadata
    }

    // MARK: - Computed Properties

    /// Whether this message can be retried
    var canRetry: Bool {
        return status == .failed && retryCount < AppConstants.maxRetryAttempts
    }

    /// Whether this message is ready to send now
    var isReadyToSend: Bool {
        guard status == .pending else { return false }

        if let nextRetryDate = nextRetryDate {
            return Date() >= nextRetryDate
        }

        return true
    }

    /// Human-readable status description
    var statusDescription: String {
        switch status {
        case .pending:
            if let nextRetryDate = nextRetryDate, Date() < nextRetryDate {
                let seconds = Int(nextRetryDate.timeIntervalSinceNow)
                return "Retrying in \(seconds)s"
            }
            return "Pending"
        case .sending:
            return "Sending..."
        case .failed:
            return "Failed (\(retryCount) attempts)"
        }
    }
}

// MARK: - Queue Errors

enum QueueError: LocalizedError {
    case queueFull
    case duplicateMessage
    case messageNotFound
    case persistenceFailed

    var errorDescription: String? {
        switch self {
        case .queueFull:
            return "Message queue is full. Please try again later or clear old messages."
        case .duplicateMessage:
            return "This message is already queued for delivery."
        case .messageNotFound:
            return "Message not found in queue."
        case .persistenceFailed:
            return "Failed to save queue state."
        }
    }
}
