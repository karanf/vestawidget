//
//  LargeWidget.swift
//  VestaWidgets
//
//  Large widget implementation (displays all 6 rows of Vestaboard)
//  Full board view showing complete Vestaboard content
//

import SwiftUI
import WidgetKit

/// Large-sized Vestaboard widget
/// Displays all 6 rows of Vestaboard content
struct LargeVestaWidget: Widget {

    // MARK: - Properties

    let kind: String = "LargeVestaWidget"

    // MARK: - Body

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: VestaWidgetTimelineProvider()
        ) { entry in
            LargeVestaWidgetView(entry: entry)
        }
        .configurationDisplayName("Vestaboard Large")
        .description("Shows all 6 rows of your Vestaboard")
        .supportedFamilies([.systemLarge])
    }
}

/// View for large widget
struct LargeVestaWidgetView: View {

    // MARK: - Properties

    let entry: VestaWidgetEntry

    // MARK: - Environment

    @Environment(\.widgetFamily) var family

    // MARK: - Body

    var body: some View {
        Group {
            if entry.isPlaceholder {
                // Unconfigured state
                PlaceholderView()
            } else if let errorMessage = entry.errorMessage {
                // Error state
                WidgetErrorView(message: errorMessage)
            } else if let content = entry.content {
                // Content state
                if content.isEmpty {
                    EmptyContentView()
                } else {
                    VStack(spacing: 0) {
                        // Status bar (optional)
                        statusBar

                        // Full Vestaboard display (all 6 rows)
                        VestaboardDisplayView(
                            content: content,
                            rowsToShow: 6,
                            showTimestamp: true,
                            carouselIndicator: entry.carouselIndicator
                        )
                    }
                }
            } else {
                // Loading state
                WidgetLoadingView()
            }
        }
    }

    // MARK: - View Components

    /// Status bar showing connection info
    private var statusBar: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color.green)
                .frame(width: 6, height: 6)

            Text("Connected")
                .font(.caption2)
                .foregroundColor(.secondary)

            Spacer()

            if let lastSync = AppGroupStorage.shared.retrieveLastSync() {
                Text("Synced \(lastSync, style: .relative)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(UIColor.systemBackground).opacity(0.95))
    }
}

// MARK: - Previews

struct LargeVestaWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Content state
            LargeVestaWidgetView(entry: .sample)
                .previewContext(WidgetPreviewContext(family: .systemLarge))
                .previewDisplayName("Content")

            // Placeholder state
            LargeVestaWidgetView(entry: .samplePlaceholder)
                .previewContext(WidgetPreviewContext(family: .systemLarge))
                .previewDisplayName("Placeholder")

            // Error state
            LargeVestaWidgetView(entry: .sampleError)
                .previewContext(WidgetPreviewContext(family: .systemLarge))
                .previewDisplayName("Error")

            // With colors
            LargeVestaWidgetView(entry: VestaWidgetEntry.content(.sampleWithColors))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
                .previewDisplayName("With Colors")

            // Mixed content
            LargeVestaWidgetView(entry: VestaWidgetEntry.content(.sampleMixed))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
                .previewDisplayName("Mixed Content")

            // Empty
            LargeVestaWidgetView(entry: VestaWidgetEntry.content(.blank))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
                .previewDisplayName("Empty")
        }
    }
}
