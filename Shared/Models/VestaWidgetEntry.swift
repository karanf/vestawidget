//
//  VestaWidgetEntry.swift
//  VestaWidget (Shared)
//
//  Timeline entry model for WidgetKit integration
//  Used by all widget sizes to display Vestaboard content
//

import Foundation
import WidgetKit

/// Timeline entry for VestaWidget widgets
/// Conforms to WidgetKit's TimelineEntry protocol
struct VestaWidgetEntry: TimelineEntry {

    // MARK: - TimelineEntry Protocol

    /// Date when this entry should be displayed
    /// WidgetKit uses this to determine when to show each timeline entry
    let date: Date

    // MARK: - Properties

    /// Current Vestaboard content to display
    /// nil indicates unconfigured or placeholder state
    let content: VestaboardContent?

    /// Configuration status (determines if credentials are available)
    /// nil indicates no configuration exists
    let isConfigured: Bool

    /// Optional error message to display if content fetch failed
    let errorMessage: String?

    // MARK: - Initialization

    /// Creates a new widget timeline entry
    /// - Parameters:
    ///   - date: Display date for this entry
    ///   - content: Vestaboard content to show
    ///   - isConfigured: Whether app is configured
    ///   - errorMessage: Optional error message
    init(
        date: Date,
        content: VestaboardContent?,
        isConfigured: Bool = false,
        errorMessage: String? = nil
    ) {
        self.date = date
        self.content = content
        self.isConfigured = isConfigured
        self.errorMessage = errorMessage
    }

    // MARK: - Computed Properties

    /// Whether this is a placeholder entry (no content, no error)
    var isPlaceholder: Bool {
        return content == nil && errorMessage == nil && !isConfigured
    }

    /// Whether this entry represents an error state
    var hasError: Bool {
        return errorMessage != nil
    }

    /// Whether this entry has valid content to display
    var hasContent: Bool {
        return content != nil && errorMessage == nil
    }

    // MARK: - Timeline Relevance

    /// Relevance score for WidgetKit (affects widget update priority)
    /// Higher scores = higher priority for updates
    var relevance: TimelineEntryRelevance? {
        if hasError {
            return TimelineEntryRelevance(score: 10)  // Low priority for errors
        } else if hasContent {
            // Higher score if content is recent
            let isRecent = content?.isRecentlyUpdated ?? false
            return TimelineEntryRelevance(score: isRecent ? 80 : 50)
        } else {
            return TimelineEntryRelevance(score: 30)  // Medium-low priority for placeholder
        }
    }
}

// MARK: - Factory Methods

extension VestaWidgetEntry {

    /// Creates a placeholder entry for unconfigured state
    /// - Parameter date: Display date (defaults to now)
    /// - Returns: Placeholder timeline entry
    static func placeholder(date: Date = Date()) -> VestaWidgetEntry {
        return VestaWidgetEntry(
            date: date,
            content: nil,
            isConfigured: false,
            errorMessage: nil
        )
    }

    /// Creates an error entry
    /// - Parameters:
    ///   - message: Error message to display
    ///   - date: Display date (defaults to now)
    /// - Returns: Error timeline entry
    static func error(_ message: String, date: Date = Date()) -> VestaWidgetEntry {
        return VestaWidgetEntry(
            date: date,
            content: nil,
            isConfigured: true,
            errorMessage: message
        )
    }

    /// Creates a content entry
    /// - Parameters:
    ///   - content: Vestaboard content to display
    ///   - date: Display date (defaults to now)
    /// - Returns: Content timeline entry
    static func content(_ content: VestaboardContent, date: Date = Date()) -> VestaWidgetEntry {
        return VestaWidgetEntry(
            date: date,
            content: content,
            isConfigured: true,
            errorMessage: nil
        )
    }
}

// MARK: - Sample Data

extension VestaWidgetEntry {
    /// Sample entry for widget previews
    static let sample = VestaWidgetEntry(
        date: Date(),
        content: .sample,
        isConfigured: true,
        errorMessage: nil
    )

    /// Sample placeholder entry
    static let samplePlaceholder = VestaWidgetEntry.placeholder()

    /// Sample error entry
    static let sampleError = VestaWidgetEntry.error("Connection failed")
}
