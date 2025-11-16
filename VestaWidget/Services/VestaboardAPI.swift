//
//  VestaboardAPI.swift
//  VestaWidget
//
//  Service for interacting with the Vestaboard Read/Write API
//  Handles GET (read current message) and POST (send message) operations
//  Reference: https://docs.vestaboard.com/read-write
//

import Foundation

/// Service for communicating with Vestaboard's Read/Write API
/// Implements async/await pattern for modern Swift concurrency
class VestaboardAPI {

    // MARK: - Properties

    /// Base URL for Vestaboard API
    private let baseURL = URL(string: AppConstants.vestaboardAPIBase)!

    /// URLSession configured for API requests
    private let session: URLSession

    // MARK: - Initialization

    /// Creates a new API service instance
    /// - Parameter session: Custom URLSession (defaults to configured session)
    init(session: URLSession? = nil) {
        if let session = session {
            self.session = session
        } else {
            // Configure default session with timeout
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = AppConstants.apiTimeout
            config.timeoutIntervalForResource = AppConstants.apiTimeout * 2
            config.waitsForConnectivity = true
            self.session = URLSession(configuration: config)
        }
    }

    // MARK: - Public Methods

    /// Retrieves the current message displayed on the Vestaboard
    /// - Parameters:
    ///   - apiKey: Vestaboard Read/Write API Key
    ///   - apiSecret: Vestaboard Read/Write API Secret
    /// - Returns: Current board content
    /// - Throws: APIError if request fails
    func getCurrentMessage(apiKey: String, apiSecret: String) async throws -> VestaboardContent {
        // Create request
        var request = URLRequest(url: baseURL)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: AppConstants.apiKeyHeader)
        request.setValue(apiSecret, forHTTPHeaderField: AppConstants.apiSecretHeader)

        // Execute request
        let (data, response) = try await session.data(for: request)

        // Validate response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        // Handle status codes
        try handleHTTPStatus(httpResponse.statusCode)

        // Parse response
        do {
            // The API returns a 6x22 array directly or wrapped in currentMessage
            let decoder = JSONDecoder()

            // Try direct array first
            if let rows = try? decoder.decode([[Int]].self, from: data) {
                return VestaboardContent(rows: rows, lastUpdated: Date())
            }

            // Try wrapped format
            struct Response: Codable {
                let currentMessage: CurrentMessage?

                struct CurrentMessage: Codable {
                    let layout: String?
                }
            }

            let response = try decoder.decode(Response.self, from: data)

            // Parse layout string if present
            if let layoutString = response.currentMessage?.layout,
               let layoutData = layoutString.data(using: .utf8),
               let rows = try? decoder.decode([[Int]].self, from: layoutData) {
                return VestaboardContent(rows: rows, lastUpdated: Date())
            }

            // If we still don't have data, try parsing as direct array one more time
            // Some API versions return the array at root level
            if let rows = try? JSONSerialization.jsonObject(with: data) as? [[Int]] {
                return VestaboardContent(rows: rows, lastUpdated: Date())
            }

            throw APIError.invalidResponse
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.parsingFailed(error)
        }
    }

    /// Posts a text message to the Vestaboard
    /// - Parameters:
    ///   - text: Message text to display (will be converted to character codes)
    ///   - apiKey: Vestaboard Read/Write API Key
    ///   - apiSecret: Vestaboard Read/Write API Secret
    /// - Throws: APIError if request fails
    func postMessage(text: String, apiKey: String, apiSecret: String) async throws {
        // Validate text is not empty
        guard !text.isEmpty else {
            throw APIError.invalidMessage("Message text cannot be empty")
        }

        // Create request body
        let body = ["text": text]

        try await postRequest(body: body, apiKey: apiKey, apiSecret: apiSecret)
    }

    /// Posts a message using character array
    /// - Parameters:
    ///   - characters: 6x22 array of Vestaboard character codes
    ///   - apiKey: Vestaboard Read/Write API Key
    ///   - apiSecret: Vestaboard Read/Write API Secret
    /// - Throws: APIError if request fails
    func postMessage(characters: [[Int]], apiKey: String, apiSecret: String) async throws {
        // Validate character array dimensions
        guard characters.isValidVestaboardLayout else {
            throw APIError.invalidMessage("Character array must be 6x22")
        }

        // Create request body
        let body = ["characters": characters]

        try await postRequest(body: body, apiKey: apiKey, apiSecret: apiSecret)
    }

    /// Tests API credentials by making a simple GET request
    /// - Parameters:
    ///   - apiKey: API Key to test
    ///   - apiSecret: API Secret to test
    /// - Returns: true if credentials are valid
    /// - Throws: APIError if credentials are invalid
    @discardableResult
    func testConnection(apiKey: String, apiSecret: String) async throws -> Bool {
        _ = try await getCurrentMessage(apiKey: apiKey, apiSecret: apiSecret)
        return true
    }

    // MARK: - Private Methods

    /// Executes a POST request to the Vestaboard API
    /// - Parameters:
    ///   - body: Request body (will be JSON encoded)
    ///   - apiKey: API Key
    ///   - apiSecret: API Secret
    /// - Throws: APIError if request fails
    private func postRequest(body: [String: Any], apiKey: String, apiSecret: String) async throws {
        // Create request
        var request = URLRequest(url: baseURL)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: AppConstants.apiKeyHeader)
        request.setValue(apiSecret, forHTTPHeaderField: AppConstants.apiSecretHeader)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Encode body
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            throw APIError.encodingFailed(error)
        }

        // Execute request
        let (_, response) = try await session.data(for: request)

        // Validate response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        // Handle status codes
        try handleHTTPStatus(httpResponse.statusCode)
    }

    /// Handles HTTP status codes and throws appropriate errors
    /// - Parameter statusCode: HTTP status code from response
    /// - Throws: APIError for non-success status codes
    private func handleHTTPStatus(_ statusCode: Int) throws {
        switch statusCode {
        case 200...299:
            return  // Success
        case 401:
            throw APIError.unauthorized
        case 429:
            throw APIError.rateLimited
        case 500...599:
            throw APIError.serverError(statusCode)
        default:
            throw APIError.httpError(statusCode)
        }
    }
}

