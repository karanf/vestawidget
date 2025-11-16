//
//  Extensions.swift
//  VestaWidget
//
//  Swift extensions for common functionality used throughout the app
//  These extensions enhance standard types with domain-specific functionality
//

import Foundation
import SwiftUI

// MARK: - Date Extensions

extension Date {
    /// Formats date as relative time string (e.g., "2 minutes ago")
    /// - Returns: User-friendly relative time string
    var relativeTimeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    /// Formats date as short time string (e.g., "2:30 PM")
    /// - Returns: Formatted time string
    var shortTimeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }

    /// Formats date as short date and time (e.g., "Jan 15, 2:30 PM")
    /// - Returns: Formatted date and time string
    var shortDateTimeString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }

    /// Formats date for widget display (compact format)
    /// - Returns: Compact formatted string
    var widgetDisplayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter.string(from: self)
    }

    /// Returns true if the date is within the last N minutes
    /// - Parameter minutes: Number of minutes to check
    /// - Returns: true if date is within the specified time window
    func isWithinLast(minutes: Int) -> Bool {
        let timeInterval = TimeInterval(minutes * 60)
        return Date().timeIntervalSince(self) < timeInterval
    }
}

// MARK: - String Extensions

extension String {
    /// Truncates string to specified length with ellipsis
    /// - Parameter length: Maximum length of string
    /// - Returns: Truncated string with "..." if needed
    func truncated(to length: Int) -> String {
        if self.count <= length {
            return self
        }
        let endIndex = self.index(self.startIndex, offsetBy: length - 3)
        return String(self[..<endIndex]) + "..."
    }

    /// Returns true if string contains only supported Vestaboard characters
    var isVestaboardCompatible: Bool {
        return VestaboardCharacterSet.validateText(self)
    }

    /// Returns array of unsupported characters
    var unsupportedVestaboardCharacters: [Character] {
        return VestaboardCharacterSet.unsupportedCharacters(in: self)
    }

    /// Replaces unsupported characters with Vestaboard-compatible alternatives
    var sanitizedForVestaboard: String {
        return VestaboardCharacterSet.sanitize(self)
    }

    /// Returns true if string is empty or contains only whitespace
    var isBlankOrEmpty: Bool {
        return self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Counts the number of lines in a multi-line string
    var lineCount: Int {
        return self.components(separatedBy: .newlines).count
    }
}

// MARK: - Array Extensions

extension Array where Element == Int {
    /// Validates that all elements are valid Vestaboard character codes (0-69)
    var areValidVestaboardCodes: Bool {
        return self.allSatisfy { $0 >= 0 && $0 <= 69 }
    }
}

extension Array where Element == [Int] {
    /// Validates that array represents a valid Vestaboard layout (6x22)
    var isValidVestaboardLayout: Bool {
        guard self.count == AppConstants.vestaboardRows else { return false }
        return self.allSatisfy { row in
            row.count == AppConstants.vestaboardColumns && row.areValidVestaboardCodes
        }
    }

    /// Converts board layout to readable text
    var asText: String {
        return VestaboardCharacterSet.text(from: self)
    }
}

// MARK: - Color Extensions

extension Color {
    /// Returns color for Vestaboard character code (63-69)
    /// - Parameter code: Vestaboard color code
    /// - Returns: Corresponding SwiftUI Color
    static func vestaboardColor(for code: Int) -> Color {
        switch code {
        case VestaboardCharacterSet.red:
            return Color(red: 0.93, green: 0.26, blue: 0.21)  // #ED4336
        case VestaboardCharacterSet.orange:
            return Color(red: 0.96, green: 0.49, blue: 0.13)  // #F57D21
        case VestaboardCharacterSet.yellow:
            return Color(red: 1.0, green: 0.76, blue: 0.03)   // #FFC208
        case VestaboardCharacterSet.green:
            return Color(red: 0.0, green: 0.65, blue: 0.42)   // #00A66B
        case VestaboardCharacterSet.blue:
            return Color(red: 0.0, green: 0.45, blue: 0.81)   // #0073CF
        case VestaboardCharacterSet.violet:
            return Color(red: 0.42, green: 0.20, blue: 0.65)  // #6C33A5
        case VestaboardCharacterSet.white:
            return Color.white
        default:
            return Color.black
        }
    }

