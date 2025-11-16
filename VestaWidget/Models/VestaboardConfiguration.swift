//
//  VestaboardConfiguration.swift
//  VestaWidget
//
//  Model for storing Vestaboard API credentials and configuration state
//  This model is stored in iOS Keychain for security
//

import Foundation

/// Represents the Vestaboard API configuration and credentials
/// Stored securely in iOS Keychain and shared with widget extension via App Group keychain
struct VestaboardConfiguration: Codable {

    // MARK: - Properties

    /// Read/Write API Key from Vestaboard
    /// Required for authenticating with the Vestaboard API
    var apiKey: String

    /// Read/Write API Secret from Vestaboard
    /// Required for authenticating with the Vestaboard API
    var apiSecret: String

    /// Indicates whether the configuration has been completed and validated
    var isConfigured: Bool

    /// Timestamp of the last successful validation of credentials
    /// Used to determine if credentials should be re-validated
    var lastValidated: Date?

    // MARK: - Initialization

    /// Creates a new Vestaboard configuration
    /// - Parameters:
    ///   - apiKey: The API key from Vestaboard
    ///   - apiSecret: The API secret from Vestaboard
    ///   - isConfigured: Whether configuration is complete (default: false)
    ///   - lastValidated: When credentials were last validated (default: nil)
    init(
        apiKey: String,
        apiSecret: String,
        isConfigured: Bool = false,
        lastValidated: Date? = nil
    ) {
        self.apiKey = apiKey
        self.apiSecret = apiSecret
        self.isConfigured = isConfigured
        self.lastValidated = lastValidated
    }

    // MARK: - Validation

    /// Validates that both API key and secret are non-empty
    /// - Returns: true if both credentials are provided
    var hasCredentials: Bool {
        return !apiKey.isEmpty && !apiSecret.isEmpty
    }

    /// Checks if credentials were recently validated (within last 24 hours)
    /// - Returns: true if credentials were validated recently
    var isRecentlyValidated: Bool {
        guard let lastValidated = lastValidated else { return false }
        let dayAgo = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        return lastValidated > dayAgo
    }

    /// Updates the configuration to mark it as validated
    /// - Returns: Updated configuration with current timestamp
    mutating func markAsValidated() {
        self.isConfigured = true
        self.lastValidated = Date()
    }

    /// Creates a new configuration with validation marked
    /// - Returns: New configuration instance with updated validation
    func validated() -> VestaboardConfiguration {
        var config = self
        config.markAsValidated()
        return config
    }
}

// MARK: - Equatable

extension VestaboardConfiguration: Equatable {
    static func == (lhs: VestaboardConfiguration, rhs: VestaboardConfiguration) -> Bool {
        return lhs.apiKey == rhs.apiKey &&
               lhs.apiSecret == rhs.apiSecret &&
               lhs.isConfigured == rhs.isConfigured
    }
}