// MARK: - API Errors

/// Errors that can occur when communicating with the Vestaboard API
enum APIError: LocalizedError {

    /// Invalid response from server
    case invalidResponse

    /// Authentication failed (401)
    case unauthorized

    /// Rate limit exceeded (429)
    case rateLimited

    /// Server error (5xx)
    case serverError(Int)

    /// Other HTTP error
    case httpError(Int)

    /// Failed to parse API response
    case parsingFailed(Error)

    /// Failed to encode request
    case encodingFailed(Error)

    /// Invalid message data
    case invalidMessage(String)

    /// Network error
    case networkError(Error)

    // MARK: - LocalizedError

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return AppConstants.ErrorMessages.invalidResponse

        case .unauthorized:
            return AppConstants.ErrorMessages.unauthorized

        case .rateLimited:
            return AppConstants.ErrorMessages.rateLimited

        case .serverError(let code):
            return "Vestaboard server error (HTTP \(code)). Please try again later."

        case .httpError(let code):
            return "HTTP error \(code). Please try again."

        case .parsingFailed:
            return "Failed to parse response from Vestaboard."

        case .encodingFailed:
            return "Failed to prepare message for sending."

        case .invalidMessage(let reason):
            return "Invalid message: \(reason)"

        case .networkError(let error):
            if let urlError = error as? URLError {
                return urlError.userFriendlyMessage
            }
            return "Network error: \(error.localizedDescription)"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .unauthorized:
            return "Please check your API credentials in Settings."

        case .rateLimited:
            return "Please wait a few moments before trying again."

        case .serverError:
            return "The Vestaboard service may be experiencing issues. Please try again later."

        case .invalidMessage:
            return "Please check your message and try again."

        case .networkError:
            return "Please check your internet connection."

        default:
            return "Please try again. If the problem persists, contact support."
        }
    }
}

// MARK: - Mock API for Testing

#if DEBUG
/// Mock API for testing and previews
class MockVestaboardAPI: VestaboardAPI {

    var shouldFail = false
    var mockContent: VestaboardContent = .sample
    var mockError: APIError = .serverError(500)

    override func getCurrentMessage(apiKey: String, apiSecret: String) async throws -> VestaboardContent {
        // Simulate network delay
        try? await Task.sleep(seconds: 0.5)

        if shouldFail {
            throw mockError
        }

        return mockContent
    }

    override func postMessage(text: String, apiKey: String, apiSecret: String) async throws {
        // Simulate network delay
        try? await Task.sleep(seconds: 0.5)

        if shouldFail {
            throw mockError
        }

        // Success - no action needed
    }

    override func postMessage(characters: [[Int]], apiKey: String, apiSecret: String) async throws {
        try? await Task.sleep(seconds: 0.5)

        if shouldFail {
            throw mockError
        }
    }
}
#endif
