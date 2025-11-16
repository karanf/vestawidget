//
//  SmallWidget.swift
//  VestaWidgets
//
//  Small widget implementation (displays first 2 rows of Vestaboard)
//  Compact view for limited home screen space
//

import SwiftUI
import WidgetKit

/// Small-sized Vestaboard widget
/// Displays the first 2 rows of Vestaboard content
struct SmallVestaWidget: Widget {

    // MARK: - Properties

    let kind: String = "SmallVestaWidget"

    // MARK: - Body

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: VestaWidgetTimelineProvider()
        ) { entry in
            SmallVestaWidgetView(entry: entry)
        }
        .configurationDisplayName("Vestaboard Small")
        .description("Shows the first 2 rows of your Vestaboard")
        .supportedFamilies([.systemSmall])
    }
}

/// View for small widget
struct SmallVestaWidgetView: View {

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
                        rowsToShow: 2,
                        showTimestamp: true
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

struct SmallVestaWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Content state
            SmallVestaWidgetView(entry: .sample)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDisplayName("Content")

            // Placeholder state
            SmallVestaWidgetView(entry: .samplePlaceholder)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDisplayName("Placeholder")

            // Error state
            SmallVestaWidgetView(entry: .sampleError)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDisplayName("Error")

            // Empty content
            SmallVestaWidgetView(entry: VestaWidgetEntry.content(.blank))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDisplayName("Empty")
        }
    }
}
