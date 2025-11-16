//
//  MessageCarouselEntry.swift
//  VestaWidget
//
//  Model for widget carousel state - enables rotating through recent messages in widget
//  Each timeline entry represents a different message in the carousel
//

import Foundation

/// Represents a single entry in the widget message carousel
/// Used by WidgetTimelineProvider to create rotating message displays
struct MessageCarouselEntry: Codable {

    /// Index of current message in the carousel (0-based)
    let currentIndex: Int

    /// Total number of messages in the carousel
    let totalMessages: Int

    /// The message to display at this carousel position
    let message: VestaboardMessage

    /// All messages in the carousel (for context/navigation)
    let allMessages: [VestaboardMessage]

    /// Timestamp when this entry was created
    let timestamp: Date

    // MARK: - Computed Properties

    /// Display text for carousel indicator (e.g., "Message 3 of 10")
    var carouselIndicator: String {
        guard totalMessages > 1 else {
            // Single message - no indicator needed
            return ""
        }

        let position = currentIndex + 1  // Convert to 1-based for display
        return "Message \(position) of \(totalMessages)"
    }

    /// Whether this is the first message in the carousel
    var isFirst: Bool {
        return currentIndex == 0
    }

    /// Whether this is the last message in the carousel
    var isLast: Bool {
        return currentIndex == totalMessages - 1
    }

    /// Whether there are multiple messages (carousel is active)
    var hasMultipleMessages: Bool {
        return totalMessages > 1
    }

    /// Display text for carousel position (shortened - e.g., "3/10")
    var shortCarouselIndicator: String {
        guard totalMessages > 1 else {
            return ""
        }

        let position = currentIndex + 1
        return "\(position)/\(totalMessages)"
    }

    // MARK: - Initialization

    /// Creates a new carousel entry
    /// - Parameters:
    ///   - currentIndex: Index of the message to display (0-based)
    ///   - allMessages: All messages in the carousel
    ///   - timestamp: When this entry was created (defaults to now)
    init(currentIndex: Int, allMessages: [VestaboardMessage], timestamp: Date = Date()) {
        self.currentIndex = currentIndex
        self.totalMessages = allMessages.count
        self.allMessages = allMessages
        self.timestamp = timestamp

        // Ensure currentIndex is valid
        let safeIndex = max(0, min(currentIndex, allMessages.count - 1))
        self.message = allMessages[safeIndex]
    }

    // MARK: - Navigation

    /// Returns entry for next message in carousel
    /// Wraps around to first message if at end
    func next() -> MessageCarouselEntry {
        let nextIndex = (currentIndex + 1) % totalMessages
        return MessageCarouselEntry(
            currentIndex: nextIndex,
            allMessages: allMessages,
            timestamp: Date()
        )
    }

    /// Returns entry for previous message in carousel
    /// Wraps around to last message if at beginning
    func previous() -> MessageCarouselEntry {
        let prevIndex = (currentIndex - 1 + totalMessages) % totalMessages
        return MessageCarouselEntry(
            currentIndex: prevIndex,
            allMessages: allMessages,
            timestamp: Date()
        )
    }

    /// Returns entry for specific index
    /// Clamps index to valid range
    func goTo(index: Int) -> MessageCarouselEntry {
        let safeIndex = max(0, min(index, totalMessages - 1))
        return MessageCarouselEntry(
            currentIndex: safeIndex,
            allMessages: allMessages,
            timestamp: Date()
        )
    }
}

// MARK: - Factory Methods

extension MessageCarouselEntry {

    /// Creates a carousel from message history
    /// - Parameters:
    ///   - history: Array of historical messages
    ///   - maxMessages: Maximum number of messages to include (defaults to 10)
    ///   - startIndex: Starting index for carousel (defaults to most recent)
    /// - Returns: Carousel entry or nil if history is empty
    static func from(
        history: [VestaboardMessage],
        maxMessages: Int = 10,
        startIndex: Int? = nil
    ) -> MessageCarouselEntry? {

        guard !history.isEmpty else {
            return nil
        }

        // Take most recent messages up to maxMessages
        let recentMessages = Array(history.prefix(maxMessages))

        // Determine starting index
        let index = startIndex ?? 0  // Default to most recent (first in array)

        return MessageCarouselEntry(
            currentIndex: index,
            allMessages: recentMessages,
            timestamp: Date()
        )
    }

    /// Creates a single-message carousel (no rotation)
    /// - Parameter message: The single message to display
    /// - Returns: Carousel entry with one message
    static func single(_ message: VestaboardMessage) -> MessageCarouselEntry {
        return MessageCarouselEntry(
            currentIndex: 0,
            allMessages: [message],
            timestamp: Date()
        )
    }

    /// Creates a carousel showing latest message from history
    /// - Parameter history: Message history
    /// - Returns: Carousel entry showing most recent message
    static func latest(from history: [VestaboardMessage]) -> MessageCarouselEntry? {
        guard let latestMessage = history.first else {
            return nil
        }

        return from(history: history, startIndex: 0)
    }
}

// MARK: - Sample Data

#if DEBUG
extension MessageCarouselEntry {

    /// Sample carousel entry for previews
    static var sample: MessageCarouselEntry {
        let messages = [
            VestaboardMessage(text: "Meeting at 2pm", status: .sent),
            VestaboardMessage(text: "Lunch order by 1pm", status: .sent),
            VestaboardMessage(text: "Deploy at 3pm", status: .sent)
        ]

        return MessageCarouselEntry(
            currentIndex: 0,
            allMessages: messages,
            timestamp: Date()
        )
    }

    /// Sample single-message entry
    static var sampleSingle: MessageCarouselEntry {
        let message = VestaboardMessage(text: "Hello World!", status: .sent)
        return MessageCarouselEntry.single(message)
    }

    /// Sample with many messages
    static var sampleMany: MessageCarouselEntry {
        let messages = (1...10).map { index in
            VestaboardMessage(text: "Message number \(index)", status: .sent)
        }

        return MessageCarouselEntry(
            currentIndex: 2,  // Show 3rd message
            allMessages: messages,
            timestamp: Date()
        )
    }
}
#endif
