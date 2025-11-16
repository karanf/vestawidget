//
//  ConfigurationViewModel.swift
//  VestaWidget
//
//  ViewModel for managing Vestaboard configuration flow
//  Handles credential validation, storage, and connection testing
//

import Foundation
import Combine
import WidgetKit

/// ViewModel for configuration screen
/// Manages API credential input, validation, and storage
@MainActor
class ConfigurationViewModel: ObservableObject {

    // MARK: - Published Properties

    /// API Key input field value
    @Published var apiKey: String = ""

    /// API Secret input field value
    @Published var apiSecret: String = ""

    /// Whether an operation is in progress
    @Published var isLoading: Bool = false

    /// Current error message to display
    @Published var errorMessage: String?

    /// Current success message to display
    @Published var successMessage: String?

    /// Whether the app is configured
    @Published var isConfigured: Bool = false

    /// Connection status for display
    @Published var connectionStatus: ConnectionStatus = .notConfigured

    /// Last successful validation timestamp
    @Published var lastValidated: Date?

    // MARK: - Types

    enum ConnectionStatus {
        case notConfigured
        case testing
        case connected
        case disconnected
        case error

        var description: String {
            switch self {
            case .notConfigured: return "Not Configured"
            case .testing: return "Testing..."
            case .connected: return "Connected"
            case .disconnected: return "Disconnected"
            case .error: return "Error"
            }
        }

        var color: String {
            switch self {
            case .notConfigured: return "gray"
            case .testing: return "blue"
            case .connected: return "green"
            case .disconnected: return "orange"
            case .error: return "red"
            }
        }
    }

    // MARK: - Private Properties

    private let api: VestaboardAPI
    private let keychain = KeychainService.shared
    private let storage = AppGroupStorage.shared

    // MARK: - Initialization

    /// Creates a new configuration view model
    /// - Parameter api: API service (can be injected for testing)
    init(api: VestaboardAPI = VestaboardAPI()) {
        self.api = api
        loadConfiguration()
    }

    // MARK: - Public Methods

    /// Loads existing configuration from keychain
    func loadConfiguration() {
        do {
            let config = try keychain.retrieve()
            isConfigured = config.isConfigured
            lastValidated = config.lastValidated

            if config.isConfigured {
                connectionStatus = .connected
            }
        } catch {
            isConfigured = false
            connectionStatus = .notConfigured
        }
    }

    /// Validates input fields
    /// - Returns: true if inputs are valid
    func validateInputs() -> Bool {
        errorMessage = nil

        guard !apiKey.isBlankOrEmpty else {
            errorMessage = "Please enter your API Key"
            return false
        }

        guard !apiSecret.isBlankOrEmpty else {
            errorMessage = "Please enter your API Secret"
            return false
        }

        // Basic format validation
        guard apiKey.count > 10 else {
            errorMessage = "API Key appears to be too short"
            return false
        }

        guard apiSecret.count > 10 else {
            errorMessage = "API Secret appears to be too short"
            return false
        }

        return true
    }

    /// Tests the API connection with current credentials
    func testConnection() async {
        guard validateInputs() else { return }

        isLoading = true
        errorMessage = nil
        successMessage = nil
        connectionStatus = .testing

        do {
            // Test the connection
            try await api.testConnection(apiKey: apiKey, apiSecret: apiSecret)

            // Success
            successMessage = AppConstants.SuccessMessages.connectionTested
            connectionStatus = .connected

            // Provide haptic feedback
            #if os(iOS)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            #endif

        } catch {
            // Failure
            errorMessage = error.userFriendlyMessage
            connectionStatus = .error

            #if os(iOS)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            #endif
        }

        isLoading = false
    }

    /// Saves configuration to keychain
    func saveConfiguration() async {
        guard validateInputs() else { return }

        isLoading = true
        errorMessage = nil
        successMessage = nil

        do {
            // Test credentials first
            try await api.testConnection(apiKey: apiKey, apiSecret: apiSecret)

            // Create configuration
            var config = VestaboardConfiguration(
                apiKey: apiKey,
                apiSecret: apiSecret,
                isConfigured: true,
                lastValidated: Date()
            )
            config.markAsValidated()

            // Save to keychain
            try keychain.save(config)

            // Update state
            isConfigured = true
            lastValidated = config.lastValidated
            connectionStatus = .connected
            successMessage = AppConstants.SuccessMessages.configurationSaved

            // Clear input fields for security
            clearInputs()

            // Trigger widget refresh
            WidgetCenter.shared.reloadAllTimelines()

            // Haptic feedback
            #if os(iOS)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            #endif

        } catch {
            errorMessage = error.userFriendlyMessage
            connectionStatus = .error

            #if os(iOS)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            #endif
        }

        isLoading = false
    }

    /// Clears the stored configuration
    func clearConfiguration() {
        do {
            try keychain.delete()

            // Also clear shared storage
            storage.deleteContent()

            // Update state
            isConfigured = false
            lastValidated = nil
            connectionStatus = .notConfigured
            successMessage = "Configuration cleared"
            clearInputs()

            // Update widgets
            WidgetCenter.shared.reloadAllTimelines()

        } catch {
            errorMessage = "Failed to clear configuration: \(error.localizedDescription)"
        }
    }

    /// Updates existing configuration
    func updateConfiguration() async {
        // Same as save for now
        await saveConfiguration()
    }

    /// Checks current connection status
    func checkStatus() async {
        guard isConfigured else {
            connectionStatus = .notConfigured
            return
        }

        do {
            let config = try keychain.retrieve()
            connectionStatus = .testing

            try await api.testConnection(apiKey: config.apiKey, apiSecret: config.apiSecret)

            connectionStatus = .connected
            lastValidated = Date()

            // Update validation timestamp
            var updatedConfig = config
            updatedConfig.markAsValidated()
            try keychain.save(updatedConfig)

        } catch {
            connectionStatus = .error
            errorMessage = error.userFriendlyMessage
        }
    }

    // MARK: - Private Methods

    /// Clears input fields
    private func clearInputs() {
        apiKey = ""
        apiSecret = ""
    }

    /// Clears all messages
    func clearMessages() {
        errorMessage = nil
        successMessage = nil
    }
}
