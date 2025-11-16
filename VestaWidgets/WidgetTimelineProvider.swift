//
//  WidgetTimelineProvider.swift
//  VestaWidgets
//
//  Timeline provider for VestaWidget widgets
//  Generates timeline entries for widget updates and handles content fetching
//

import Foundation
import WidgetKit

/// Timeline provider for all VestaWidget widget sizes
/// Implements WidgetKit's TimelineProvider protocol to supply widget entries
struct VestaWidgetTimelineProvider: TimelineProvider {

    // MARK: - Dependencies

    private let api = VestaboardAPI()
    private let keychain = KeychainService.shared
    private let storage = AppGroupStorage.shared

    // MARK: - TimelineProvider Protocol

    /// Provides a placeholder entry for widget gallery
    /// - Parameter context: Widget context
    /// - Returns: Placeholder timeline entry
    func placeholder(in context: Context) -> VestaWidgetEntry {
        return VestaWidgetEntry.placeholder()
    }

    /// Provides a snapshot entry for widget gallery or quick display
    /// - Parameters:
    ///   - context: Widget context
    ///   - completion: Completion handler with entry
    func getSnapshot(in context: Context, completion: @escaping (VestaWidgetEntry) -> Void) {
        let entry: VestaWidgetEntry

        if context.isPreview {
            // Use sample data for widget gallery preview
            entry = VestaWidgetEntry.sample
        } else {
            // Use real data from App Group storage
            entry = fetchCurrentEntry()
        }

        completion(entry)
    }

    /// Generates a timeline of entries for widget updates
    /// - Parameters:
    ///   - context: Widget context
    ///   - completion: Completion handler with timeline
    func getTimeline(in context: Context, completion: @escaping (Timeline<VestaWidgetEntry>) -> Void) {
        Task {
            let entries = await generateTimelineEntries()

            // Create timeline with policy to reload at end
            // iOS will request a new timeline when all entries are used
            let timeline = Timeline(entries: entries, policy: .atEnd)

            completion(timeline)
        }
    }

    // MARK: - Private Methods

    /// Fetches current entry from App Group storage
    /// - Returns: Timeline entry with stored content or appropriate state
    private func fetchCurrentEntry() -> VestaWidgetEntry {
        // Check if configured
        let isConfigured = keychain.hasConfiguration()

        guard isConfigured else {
            return VestaWidgetEntry.placeholder()
        }

        // Try to get cached content from App Group
        if let content = storage.retrieveContent() {
            return VestaWidgetEntry.content(content)
        } else {
            // No content available yet
            return VestaWidgetEntry(
                date: Date(),
                content: nil,
                isConfigured: true,
                errorMessage: "Loading..."
            )
        }
    }

