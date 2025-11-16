//
//  AppGroupStorage.swift
//  VestaWidget (Shared)
//
//  Service for storing and retrieving shared data between app and widget extension
//  Uses App Group UserDefaults for persistent storage accessible by both targets
//

import Foundation

/// Service for managing shared data storage between app and widgets
/// Uses App Group UserDefaults to share data across app extensions
class AppGroupStorage {

    // MARK: - Singleton

    /// Shared instance for app-wide access
    static let shared = AppGroupStorage()

    // MARK: - Properties

    /// UserDefaults instance configured for App Group
    private let userDefaults: UserDefaults

    // MARK: - Initialization

    /// Private initializer to enforce singleton pattern
    /// Creates UserDefaults with App Group suite name
    private init() {
        guard let defaults = UserDefaults(suiteName: AppConstants.appGroupIdentifier) else {
            fatalError("Failed to create UserDefaults with App Group identifier: \(AppConstants.appGroupIdentifier)")
        }
        self.userDefaults = defaults
    }

    // MARK: - Vestaboard Content

    /// Saves current Vestaboard content to shared storage
    /// - Parameter content: VestaboardContent to save
    /// - Throws: Error if encoding or saving fails
    func saveContent(_ content: VestaboardContent) throws {
        try userDefaults.setCodable(content, forKey: AppConstants.currentContentKey)
        userDefaults.synchronize()  // Force immediate synchronization
    }

    /// Retrieves current Vestaboard content from shared storage
    /// - Returns: Stored VestaboardContent, or nil if none exists
    func retrieveContent() -> VestaboardContent? {
        return userDefaults.codable(VestaboardContent.self, forKey: AppConstants.currentContentKey)
    }

    /// Deletes stored Vestaboard content
    func deleteContent() {
        userDefaults.removeObject(forKey: AppConstants.currentContentKey)
        userDefaults.synchronize()
    }

    // MARK: - Message Templates

    /// Saves message templates to shared storage
    /// - Parameter templates: Array of MessageTemplate objects
    /// - Throws: Error if encoding or saving fails
    func saveTemplates(_ templates: [MessageTemplate]) throws {
        // Limit to maximum number of templates
        let limitedTemplates = Array(templates.prefix(AppConstants.maxTemplates))
        try userDefaults.setCodable(limitedTemplates, forKey: AppConstants.messageTemplatesKey)
        userDefaults.synchronize()
    }

    /// Retrieves message templates from shared storage
    /// - Returns: Array of stored templates (empty if none exist)
    func retrieveTemplates() -> [MessageTemplate] {
        return userDefaults.codable([MessageTemplate].self, forKey: AppConstants.messageTemplatesKey) ?? []
    }

    /// Adds a new template to storage
    /// - Parameter template: Template to add
    /// - Throws: Error if saving fails
    func addTemplate(_ template: MessageTemplate) throws {
        var templates = retrieveTemplates()
        templates.append(template)
        try saveTemplates(templates)
    }

    /// Removes a template from storage
    /// - Parameter id: UUID of template to remove
    /// - Throws: Error if saving fails
    func removeTemplate(withID id: UUID) throws {
        var templates = retrieveTemplates()
        templates.removeAll { $0.id == id }
        try saveTemplates(templates)
    }

    /// Updates an existing template
    /// - Parameter template: Updated template
    /// - Throws: Error if saving fails
    func updateTemplate(_ template: MessageTemplate) throws {
        var templates = retrieveTemplates()
        if let index = templates.firstIndex(where: { $0.id == template.id }) {
            templates[index] = template
            try saveTemplates(templates)
        } else {
            throw StorageError.templateNotFound
        }
    }

    // MARK: - Message History

    /// Saves message history to shared storage
    /// - Parameter messages: Array of VestaboardMessage objects
    /// - Throws: Error if encoding or saving fails
    func saveMessageHistory(_ messages: [VestaboardMessage]) throws {
        // Limit to maximum number of history items
        let limitedHistory = Array(messages.prefix(AppConstants.maxHistoryItems))
        try userDefaults.setCodable(limitedHistory, forKey: AppConstants.messageHistoryKey)
        userDefaults.synchronize()
    }

    /// Retrieves message history from shared storage
    /// - Returns: Array of stored messages (empty if none exist)
    func retrieveMessageHistory() -> [VestaboardMessage] {
        return userDefaults.codable([VestaboardMessage].self, forKey: AppConstants.messageHistoryKey) ?? []
    }

    /// Adds a message to history
    /// - Parameter message: Message to add
    /// - Throws: Error if saving fails
    func addToHistory(_ message: VestaboardMessage) throws {
        var history = retrieveMessageHistory()
        // Add to beginning (most recent first)
        history.insert(message, at: 0)
        try saveMessageHistory(history)
    }

    /// Clears message history
    func clearHistory() {
        userDefaults.removeObject(forKey: AppConstants.messageHistoryKey)
        userDefaults.synchronize()
    }

    // MARK: - Last Sync Timestamp

    /// Saves the last successful sync timestamp
    /// - Parameter date: Timestamp to save
    func saveLastSync(_ date: Date) {
        userDefaults.set(date, forKey: AppConstants.lastSyncKey)
        userDefaults.synchronize()
    }

    /// Retrieves the last successful sync timestamp
    /// - Returns: Last sync date, or nil if never synced
    func retrieveLastSync() -> Date? {
        return userDefaults.object(forKey: AppConstants.lastSyncKey) as? Date
    }

    // MARK: - Generic Storage

    /// Saves any Codable object to shared storage
    /// - Parameters:
    ///   - object: Object to save
    ///   - key: Storage key
    /// - Throws: Error if encoding or saving fails
    func save<T: Codable>(_ object: T, forKey key: String) throws {
        try userDefaults.setCodable(object, forKey: key)
        userDefaults.synchronize()
    }

    /// Retrieves a Codable object from shared storage
    /// - Parameters:
    ///   - type: Type of object to retrieve
    ///   - key: Storage key
    /// - Returns: Stored object, or nil if not found
    func retrieve<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        return userDefaults.codable(type, forKey: key)
    }

    /// Removes an object from shared storage
    /// - Parameter key: Storage key
    func remove(forKey key: String) {
        userDefaults.removeObject(forKey: key)
        userDefaults.synchronize()
    }

    /// Clears all app data from shared storage
    /// Use with caution - this removes all stored data
    func clearAll() {
        if let bundleID = Bundle.main.bundleIdentifier {
            userDefaults.removePersistentDomain(forName: bundleID)
        }
        userDefaults.synchronize()
    }
}

// MARK: - Storage Errors

/// Errors that can occur during storage operations
enum StorageError: LocalizedError {

    /// Template with given ID not found
    case templateNotFound

    /// Message with given ID not found
    case messageNotFound

    /// Storage quota exceeded
    case quotaExceeded

    /// Failed to encode data
    case encodingFailed

    /// Failed to decode data
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .templateNotFound:
            return "Template not found"
        case .messageNotFound:
            return "Message not found"
        case .quotaExceeded:
            return "Storage limit exceeded"
        case .encodingFailed:
            return "Failed to save data"
        case .decodingFailed:
            return "Failed to load data"
        }
    }
}
