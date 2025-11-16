//
//  MessageDigestService.swift
//  VestaWidget
//
//  Combines multiple messages into a single digest display for the Vestaboard
//  Useful for handling burst scenarios where many messages are sent within a short time
//  Formats messages as a compact summary that fits within 6×22 board constraints
//

import Foundation

/// Service for creating message digests from multiple messages
/// Combines burst messages into a single, formatted display
class MessageDigestService {

    // MARK: - Configuration

    /// Maximum number of messages to include in a digest
    private let maxMessagesInDigest: Int

    /// Maximum characters per message line (leaves room for bullet)
    private let maxCharactersPerLine: Int = 20

    /// Burst detection window (messages within this window are grouped)
    private let burstWindow: TimeInterval

    // MARK: - Initialization

    /// Creates a new digest service
    /// - Parameters:
    ///   - maxMessagesInDigest: Maximum messages to include (default: 4)
    ///   - burstWindow: Time window for burst detection in seconds (default: 120 = 2 minutes)
    init(maxMessagesInDigest: Int = 4, burstWindow: TimeInterval = 120) {
        self.maxMessagesInDigest = maxMessagesInDigest
        self.burstWindow = burstWindow
    }

    // MARK: - Public Methods

    /// Detects if messages constitute a burst (multiple messages in short timeframe)
    /// - Parameter messages: Array of messages to analyze
    /// - Returns: true if messages are a burst
    func isBurst(_ messages: [VestaboardMessage]) -> Bool {
        guard messages.count >= 2 else { return false }

        // Check if all messages are within burst window
        let sortedMessages = messages.sorted { ($0.createdAt ?? Date.distantPast) > ($1.createdAt ?? Date.distantPast) }

        guard let newest = sortedMessages.first?.createdAt,
              let oldest = sortedMessages.last?.createdAt else {
            return false
        }

        let timeDifference = newest.timeIntervalSince(oldest)
        return timeDifference <= burstWindow
    }

    /// Creates a digest message from multiple messages
    /// - Parameter messages: Messages to combine
    /// - Returns: VestaboardMessage containing formatted digest, or nil if can't create digest
    func createDigest(from messages: [VestaboardMessage]) -> VestaboardMessage? {
        guard !messages.isEmpty else { return nil }

        // Take most recent messages up to max
        let recentMessages = Array(messages.prefix(maxMessagesInDigest))

        // Format digest text
        let digestText = formatDigest(messages: recentMessages)

        // Create digest message
        var digestMessage = VestaboardMessage(text: digestText, status: .draft)
        digestMessage.metadata = [
            "digest_message_count": "\(recentMessages.count)",
            "digest_created_at": ISO8601DateFormatter().string(from: Date())
        ]

        return digestMessage
    }

    /// Creates a digest if messages constitute a burst, otherwise returns nil
    /// - Parameter messages: Messages to analyze
    /// - Returns: Digest message if burst detected, nil otherwise
    func createDigestIfBurst(from messages: [VestaboardMessage]) -> VestaboardMessage? {
        guard isBurst(messages) else { return nil }
        return createDigest(from: messages)
    }

    // MARK: - Private Methods

    /// Formats messages into a digest string
    /// - Parameter messages: Messages to format
    /// - Returns: Formatted digest text
    private func formatDigest(messages: [VestaboardMessage]) -> String {
        var lines: [String] = []

        // Header
        let headerText = messages.count == 1 ? "1 UPDATE" : "\(messages.count) UPDATES"
        lines.append(headerText.centered(in: AppConstants.vestaboardColumns))
        lines.append("")  // Blank line for spacing

        // Message items (each as a bullet point)
        for (index, message) in messages.enumerated() {
            guard index < 4 else {
                // Max 4 message lines fit on board
                let remaining = messages.count - index
                lines.append("...+\(remaining) MORE")
                break
            }

            let bulletLine = formatMessageLine(message.text)
            lines.append(bulletLine)
        }

        // Pad remaining lines to fill 6 rows
        while lines.count < AppConstants.vestaboardRows {
            lines.append("")
        }

        // Combine lines
        return lines.joined(separator: "\n")
    }