    /// Generates timeline entries for the next 24 hours
    /// With carousel support: rotates through recent messages if multiple exist
    /// - Returns: Array of timeline entries
    private func generateTimelineEntries() async -> [VestaWidgetEntry] {
        var entries: [VestaWidgetEntry] = []
        let currentDate = Date()

        // Check if app is configured
        guard keychain.hasConfiguration() else {
            // Return single placeholder entry
            return [VestaWidgetEntry.placeholder(date: currentDate)]
        }

        // Try to fetch latest content from API
        do {
            let config = try keychain.retrieve()

            // Fetch current Vestaboard content
            let content = try await api.getCurrentMessage(
                apiKey: config.apiKey,
                apiSecret: config.apiSecret
            )

            // Save to App Group for other widgets and app
            try storage.saveContent(content)
            storage.saveLastSync(Date())

            // Retrieve message history for carousel
            let history = storage.retrieveHistory()

            // Generate carousel entries if multiple messages exist
            if history.count > 1, let carousel = MessageCarouselEntry.from(history: history, maxMessages: 10) {
                // Create rotating carousel entries
                entries = generateCarouselEntries(carousel: carousel, startDate: currentDate)
            } else {
                // Single message or no history - use standard entries
                // Generate entries for next 24 hours (96 entries at 15-minute intervals)
                for index in 0..<AppConstants.timelineEntryCount {
                    let entryDate = Calendar.current.date(
                        byAdding: .minute,
                        value: index * 15,
                        to: currentDate
                    ) ?? currentDate

                    entries.append(VestaWidgetEntry.content(content, date: entryDate))
                }
            }

        } catch APIError.unauthorized {
            // Invalid credentials - prompt user to reconfigure
            let entry = VestaWidgetEntry.error(
                "Invalid credentials. Please reconfigure in app.",
                date: currentDate
            )
            entries.append(entry)

        } catch APIError.rateLimited {
            // Rate limited - use cached content if available
            if let cachedContent = storage.retrieveContent() {
                // Create entries with cached content
                for index in 0..<AppConstants.timelineEntryCount {
                    let entryDate = Calendar.current.date(
                        byAdding: .minute,
                        value: index * 15,
                        to: currentDate
                    ) ?? currentDate

                    entries.append(VestaWidgetEntry.content(cachedContent, date: entryDate))
                }
            } else {
                let entry = VestaWidgetEntry.error(
                    "Rate limited. Try again later.",
                    date: currentDate
                )
                entries.append(entry)
            }

        } catch {
            // Other errors - try to use cached content
            if let cachedContent = storage.retrieveContent() {
                // Use cached content but show it's not current
                let entry = VestaWidgetEntry(
                    date: currentDate,
                    content: cachedContent,
                    isConfigured: true,
                    errorMessage: nil  // Don't show error if we have cached content
                )
                entries.append(entry)

                // Add more entries with same cached content
                for index in 1..<min(24, AppConstants.timelineEntryCount) {
                    let entryDate = Calendar.current.date(
                        byAdding: .minute,
                        value: index * 15,
                        to: currentDate
                    ) ?? currentDate

                    entries.append(VestaWidgetEntry.content(cachedContent, date: entryDate))
                }
            } else {
                // No cached content available
                let entry = VestaWidgetEntry.error(
                    error.userFriendlyMessage,
                    date: currentDate
                )
                entries.append(entry)
            }
        }

        // Ensure we have at least one entry
        if entries.isEmpty {
            entries.append(VestaWidgetEntry.placeholder(date: currentDate))
        }

        return entries
    }

    /// Generates carousel timeline entries that rotate through messages
    /// Creates 96 entries (24 hours) that cycle through the carousel messages
    /// - Parameters:
    ///   - carousel: Carousel with messages to rotate through
    ///   - startDate: Starting date for timeline
    /// - Returns: Array of carousel timeline entries
    private func generateCarouselEntries(carousel: MessageCarouselEntry, startDate: Date) -> [VestaWidgetEntry] {
        var entries: [VestaWidgetEntry] = []
        let totalMessages = carousel.totalMessages

        // Generate 96 entries (24 hours / 15 minutes)
        for index in 0..<AppConstants.timelineEntryCount {
            let entryDate = Calendar.current.date(
                byAdding: .minute,
                value: index * 15,
                to: startDate
            ) ?? startDate

            // Rotate through messages: each message gets shown multiple times
            // Example: With 3 messages and 96 entries, each message shows ~32 times
            let messageIndex = index % totalMessages
            let carouselAtIndex = carousel.goTo(index: messageIndex)

            entries.append(VestaWidgetEntry.carousel(carouselAtIndex, date: entryDate))
        }

        return entries
    }
}

// MARK: - Intent Configuration (Optional)

/// Intent configuration for widget customization
/// This is optional but allows users to configure widget-specific settings
/// Uncomment and implement if you want configurable widgets
/*
struct VestaWidgetIntentTimelineProvider: IntentTimelineProvider {

    typealias Entry = VestaWidgetEntry
    typealias Intent = VestaWidgetConfigurationIntent

    private let baseProvider = VestaWidgetTimelineProvider()

    func placeholder(in context: Context) -> VestaWidgetEntry {
        baseProvider.placeholder(in: context)
    }

    func getSnapshot(for configuration: Intent, in context: Context, completion: @escaping (VestaWidgetEntry) -> Void) {
        baseProvider.getSnapshot(in: context, completion: completion)
    }

    func getTimeline(for configuration: Intent, in context: Context, completion: @escaping (Timeline<VestaWidgetEntry>) -> Void) {
        baseProvider.getTimeline(in: context, completion: completion)
    }

    func recommendations() -> [IntentRecommendation<Intent>] {
        // Provide recommendations for Siri suggestions
        return []
    }
}
*/
