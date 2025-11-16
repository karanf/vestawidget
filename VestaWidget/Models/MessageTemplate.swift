//
//  MessageTemplate.swift
//  VestaWidget
//
//  Model for storing reusable message templates
//  Templates allow users to save and quickly reuse common messages
//

import Foundation

/// Represents a saved message template for quick reuse
struct MessageTemplate: Codable, Identifiable {

    // MARK: - Properties

    /// Unique identifier for the template
    let id: UUID

    /// User-defined name for the template (e.g., "Morning Greeting", "Daily Quote")
    var name: String

    /// The message text content
    var text: String

    /// When the template was created
    var createdAt: Date

    /// Number of times this template has been used
    var usageCount: Int

    /// When the template was last used
    var lastUsed: Date?

    // MARK: - Initialization

    /// Creates a new message template
    /// - Parameters:
    ///   - name: Display name for the template
    ///   - text: Message content
    ///   - id: Unique identifier (defaults to new UUID)
    ///   - createdAt: Creation timestamp (defaults to now)
    ///   - usageCount: Initial usage count (defaults to 0)
    ///   - lastUsed: Last usage timestamp (defaults to nil)
    init(
        name: String,
        text: String,
        id: UUID = UUID(),
        createdAt: Date = Date(),
        usageCount: Int = 0,
        lastUsed: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.text = text
        self.createdAt = createdAt
        self.usageCount = usageCount
        self.lastUsed = lastUsed
    }

    // MARK: - Computed Properties

    /// Preview of the message text (first 50 characters)
    var preview: String {
        return text.truncated(to: 50)
    }

    /// Whether the template is valid (has name and text)
    var isValid: Bool {
        return !name.isBlankOrEmpty && !text.isBlankOrEmpty
    }

    /// Character count of the template text
    var characterCount: Int {
        return text.count
    }

    /// Whether the template text is compatible with Vestaboard
    var isVestaboardCompatible: Bool {
        return VestaboardCharacterSet.validateText(text)
    }

    // MARK: - Methods

    /// Increments the usage count and updates last used timestamp
    mutating func recordUsage() {
        self.usageCount += 1
        self.lastUsed = Date()
    }

    /// Updates the template content
    /// - Parameters:
    ///   - name: New name
    ///   - text: New text
    mutating func update(name: String, text: String) {
        self.name = name
        self.text = text
    }

    /// Creates a VestaboardMessage from this template
    /// - Returns: New message instance with template text
    func createMessage() -> VestaboardMessage {
        return VestaboardMessage(text: text)
    }
}

// MARK: - Hashable

extension MessageTemplate: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: MessageTemplate, rhs: MessageTemplate) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Sample Data

extension MessageTemplate {
    /// Sample templates for previews and testing
    static let samples: [MessageTemplate] = [
        MessageTemplate(
            name: "Morning Greeting",
            text: "GOOD MORNING!",
            usageCount: 15,
            lastUsed: Date().addingTimeInterval(-86400)
        ),
        MessageTemplate(
            name: "Daily Reminder",
            text: "REMEMBER TO BREATHE",
            usageCount: 8,
            lastUsed: Date().addingTimeInterval(-172800)
        ),
        MessageTemplate(
            name: "Weekend Message",
            text: "HAPPY WEEKEND!",
            usageCount: 4,
            lastUsed: Date().addingTimeInterval(-604800)
        ),
        MessageTemplate(
            name: "Meeting Alert",
            text: "TEAM MEETING @ 2PM",
            usageCount: 12
        )
    ]

    /// Single sample template
    static let sample = samples[0]
}
