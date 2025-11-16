//
//  MessageDeliveryStrategy.swift
//  VestaWidget
//
//  Defines delivery strategies for handling message conflicts and queue behavior
//  Provides flexible approaches for different delivery scenarios
//  Supports immediate delivery, queued delivery, and conflict resolution
//

import Foundation

/// Protocol defining a message delivery strategy
/// Different strategies can handle conflicts and queueing differently
protocol MessageDeliveryStrategy {

    /// Whether to check for conflicts before sending
    var shouldCheckConflicts: Bool { get }

    /// Whether to prevent sends when conflicts are detected
    var shouldPreventConflicts: Bool { get }

    /// Whether to queue messages or send immediately
    var shouldQueueMessages: Bool { get }

    /// Name of the strategy
    var name: String { get }

    /// Description of what this strategy does
    var description: String { get }
}

// MARK: - Queued Delivery Strategy

/// Default strategy: Queue all messages and send sequentially
/// Checks for conflicts and uses last-write-wins
/// Best for: General use, reliable delivery, conflict awareness
struct QueuedDeliveryStrategy: MessageDeliveryStrategy {

    var shouldCheckConflicts: Bool { true }
    var shouldPreventConflicts: Bool { false }  // Last-write-wins
    var shouldQueueMessages: Bool { true }

    var name: String { "Queued Delivery" }

    var description: String {
        """
        Messages are queued and sent sequentially with conflict detection.
        If the board content has changed since last check, the message
        is still sent (last-write-wins). Provides reliable delivery with
        retry logic and status tracking.
        """
    }
}

// MARK: - Immediate Delivery Strategy

/// Send messages immediately without queueing
/// No conflict checking, fastest delivery
/// Best for: Single-user scenarios, speed over safety
struct ImmediateDeliveryStrategy: MessageDeliveryStrategy {

    var shouldCheckConflicts: Bool { false }
    var shouldPreventConflicts: Bool { false }
    var shouldQueueMessages: Bool { false }

    var name: String { "Immediate Delivery" }

    var description: String {
        """
        Messages are sent immediately without queueing or conflict detection.
        Fastest delivery but may overwrite concurrent messages. Best for
        single-user scenarios where speed is critical.
        """
    }
}

// MARK: - Conflict-Aware Strategy

/// Queue messages and prevent sends on conflicts
/// Requires user intervention to resolve conflicts
/// Best for: Multi-user scenarios, preventing data loss
struct ConflictAwareStrategy: MessageDeliveryStrategy {

    var shouldCheckConflicts: Bool { true }
    var shouldPreventConflicts: Bool { true }
    var shouldQueueMessages: Bool { true }

    var name: String { "Conflict-Aware Delivery" }

    var description: String {
        """
        Messages are queued and checked for conflicts before sending.
        If board content has changed, the message is held and user is
        notified to resolve the conflict. Prevents accidental overwrites
        in multi-user scenarios.
        """
    }
}

// MARK: - Optimistic Delivery Strategy

/// Queue messages but skip conflict checks for speed
/// Assumes conflicts are rare
/// Best for: Low-traffic boards, performance optimization
struct OptimisticDeliveryStrategy: MessageDeliveryStrategy {

    var shouldCheckConflicts: Bool { false }
    var shouldPreventConflicts: Bool { false }
    var shouldQueueMessages: Bool { true }

    var name: String { "Optimistic Delivery" }

    var description: String {
        """
        Messages are queued and sent without conflict checking.
        Optimizes for speed by assuming conflicts are rare.
        Provides retry logic and status tracking without the
        overhead of conflict detection.
        """
    }
}

// MARK: - Retry-Only Strategy

/// Send immediately but with retry logic
/// No queueing, retries happen inline
/// Best for: Simple scenarios with network unreliability
struct RetryOnlyStrategy: MessageDeliveryStrategy {

    var shouldCheckConflicts: Bool { false }
    var shouldPreventConflicts: Bool { false }
    var shouldQueueMessages: Bool { false }

    var name: String { "Retry-Only Delivery" }

    var description: String {
        """
        Messages are sent immediately with inline retry logic.
        If a send fails, it's retried with exponential backoff
        before giving up. No persistent queue or conflict detection.
        """
    }
}

// MARK: - Strategy Factory

/// Factory for creating delivery strategies
struct DeliveryStrategyFactory {

    /// Available strategy types
    enum StrategyType: String, CaseIterable {
        case queued = "queued"
        case immediate = "immediate"
        case conflictAware = "conflict_aware"
        case optimistic = "optimistic"
        case retryOnly = "retry_only"

        var displayName: String {
            switch self {
            case .queued: return "Queued Delivery"
            case .immediate: return "Immediate Delivery"
            case .conflictAware: return "Conflict-Aware"
            case .optimistic: return "Optimistic"
            case .retryOnly: return "Retry-Only"
            }
        }
    }

