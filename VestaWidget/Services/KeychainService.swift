//
//  KeychainService.swift
//  VestaWidget
//
//  Service for securely storing and retrieving API credentials using iOS Keychain
//  Credentials are shared between app and widget extension via Keychain Access Group
//

import Foundation
import Security

/// Service for managing secure credential storage in iOS Keychain
/// Uses App Group keychain sharing to allow widget extension to access credentials
class KeychainService {

    // MARK: - Singleton

    /// Shared instance for app-wide access
    static let shared = KeychainService()

    // MARK: - Private Initialization

    /// Private initializer to enforce singleton pattern
    private init() {}

    // MARK: - Public Methods

    /// Saves Vestaboard configuration to Keychain
    /// - Parameter configuration: Configuration containing API credentials
    /// - Throws: KeychainError if save fails
    func save(_ configuration: VestaboardConfiguration) throws {
        // Encode configuration to Data
        let data = try JSONEncoder().encode(configuration)

        // Create keychain query dictionary
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: AppConstants.keychainIdentifier,
            kSecAttrAccessGroup as String: AppConstants.keychainAccessGroup,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        // Delete any existing item first to avoid duplicates
        SecItemDelete(query as CFDictionary)

        // Add new item to keychain
        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status: status)
        }
    }

    /// Retrieves Vestaboard configuration from Keychain
    /// - Returns: Stored configuration
    /// - Throws: KeychainError if retrieval fails or no configuration exists
    func retrieve() throws -> VestaboardConfiguration {
        // Create keychain query dictionary
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: AppConstants.keychainIdentifier,
            kSecAttrAccessGroup as String: AppConstants.keychainAccessGroup,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        // Query keychain
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        // Check for errors
        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                throw KeychainError.notFound
            }
            throw KeychainError.retrieveFailed(status: status)
        }

        // Decode data
        guard let data = result as? Data else {
            throw KeychainError.invalidData
        }

        do {
            return try JSONDecoder().decode(VestaboardConfiguration.self, from: data)
        } catch {
            throw KeychainError.decodingFailed(error)
        }
    }

    /// Checks if a configuration exists in Keychain
    /// - Returns: true if configuration is stored, false otherwise
    func hasConfiguration() -> Bool {
        do {
            _ = try retrieve()
            return true
        } catch {
            return false
        }
    }

    /// Deletes stored configuration from Keychain
    /// - Throws: KeychainError if deletion fails
    func delete() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: AppConstants.keychainIdentifier,
            kSecAttrAccessGroup as String: AppConstants.keychainAccessGroup
        ]

        let status = SecItemDelete(query as CFDictionary)

        // Success if deleted or item didn't exist
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status: status)
        }
    }

    /// Updates existing configuration in Keychain
    /// - Parameter configuration: Updated configuration
    /// - Throws: KeychainError if update fails
    func update(_ configuration: VestaboardConfiguration) throws {
        // Updating in keychain is same as saving (we delete old and add new)
        try save(configuration)
    }
}

// MARK: - Keychain Errors

/// Errors that can occur during Keychain operations
enum KeychainError: LocalizedError {

    /// Failed to save item to Keychain
    case saveFailed(status: OSStatus)

    /// Failed to retrieve item from Keychain
    case retrieveFailed(status: OSStatus)

    /// Failed to delete item from Keychain
    case deleteFailed(status: OSStatus)

    /// No configuration found in Keychain
    case notFound

    /// Retrieved data is not valid
    case invalidData

    /// Failed to decode configuration from stored data
    case decodingFailed(Error)

    // MARK: - LocalizedError

    var errorDescription: String? {
        switch self {
        case .saveFailed(let status):
            return "Failed to save credentials to Keychain (error code: \(status))"
        case .retrieveFailed(let status):
            return "Failed to retrieve credentials from Keychain (error code: \(status))"
        case .deleteFailed(let status):
            return "Failed to delete credentials from Keychain (error code: \(status))"
        case .notFound:
            return "No credentials found. Please configure your Vestaboard connection."
        case .invalidData:
            return "Stored credentials are corrupted. Please reconfigure."
        case .decodingFailed:
            return "Failed to read stored credentials. Please reconfigure."
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .notFound, .invalidData, .decodingFailed:
            return "Go to Settings to configure your Vestaboard API credentials."
        case .saveFailed, .retrieveFailed, .deleteFailed:
            return "Please try again. If the problem persists, restart the app."
        }
    }
}

// MARK: - Helper Extensions

private extension OSStatus {
    /// Returns human-readable description of OSStatus code
    var description: String {
        if let errorString = SecCopyErrorMessageString(self, nil) as String? {
            return errorString
        }
        return "Unknown error (\(self))"
    }
}
