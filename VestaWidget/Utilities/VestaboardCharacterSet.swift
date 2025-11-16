//
//  VestaboardCharacterSet.swift
//  VestaWidget
//
//  Vestaboard character code mapping and validation utilities
//  Maps characters to their corresponding Vestaboard character codes (0-69)
//  Reference: https://docs.vestaboard.com/character-codes
//

import Foundation

/// Utility for converting between characters and Vestaboard character codes
/// Vestaboard uses a proprietary character encoding system where each displayable
/// character or color is represented by a number from 0 to 69
enum VestaboardCharacterSet {

    // MARK: - Character Codes

    /// Blank space (code 0)
    static let blank = 0

    // Letters A-Z (codes 1-26)
    static let A = 1, B = 2, C = 3, D = 4, E = 5, F = 6, G = 7, H = 8, I = 9
    static let J = 10, K = 11, L = 12, M = 13, N = 14, O = 15, P = 16, Q = 17
    static let R = 18, S = 19, T = 20, U = 21, V = 22, W = 23, X = 24, Y = 25, Z = 26

    // Numbers 0-9 (codes 27-36)
    static let digit0 = 27, digit1 = 28, digit2 = 29, digit3 = 30, digit4 = 31
    static let digit5 = 32, digit6 = 33, digit7 = 34, digit8 = 35, digit9 = 36

    // Special characters
    static let exclamation = 37    // !
    static let at = 38             // @
    static let hash = 39           // #
    static let dollar = 40         // $
    static let leftParen = 41      // (
    static let rightParen = 42     // )
    static let hyphen = 44         // -
    static let plus = 46           // +
    static let ampersand = 47      // &
    static let equals = 48         // =
    static let semicolon = 49      // ;
    static let colon = 50          // :
    static let singleQuote = 52    // '
    static let doubleQuote = 53    // "
    static let percent = 54        // %
    static let comma = 55          // ,
    static let period = 56         // .
    static let slash = 59          // /
    static let question = 60       // ?
    static let degreeSign = 62     // °

    // Color codes (filled blocks) - codes 63-69
    static let red = 63
    static let orange = 64
    static let yellow = 65
    static let green = 66
    static let blue = 67
    static let violet = 68
    static let white = 69

    // MARK: - Character Mapping

    /// Complete mapping of characters to their Vestaboard codes
    private static let characterToCode: [Character: Int] = [
        " ": blank,

        // Uppercase letters
        "A": A, "B": B, "C": C, "D": D, "E": E, "F": F, "G": G, "H": H, "I": I,
        "J": J, "K": K, "L": L, "M": M, "N": N, "O": O, "P": P, "Q": Q,
        "R": R, "S": S, "T": T, "U": U, "V": V, "W": W, "X": X, "Y": Y, "Z": Z,

        // Numbers
        "0": digit0, "1": digit1, "2": digit2, "3": digit3, "4": digit4,
        "5": digit5, "6": digit6, "7": digit7, "8": digit8, "9": digit9,

        // Special characters
        "!": exclamation,
        "@": at,
        "#": hash,
        "$": dollar,
        "(": leftParen,
        ")": rightParen,
        "-": hyphen,
        "+": plus,
        "&": ampersand,
        "=": equals,
        ";": semicolon,
        ":": colon,
        "'": singleQuote,
        "\"": doubleQuote,
        "%": percent,
        ",": comma,
        ".": period,
        "/": slash,
        "?": question,
        "°": degreeSign
    ]

    /// Reverse mapping of Vestaboard codes to characters
    private static let codeToCharacter: [Int: Character] = {
        var mapping: [Int: Character] = [:]
        for (char, code) in characterToCode {
            mapping[code] = char
        }
        return mapping
    }()

    // MARK: - Public Methods

    /// Converts a character to its Vestaboard character code
    /// - Parameter character: The character to convert
    /// - Returns: The Vestaboard code, or nil if character is not supported
    static func code(for character: Character) -> Int? {
        // Convert to uppercase since Vestaboard only supports uppercase
        let uppercased = String(character).uppercased().first ?? character
        return characterToCode[uppercased]
    }

    /// Converts a Vestaboard character code to a displayable character
    /// - Parameter code: The Vestaboard code (0-69)
    /// - Returns: The corresponding character, or "?" if code is invalid
    static func character(for code: Int) -> Character {
        // Handle color codes - they don't have text representation
        if code >= red && code <= white {
            return "■"  // Filled block to represent colors
        }
        return codeToCharacter[code] ?? "?"
    }

    /// Checks if a character is supported by Vestaboard
    /// - Parameter character: The character to check
    /// - Returns: true if the character can be displayed on Vestaboard
    static func isSupported(_ character: Character) -> Bool {
        return code(for: character) != nil
    }