    /// Creates a strategy for the given type
    /// - Parameter type: Strategy type to create
    /// - Returns: Concrete strategy instance
    static func strategy(for type: StrategyType) -> MessageDeliveryStrategy {
        switch type {
        case .queued:
            return QueuedDeliveryStrategy()
        case .immediate:
            return ImmediateDeliveryStrategy()
        case .conflictAware:
            return ConflictAwareStrategy()
        case .optimistic:
            return OptimisticDeliveryStrategy()
        case .retryOnly:
            return RetryOnlyStrategy()
        }
    }

    /// Default strategy for most use cases
    static var `default`: MessageDeliveryStrategy {
        return QueuedDeliveryStrategy()
    }

    /// Recommended strategy for single-user scenarios
    static var singleUser: MessageDeliveryStrategy {
        return OptimisticDeliveryStrategy()
    }

    /// Recommended strategy for multi-user scenarios
    static var multiUser: MessageDeliveryStrategy {
        return ConflictAwareStrategy()
    }
}

// MARK: - Conflict Resolution Policy

/// Defines how to handle conflicts when detected
enum ConflictResolutionPolicy {
    /// Always send the new message (last-write-wins)
    case overwrite

    /// Never send if conflict detected (requires manual resolution)
    case preventOverwrite

    /// Ask user how to resolve
    case askUser

    /// Merge messages if possible (future enhancement)
    case merge

    /// Queue for later retry
    case retryLater(TimeInterval)

    var description: String {
        switch self {
        case .overwrite:
            return "Overwrite existing content (last-write-wins)"
        case .preventOverwrite:
            return "Prevent send and notify user"
        case .askUser:
            return "Ask user how to resolve"
        case .merge:
            return "Attempt to merge messages"
        case .retryLater(let delay):
            return "Retry after \(Int(delay)) seconds"
        }
    }
}

// MARK: - Delivery Configuration

/// Configuration for delivery behavior
struct DeliveryConfiguration {

    /// Strategy to use for delivery
    var strategy: MessageDeliveryStrategy

    /// Conflict resolution policy
    var conflictResolution: ConflictResolutionPolicy

    /// Maximum retry attempts
    var maxRetries: Int

    /// Base delay for exponential backoff (seconds)
    var retryBaseDelay: TimeInterval

    /// Maximum queue size
    var maxQueueSize: Int

    /// Maximum age for queued messages (seconds)
    var maxMessageAge: TimeInterval

    /// Whether to process queue in background
    var enableBackgroundProcessing: Bool

    // MARK: - Initialization

    init(
        strategy: MessageDeliveryStrategy = DeliveryStrategyFactory.default,
        conflictResolution: ConflictResolutionPolicy = .overwrite,
        maxRetries: Int = AppConstants.maxRetryAttempts,
        retryBaseDelay: TimeInterval = AppConstants.retryBaseDelay,
        maxQueueSize: Int = AppConstants.maxQueueSize,
        maxMessageAge: TimeInterval = AppConstants.maxMessageAge,
        enableBackgroundProcessing: Bool = true
    ) {
        self.strategy = strategy
        self.conflictResolution = conflictResolution
        self.maxRetries = maxRetries
        self.retryBaseDelay = retryBaseDelay
        self.maxQueueSize = maxQueueSize
        self.maxMessageAge = maxMessageAge
        self.enableBackgroundProcessing = enableBackgroundProcessing
    }

    // MARK: - Presets

    /// Default configuration for most users
    static var `default`: DeliveryConfiguration {
        return DeliveryConfiguration(
            strategy: DeliveryStrategyFactory.default,
            conflictResolution: .overwrite
        )
    }

    /// Conservative configuration for multi-user boards
    static var conservative: DeliveryConfiguration {
        return DeliveryConfiguration(
            strategy: DeliveryStrategyFactory.multiUser,
            conflictResolution: .preventOverwrite,
            maxRetries: 5
        )
    }

    /// Aggressive configuration for single-user, fast delivery
    static var aggressive: DeliveryConfiguration {
        return DeliveryConfiguration(
            strategy: DeliveryStrategyFactory.singleUser,
            conflictResolution: .overwrite,
            maxRetries: 2,
            retryBaseDelay: 1
        )
    }

    /// Balanced configuration
    static var balanced: DeliveryConfiguration {
        return DeliveryConfiguration(
            strategy: QueuedDeliveryStrategy(),
            conflictResolution: .overwrite,
            maxRetries: 3,
            retryBaseDelay: 2
        )
    }
}

// MARK: - Example Usage Documentation

/*
 USAGE EXAMPLES:

 1. Default queued delivery with last-write-wins:
    let manager = MessageDeliveryManager()
    await manager.sendMessage("Hello World")

 2. Immediate delivery without queueing:
    let config = DeliveryConfiguration.aggressive
    let strategy = ImmediateDeliveryStrategy()
    let manager = MessageDeliveryManager(strategy: strategy)
    await manager.sendMessage("Urgent Message")

 3. Conflict-aware delivery for multi-user:
    let strategy = ConflictAwareStrategy()
    let manager = MessageDeliveryManager(strategy: strategy)
    await manager.sendMessage("Shared Board Message")

 4. Custom configuration:
    var config = DeliveryConfiguration.default
    config.maxRetries = 5
    config.conflictResolution = .askUser
    // Apply config to manager...

 */
