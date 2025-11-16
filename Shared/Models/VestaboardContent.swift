//
//  VestaboardContent.swift
//  VestaWidget (Shared)
//
//  Model representing the current content displayed on a Vestaboard
//  Shared between main app and widget extension via App Group storage
//

import Foundation

/// Represents the current state of a Vestaboard display
/// This model is shared between the app and widgets via App Group UserDefaults
struct VestaboardContent: Codable {

    // MARK: - Properties

    /// 2D array of character codes representing the board state (6 rows × 22 columns)
    /// Each element is a Vestaboard character code (0-69)
    var rows: [[Int]]

    /// Timestamp of when this content was last updated from the API
    var lastUpdated: Date

    /// Optional human-readable text representation of the board content
    /// Generated from the character codes
    var message: String?

    // MARK: - Initialization

    /// Creates new Vestaboard content from character array
    /// - Parameters:
    ///   - rows: 6x22 array of character codes
    ///   - lastUpdated: Update timestamp (defaults to now)
    ///   - message: Optional text representation
    init(
        rows: [[Int]],
        lastUpdated: Date = Date(),
        message: String? = nil
    ) {
        self.rows = rows
        self.lastUpdated = lastUpdated
        self.message = message
    }

    /// Creates Vestaboard content from text
    /// - Parameters:
    ///   - text: Text to convert to board layout
    ///   - lastUpdated: Update timestamp (defaults to now)
    init(text: String, lastUpdated: Date = Date()) {
        self.rows = VestaboardCharacterSet.boardLayout(for: text)
        self.lastUpdated = lastUpdated
        self.message = text
    }

    // MARK: - Computed Properties

    /// Validates that the content has correct dimensions (6x22)
    var isValidLayout: Bool {
        return rows.isValidVestaboardLayout
    }

    /// Returns text representation of the board content
    var displayText: String {
        if let message = message {
            return message
        }
        return VestaboardCharacterSet.text(from: rows)
    }

    /// Checks if the content is empty (all blank characters)
    var isEmpty: Bool {
        return rows.allSatisfy { row in
            row.allSatisfy { $0 == VestaboardCharacterSet.blank }
        }
    }

    /// Returns the first N rows for display in smaller widgets
    /// - Parameter count: Number of rows to return (1-6)
    /// - Returns: Array of the first N rows
    func firstRows(_ count: Int) -> [[Int]] {
        let validCount = max(1, min(count, AppConstants.vestaboardRows))
        return Array(rows.prefix(validCount))
    }

    /// Returns character code at specific position
    /// - Parameters:
    ///   - row: Row index (0-5)
    ///   - column: Column index (0-21)
    /// - Returns: Character code, or nil if indices are invalid
    func character(at row: Int, column: Int) -> Int? {
        guard row >= 0 && row < rows.count,
              column >= 0 && column < rows[row].count else {
            return nil
        }
        return rows[row][column]
    }

    /// Checks if content was updated recently (within last hour)
    var isRecentlyUpdated: Bool {
        return lastUpdated.isWithinLast(minutes: 60)
    }

    /// Returns age of content as human-readable string
    var ageDescription: String {
        return lastUpdated.relativeTimeString
    }
}

// MARK: - Equatable

extension VestaboardContent: Equatable {
    static func == (lhs: VestaboardContent, rhs: VestaboardContent) -> Bool {
        return lhs.rows == rhs.rows &&
               lhs.message == rhs.message
    }
}

// MARK: - Sample Data

extension VestaboardContent {
    /// Creates a blank Vestaboard (all zeros)
    static var blank: VestaboardContent {
        let emptyRow = Array(repeating: VestaboardCharacterSet.blank, count: AppConstants.vestaboardColumns)
        let emptyRows = Array(repeating: emptyRow, count: AppConstants.vestaboardRows)
        return VestaboardContent(rows: emptyRows, message: "")
    }

    /// Sample content for previews and testing
    static var sample: VestaboardContent {
        return VestaboardContent(
            text: "HELLO WORLD! WELCOME TO VESTABOARD",
            lastUpdated: Date()
        )
    }

    /// Sample content with mixed content
    static var sampleMixed: VestaboardContent {
        var content = VestaboardContent.blank
        // Add some text in first few rows
        content.rows[0] = VestaboardCharacterSet.codes(for: String("TEMPERATURE: 72°F".padding(toLength: 22, withPad: " ", startingAt: 0))) ?? content.rows[0]
        content.rows[1] = VestaboardCharacterSet.codes(for: String("HUMIDITY: 45%".padding(toLength: 22, withPad: " ", startingAt: 0))) ?? content.rows[1]
        content.rows[3] = VestaboardCharacterSet.codes(for: String("HAVE A GREAT DAY!".padding(toLength: 22, withPad: " ", startingAt: 0))) ?? content.rows[3]
        content.message = "Temperature and weather display"
        content.lastUpdated = Date()
        return content
    }

    /// Sample content with color blocks
    static var sampleWithColors: VestaboardContent {
        var content = VestaboardContent.blank
        // Create a rainbow pattern in first row
        content.rows[0] = [
            VestaboardCharacterSet.red, VestaboardCharacterSet.red,
            VestaboardCharacterSet.orange, VestaboardCharacterSet.orange,
            VestaboardCharacterSet.yellow, VestaboardCharacterSet.yellow,
            VestaboardCharacterSet.green, VestaboardCharacterSet.green,
            VestaboardCharacterSet.blue, VestaboardCharacterSet.blue,
            VestaboardCharacterSet.violet, VestaboardCharacterSet.violet,
            VestaboardCharacterSet.white, VestaboardCharacterSet.white,
            VestaboardCharacterSet.blank, VestaboardCharacterSet.blank,
            VestaboardCharacterSet.blank, VestaboardCharacterSet.blank,
            VestaboardCharacterSet.blank, VestaboardCharacterSet.blank,
            VestaboardCharacterSet.blank, VestaboardCharacterSet.blank
        ]
        content.rows[2] = VestaboardCharacterSet.codes(for: String("RAINBOW COLORS!".padding(toLength: 22, withPad: " ", startingAt: 0))) ?? content.rows[2]
        content.message = "Color demonstration"
        return content
    }
}
