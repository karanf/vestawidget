//
//  ErrorView.swift
//  VestaWidgets
//
//  Error view displayed when widget encounters an error
//  Shows error message and instructions for resolution
//

import SwiftUI
import WidgetKit

/// Error view for widget error states
struct WidgetErrorView: View {

    // MARK: - Properties

    /// Error message to display
    let message: String

    // MARK: - Body

    var body: some View {
        VStack(spacing: 12) {
            // Error icon
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 32))
                .foregroundColor(.orange)

            // Error title
            Text("Unable to Load")
                .font(.headline)
                .fontWeight(.semibold)

            // Error message
            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(4)

            Spacer()
                .frame(height: 8)

            // Action hint
            Label("Tap to open app", systemImage: "arrow.right.circle")
                .font(.caption2)
                .foregroundColor(.blue)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground))
        .widgetURL(URL(string: AppConstants.appURLScheme + "://open"))
    }
}

// MARK: - Loading View

/// Loading view displayed while fetching content
struct WidgetLoadingView: View {

    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)

            Text("Loading...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground))
    }
}

// MARK: - Empty Content View

/// View displayed when Vestaboard has no content
struct EmptyContentView: View {

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "square.dashed")
                .font(.system(size: 32))
                .foregroundColor(.secondary)

            Text("No Content")
                .font(.headline)
                .foregroundColor(.secondary)

            Text("Your Vestaboard is empty")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground))
        .widgetURL(URL(string: AppConstants.composerURL))
    }
}

// MARK: - Previews

struct WidgetErrorView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WidgetErrorView(message: "Network connection failed")
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDisplayName("Error - Small")

            WidgetErrorView(message: "Invalid API credentials. Please reconfigure in app.")
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .previewDisplayName("Error - Medium")

            WidgetLoadingView()
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDisplayName("Loading")

            EmptyContentView()
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .previewDisplayName("Empty")
        }
    }
}
