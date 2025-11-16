//
//  Constants.swift
//  VestaWidget
//
//  Application-wide constants for VestaWidget app
//  Centralizes configuration values to ensure consistency across app and widgets
//

import Foundation

/// Global constants used throughout the VestaWidget application
/// These values should not be changed without careful consideration of their impact
/// on both the main app and widget extension
enum AppConstants {

    // MARK: - App Group & Keychain

    /// App Group identifier for sharing data between app and widget extension
    /// This MUST match the App Group configured in both targets' entitlements
    /// Format: group.{reverse-domain}.{app-name}
    static let appGroupIdentifier = "group.com.vestawidget.shared"

    /// Keychain identifier for storing credentials securely
    /// Using the same identifier allows widgets to access credentials
    static let keychainIdentifier = "com.vestawidget.credentials"

    /// Keychain access group for sharing credentials between app and widgets
    /// This enables the widget extension to read API credentials stored by the main app
    static let keychainAccessGroup = "com.vestawidget.shared"

    // MARK: - Vestaboard API

    /// Base URL for Vestaboard Read/Write API
    /// Documentation: https://docs.vestaboard.com/read-write
    static let vestaboardAPIBase = "https://rw.vestaboard.com"

    /// Timeout for API requests in seconds
    /// Set to 30 seconds to handle slow network conditions
    static let apiTimeout: TimeInterval = 30

    /// HTTP header name for Vestaboard API Key
    static let apiKeyHeader = "X-Vestaboard-Read-Write-Key"

    /// HTTP header name for Vestaboard API Secret
    static let apiSecretHeader = "X-Vestaboard-Api-Secret"

    // MARK: - Widget Configuration

    /// Widget refresh interval in seconds (15 minutes)
    /// iOS WidgetKit minimum is 15 minutes for automatic refresh
    static let widgetRefreshInterval: TimeInterval = 900

    /// Number of timeline entries to generate (24 hours / 15 minutes = 96 entries)
    /// This provides a full day of scheduled updates
    static let timelineEntryCount = 96

    // MARK: - Vestaboard Specifications

    /// Number of rows on a Vestaboard display
    static let vestaboardRows = 6

    /// Number of columns (characters per row) on a Vestaboard display
    static let vestaboardColumns = 22

    /// Maximum message length (6 rows × 22 columns = 132 characters)
    static let maxMessageLength = vestaboardRows * vestaboardColumns

    // MARK: - Storage Keys

    /// UserDefaults key for storing current Vestaboard content in App Group
    static let currentContentKey = "currentContent"

    /// UserDefaults key for storing message templates
    static let messageTemplatesKey = "messageTemplates"

    /// UserDefaults key for storing message history
    static let messageHistoryKey = "messageHistory"

    /// UserDefaults key for storing last successful sync timestamp
    static let lastSyncKey = "lastSync"

    /// UserDefaults key for widget configuration preferences
    static let widgetConfigKey = "widgetConfig"

    // MARK: - Limits

    /// Maximum number of message templates user can save
    static let maxTemplates = 20

    /// Maximum number of messages to keep in history
    static let maxHistoryItems = 50

    /// Maximum number of retry attempts for failed API calls
    static let maxRetryAttempts = 3

    /// Base delay for exponential backoff (in seconds)
    static let retryBaseDelay: TimeInterval = 2

    // MARK: - URL Schemes

    /// Custom URL scheme for deep linking from widgets
    static let appURLScheme = "vestawidget"

    /// Deep link to open configuration screen
    static let configurationURL = "vestawidget://configure"

    /// Deep link to open message composer
    static let composerURL = "vestawidget://compose"

    // MARK: - Error Messages

    /// User-friendly error messages
    enum ErrorMessages {
        static let noInternet = "No internet connection. Please check your network settings."
        static let unauthorized = "Invalid API credentials. Please check your API key and secret."
        static let rateLimited = "Too many requests. Please wait a moment and try again."
        static let serverError = "Vestaboard server error. Please try again later."
        static let timeout = "Request timed out. Please check your connection."
        static let invalidResponse = "Received invalid response from server."
        static let notConfigured = "Please configure your Vestaboard credentials in the app."
        static let keychainError = "Failed to access secure storage. Please try again."
        static let characterValidation = "Message contains unsupported characters."
    }

    // MARK: - Success Messages

    enum SuccessMessages {
        static let configurationSaved = "Configuration saved successfully!"
        static let connectionTested = "Connection successful!"
        static let messageSent = "Message sent to your Vestaboard!"
        static let templateSaved = "Template saved!"
        static let templateDeleted = "Template deleted."
    }
}
