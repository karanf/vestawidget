//
//  PlaceholderView.swift
//  VestaWidgets
//
//  Placeholder view displayed when widget is not yet configured
//  Shows instructions to configure the app
//

import SwiftUI
import WidgetKit

/// Placeholder view for unconfigured widgets
struct PlaceholderView: View {

    // MARK: - Body

    var body: some View {
        VStack(spacing: 12) {
            // Icon
            Image(systemName: "square.grid.3x2")
                .font(.system(size: 40))
                .foregroundColor(.blue)

            // Title
            Text("VestaWidget")
                .font(.headline)
                .fontWeight(.bold)

            // Instructions
            Text("Configure in app to get started")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Spacer()
                .frame(height: 8)

            // Action hint
            Label("Tap to configure", systemImage: "hand.tap")
                .font(.caption2)
                .foregroundColor(.blue)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground))
        .widgetURL(URL(string: AppConstants.configurationURL))
    }
}

// MARK: - Previews

struct PlaceholderView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PlaceholderView()
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDisplayName("Small")

            PlaceholderView()
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .previewDisplayName("Medium")

            PlaceholderView()
                .previewContext(WidgetPreviewContext(family: .systemLarge))
                .previewDisplayName("Large")
        }
    }
}