    /// Validates that all characters in a string are supported by Vestaboard
    /// - Parameter text: The string to validate
    /// - Returns: true if all characters are supported
    static func validateText(_ text: String) -> Bool {
        return text.allSatisfy { isSupported($0) }
    }

    /// Returns array of unsupported characters in a string
    /// - Parameter text: The string to check
    /// - Returns: Array of characters that are not supported by Vestaboard
    static func unsupportedCharacters(in text: String) -> [Character] {
        return text.filter { !isSupported($0) }
    }

    /// Converts a string to an array of Vestaboard character codes
    /// - Parameter text: The string to convert
    /// - Returns: Array of character codes, or nil if any character is unsupported
    static func codes(for text: String) -> [Int]? {
        var codes: [Int] = []
        for character in text.uppercased() {
            guard let code = code(for: character) else {
                return nil  // Unsupported character found
            }
            codes.append(code)
        }
        return codes
    }

    /// Converts a string to a 2D array of Vestaboard character codes (6x22)
    /// - Parameter text: The string to convert
    /// - Returns: 6x22 array of character codes, padded with blanks
    /// - Note: Text longer than 132 characters will be truncated
    static func boardLayout(for text: String) -> [[Int]] {
        // Get character codes, truncating to max length
        let uppercased = text.uppercased()
        let truncated = String(uppercased.prefix(AppConstants.maxMessageLength))

        // Convert to codes, replacing unsupported characters with blank
        var codes: [Int] = truncated.map { code(for: $0) ?? blank }

        // Pad to 132 characters (6 rows × 22 columns)
        while codes.count < AppConstants.maxMessageLength {
            codes.append(blank)
        }

        // Split into 6 rows of 22 characters each
        var rows: [[Int]] = []
        for rowIndex in 0..<AppConstants.vestaboardRows {
            let start = rowIndex * AppConstants.vestaboardColumns
            let end = start + AppConstants.vestaboardColumns
            let row = Array(codes[start..<end])
            rows.append(row)
        }

        return rows
    }

    /// Converts a 2D array of character codes to a readable string
    /// - Parameter layout: 6x22 array of character codes
    /// - Returns: String representation of the board content
    static func text(from layout: [[Int]]) -> String {
        var result = ""
        for (rowIndex, row) in layout.enumerated() {
            for code in row {
                result.append(character(for: code))
            }
            // Add newline between rows (except after last row)
            if rowIndex < layout.count - 1 {
                result.append("\n")
            }
        }
        return result
    }

    /// Suggests alternative characters for unsupported characters
    /// - Parameter character: The unsupported character
    /// - Returns: Suggested replacement character, or nil if no good alternative
    static func suggestedReplacement(for character: Character) -> Character? {
        // Common replacements for unsupported characters
        let replacements: [Character: Character] = [
            "_": "-",     // underscore → hyphen
            "*": ".",     // asterisk → period
            "|": "!",     // pipe → exclamation
            "~": "-",     // tilde → hyphen
            "`": "'",     // backtick → single quote
            "^": ".",     // caret → period
            "[": "(",     // left bracket → left paren
            "]": ")",     // right bracket → right paren
            "{": "(",     // left brace → left paren
            "}": ")",     // right brace → right paren
            "<": "(",     // less than → left paren
            ">": ")",     // greater than → right paren
            "\\": "/",    // backslash → forward slash
        ]
        return replacements[character]
    }

    /// Cleans a string by replacing unsupported characters with alternatives
    /// - Parameter text: The string to clean
    /// - Returns: String with unsupported characters replaced
    static func sanitize(_ text: String) -> String {
        var result = ""
        for character in text {
            if isSupported(character) {
                result.append(character)
            } else if let replacement = suggestedReplacement(for: character) {
                result.append(replacement)
            } else {
                // Skip unsupported characters without replacement
                continue
            }
        }
        return result
    }

    /// Returns a string listing all supported characters
    /// - Returns: Human-readable string of supported characters
    static func supportedCharactersDescription() -> String {
        return """
        Supported characters:
        • Letters: A-Z (uppercase only)
        • Numbers: 0-9
        • Symbols: ! @ # $ ( ) - + & = ; : ' " % , . / ?
        • Special: ° (degree sign)
        • Colors: Red, Orange, Yellow, Green, Blue, Violet, White blocks
        """
    }

    /// Checks if a character code represents a color block
    /// - Parameter code: The character code to check
    /// - Returns: true if the code is a color block (63-69)
    static func isColorCode(_ code: Int) -> Bool {
        return code >= red && code <= white
    }

    /// Returns the color name for a color code
    /// - Parameter code: The color code (63-69)
    /// - Returns: Color name, or nil if not a color code
    static func colorName(for code: Int) -> String? {
        switch code {
        case red: return "Red"
        case orange: return "Orange"
        case yellow: return "Yellow"
        case green: return "Green"
        case blue: return "Blue"
        case violet: return "Violet"
        case white: return "White"
        default: return nil
        }
    }
}