    /// Vestaboard's standard black background color
    static let vestaboardBlack = Color(red: 0.11, green: 0.11, blue: 0.11)  // #1C1C1C

    /// Vestaboard's standard character color (off-white/cream)
    static let vestaboardCharacter = Color(red: 1.0, green: 0.98, blue: 0.94)  // #FFF9EF
}

// MARK: - UserDefaults Extensions

extension UserDefaults {
    /// Saves a Codable object to UserDefaults
    /// - Parameters:
    ///   - object: Object to save
    ///   - key: Storage key
    func setCodable<T: Codable>(_ object: T, forKey key: String) throws {
        let data = try JSONEncoder().encode(object)
        self.set(data, forKey: key)
    }

    /// Retrieves a Codable object from UserDefaults
    /// - Parameters:
    ///   - type: Type of object to retrieve
    ///   - key: Storage key
    /// - Returns: Decoded object, or nil if not found or decoding fails
    func codable<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = self.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}

// MARK: - Error Extensions

extension Error {
    /// Returns user-friendly error message
    var userFriendlyMessage: String {
        // Check if it's a LocalizedError with custom description
        if let localizedError = self as? LocalizedError,
           let description = localizedError.errorDescription {
            return description
        }

        // Check for specific error types
        if let urlError = self as? URLError {
            return urlError.userFriendlyMessage
        }

        // Default to localized description
        return self.localizedDescription
    }
}

extension URLError {
    /// Returns user-friendly message for common network errors
    var userFriendlyMessage: String {
        switch self.code {
        case .notConnectedToInternet:
            return AppConstants.ErrorMessages.noInternet
        case .timedOut:
            return AppConstants.ErrorMessages.timeout
        case .cannotFindHost, .cannotConnectToHost:
            return "Cannot reach Vestaboard servers. Please try again."
        case .networkConnectionLost:
            return "Network connection lost. Please check your connection."
        case .badServerResponse:
            return AppConstants.ErrorMessages.invalidResponse
        default:
            return "Network error: \(self.localizedDescription)"
        }
    }
}

// MARK: - View Extensions

extension View {
    /// Applies a conditional modifier to a view
    /// - Parameters:
    ///   - condition: Condition to check
    ///   - transform: Modifier to apply if condition is true
    /// - Returns: Modified view
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// Applies a conditional modifier with else clause
    /// - Parameters:
    ///   - condition: Condition to check
    ///   - ifTransform: Modifier to apply if condition is true
    ///   - elseTransform: Modifier to apply if condition is false
    /// - Returns: Modified view
    @ViewBuilder
    func `if`<TrueContent: View, FalseContent: View>(
        _ condition: Bool,
        if ifTransform: (Self) -> TrueContent,
        else elseTransform: (Self) -> FalseContent
    ) -> some View {
        if condition {
            ifTransform(self)
        } else {
            elseTransform(self)
        }
    }
}

// MARK: - Task Extensions

extension Task where Success == Never, Failure == Never {
    /// Delays execution for a specified number of seconds
    /// - Parameter seconds: Number of seconds to delay
    static func sleep(seconds: TimeInterval) async throws {
        try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    }
}

// MARK: - Bundle Extensions

extension Bundle {
    /// Returns the app version string
    var appVersion: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }

    /// Returns the build number string
    var buildNumber: String {
        return infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }

    /// Returns the full version string (version + build)
    var fullVersion: String {
        return "\(appVersion) (\(buildNumber))"
    }
}
