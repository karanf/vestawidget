//
//  MediumWidget.swift
//  VestaWidgets
//
//  Medium widget implementation (displays first 4 rows of Vestaboard)
//  Balanced view showing more content than small widget
//

import SwiftUI
import WidgetKit

/// Medium-sized Vestaboard widget
/// Displays the first 4 rows of Vestaboard content
struct MediumVestaWidget: Widget {

    // MARK: - Properties

    let kind: String = "MediumVestaWidget"

    // MARK: - Body

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: VestaWidgetTimelineProvider()
        ) { entry in
            MediumVestaWidgetView(entry: entry)
        }
        .configurationDisplayName("Vestaboard Medium")
        .description("Shows the first 4 rows of your Vestaboard")
        .supportedFamilies([.systemMedium])
    }
}

/// View for medium widget
struct MediumVestaWidgetView: View {

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
                    VestaboardDisplayView(
                        content: content,
                        rowsToShow: 4,
                        showTimestamp: true,
                        carouselIndicator: entry.carouselIndicator
                    )
                }
            } else {
                // Loading state
                WidgetLoadingView()
            }
        }
    }
}

// MARK: - Previews

struct MediumVestaWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Content state
            MediumVestaWidgetView(entry: .sample)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .previewDisplayName("Content")

            // Placeholder state
            MediumVestaWidgetView(entry: .samplePlaceholder)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .previewDisplayName("Placeholder")

            // Error state
            MediumVestaWidgetView(entry: .sampleError)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .previewDisplayName("Error")

            // With colors
            MediumVestaWidgetView(entry: VestaWidgetEntry.content(.sampleWithColors))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .previewDisplayName("With Colors")

            // Mixed content
            MediumVestaWidgetView(entry: VestaWidgetEntry.content(.sampleMixed))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .previewDisplayName("Mixed Content")
        }
    }
}
