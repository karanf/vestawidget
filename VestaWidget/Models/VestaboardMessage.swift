//
//  VestaboardMessage.swift
//  VestaWidget
//
//  Model representing a message to be posted to Vestaboard
//  Supports both text-based and character array-based messages
//

import Foundation

/// Represents a message to be posted to or retrieved from Vestaboard
struct VestaboardMessage: Codable, Identifiable {

    // MARK: - Properties

    /// Unique identifier for the message
    let id: UUID

    /// Text content of the message (human-readable)
    var text: String

    /// 2D array of character codes (6x22) representing the message on the board
    /// If nil, the text will be converted to character array when posting
    var characterArray: [[Int]]?

    /// Timestamp when the message was created or sent
    var timestamp: Date

    /// Current status of the message (draft, sending, sent, failed)
    var status: MessageStatus

    /// Optional error message if posting failed
    var errorMessage: String?

    // MARK: - Nested Types

    /// Represents the current state of a message
    enum MessageStatus: String, Codable {
        case draft      // Message created but not yet sent
        case sending    // Message is currently being posted
        case sent       // Message was successfully posted
        case failed     // Message failed to post
    }

    // MARK: - Initialization

    /// Creates a new message with text content
    /// - Parameters:
    ///   - text: The text content of the message
    ///   - id: Unique identifier (defaults to new UUID)
    ///   - timestamp: Creation timestamp (defaults to now)
    ///   - status: Initial status (defaults to draft)
    init(
        text: String,
        id: UUID = UUID(),
        timestamp: Date = Date(),
        status: MessageStatus = .draft
    ) {
        self.id = id
        self.text = text
        self.timestamp = timestamp
        self.status = status
        self.characterArray = nil
        self.errorMessage = nil
    }

    /// Creates a new message with character array
    /// - Parameters:
    ///   - characterArray: 6x22 array of Vestaboard character codes
    ///   - id: Unique identifier (defaults to new UUID)
    ///   - timestamp: Creation timestamp (defaults to now)
    init(
        characterArray: [[Int]],
        id: UUID = UUID(),
        timestamp: Date = Date()
    ) {
        self.id = id
        self.characterArray = characterArray
        self.text = VestaboardCharacterSet.text(from: characterArray)
        self.timestamp = timestamp
        self.status = .draft
        self.errorMessage = nil
    }

    // MARK: - Computed Properties

    /// Returns the character array, generating it from text if needed
    var resolvedCharacterArray: [[Int]] {
        if let array = characterArray {
            return array
        }
        return VestaboardCharacterSet.boardLayout(for: text)
    }

    /// Checks if the message text contains only supported characters
    var isValid: Bool {
        return VestaboardCharacterSet.validateText(text)
    }

    /// Returns array of unsupported characters in the message
    var unsupportedCharacters: [Character] {
        return VestaboardCharacterSet.unsupportedCharacters(in: text)
    }

    /// Returns sanitized version of the message text
    var sanitizedText: String {
        return VestaboardCharacterSet.sanitize(text)
    }

    /// Character count of the message
    var characterCount: Int {
        return text.count
    }

    /// Whether the message exceeds maximum length
    var exceedsMaxLength: Bool {
        return text.count > AppConstants.maxMessageLength
    }

    // MARK: - Methods

    /// Updates the message status
    /// - Parameter newStatus: The new status to set
    /// - Returns: Updated message instance
    mutating func updateStatus(_ newStatus: MessageStatus) {
        self.status = newStatus
        if newStatus == .sent || newStatus == .sending {
            self.errorMessage = nil
        }
    }

    /// Marks the message as failed with an error
    /// - Parameter error: The error that occurred
    mutating func markAsFailed(with error: Error) {
        self.status = .failed
        self.errorMessage = error.localizedDescription
    }

    /// Marks the message as successfully sent
    mutating func markAsSent() {
        self.status = .sent
        self.timestamp = Date()
        self.errorMessage = nil
    }

    /// Creates a copy of the message for resending
    /// - Returns: New message instance with draft status
    func createResendCopy() -> VestaboardMessage {
        var copy = self
        copy.id = UUID()
        copy.status = .draft
        copy.errorMessage = nil
        return copy
    }
}

// MARK: - Hashable

extension VestaboardMessage: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: VestaboardMessage, rhs: VestaboardMessage) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Sample Data

extension VestaboardMessage {
    /// Sample message for previews and testing
    static let sample = VestaboardMessage(
        text: "HELLO WORLD",
        timestamp: Date()
    )

    /// Sample sent message
    static let sampleSent = VestaboardMessage(
        text: "MEETING AT 2PM",
        timestamp: Date().addingTimeInterval(-3600),
        status: .sent
    )

    /// Sample failed message
    static var sampleFailed: VestaboardMessage {
        var message = VestaboardMessage(
            text: "FAILED MESSAGE",
            timestamp: Date().addingTimeInterval(-7200),
            status: .failed
        )
        message.errorMessage = "Network connection lost"
        return message
    }
}