    /// Formats a single message as a bullet point line
    /// - Parameter text: Message text
    /// - Returns: Formatted line with bullet
    private func formatMessageLine(_ text: String) -> String {
        // Clean and uppercase text
        let cleaned = text.uppercased().trimmingCharacters(in: .whitespacesAndNewlines)

        // Truncate to fit (22 chars total - 2 for bullet = 20 chars)
        let truncated: String
        if cleaned.count > maxCharactersPerLine {
            truncated = String(cleaned.prefix(maxCharactersPerLine - 1)) + "…"
        } else {
            truncated = cleaned
        }

        // Add bullet point
        return "• \(truncated)"
    }
}

// MARK: - String Extensions for Formatting

private extension String {

    /// Centers text within specified width
    /// - Parameter width: Total width to center in
    /// - Returns: Centered string
    func centered(in width: Int) -> String {
        let trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count < width else { return trimmed }

        let padding = (width - trimmed.count) / 2
        let leftPadding = String(repeating: " ", count: padding)
        return leftPadding + trimmed
    }
}

// MARK: - Message Digest Detection

extension MessageDigestService {

    /// Analyzes message history and determines if digest should be created
    /// - Parameters:
    ///   - history: Full message history
    ///   - recentWindow: Time window to consider for recent messages (default: 5 minutes)
    /// - Returns: Tuple of (should create digest, messages to digest)
    func analyzeHistory(_ history: [VestaboardMessage], recentWindow: TimeInterval = 300) -> (shouldDigest: Bool, messages: [VestaboardMessage]) {

        // Get messages from recent window
        let cutoffDate = Date().addingTimeInterval(-recentWindow)
        let recentMessages = history.filter { message in
            guard let createdAt = message.createdAt else { return false }
            return createdAt >= cutoffDate
        }

        // Check if recent messages constitute a burst
        let shouldDigest = isBurst(recentMessages)

        return (shouldDigest, recentMessages)
    }
}

// MARK: - Digest Configuration

/// Configuration for digest behavior
struct DigestConfiguration: Codable {

    /// Whether digest mode is enabled
    var isEnabled: Bool = true

    /// Burst detection window in seconds (default: 2 minutes)
    var burstWindowSeconds: TimeInterval = 120

    /// Minimum number of messages to trigger digest (default: 3)
    var minimumMessagesForDigest: Int = 3

    /// Maximum messages to show in digest (default: 4)
    var maxMessagesInDigest: Int = 4

    /// Storage key for UserDefaults
    static let storageKey = "digestConfiguration"

    // MARK: - Persistence

    /// Loads configuration from UserDefaults
    static func load(from storage: AppGroupStorage = .shared) -> DigestConfiguration {
        guard let data = storage.userDefaults.data(forKey: storageKey),
              let config = try? JSONDecoder().decode(DigestConfiguration.self, from: data) else {
            return DigestConfiguration()  // Return default
        }
        return config
    }

    /// Saves configuration to UserDefaults
    func save(to storage: AppGroupStorage = .shared) {
        if let data = try? JSONEncoder().encode(self) {
            storage.userDefaults.set(data, forKey: Self.storageKey)
        }
    }
}

// MARK: - Sample Data

#if DEBUG
extension MessageDigestService {

    /// Sample digest for testing
    static var sampleDigest: VestaboardMessage {
        let messages = [
            VestaboardMessage(text: "Meeting at 2pm", status: .sent),
            VestaboardMessage(text: "Lunch order by 1pm", status: .sent),
            VestaboardMessage(text: "Deploy at 3pm", status: .sent)
        ]

        let service = MessageDigestService()
        return service.createDigest(from: messages)!
    }

    /// Sample burst messages
    static var sampleBurstMessages: [VestaboardMessage] {
        var messages: [VestaboardMessage] = []
        let baseDate = Date()

        for i in 0..<5 {
            var message = VestaboardMessage(text: "Message \(i + 1)", status: .sent)
            message.createdAt = baseDate.addingTimeInterval(TimeInterval(i * 10))  // 10 seconds apart
            messages.append(message)
        }

        return messages
    }
}
#endif
