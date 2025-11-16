//
//  VestaboardDisplayView.swift
//  VestaWidgets
//
//  Reusable SwiftUI view for displaying Vestaboard content in widgets
//  Renders character grid with Vestaboard styling and colors
//

import SwiftUI
import WidgetKit

/// Displays Vestaboard content in widget-friendly format
/// Supports displaying subset of rows for different widget sizes
struct VestaboardDisplayView: View {

    // MARK: - Properties

    /// Vestaboard content to display
    let content: VestaboardContent

    /// Number of rows to display (1-6)
    let rowsToShow: Int

    /// Whether to show the timestamp
    let showTimestamp: Bool

    /// Optional carousel indicator text (e.g., "Message 3 of 10")
    let carouselIndicator: String?

    // MARK: - Initialization

    /// Creates a Vestaboard display view
    /// - Parameters:
    ///   - content: Content to display
    ///   - rowsToShow: Number of rows to show (default: all 6)
    ///   - showTimestamp: Whether to show last update time (default: true)
    ///   - carouselIndicator: Optional carousel indicator text
    init(
        content: VestaboardContent,
        rowsToShow: Int = 6,
        showTimestamp: Bool = true,
        carouselIndicator: String? = nil
    ) {
        self.content = content
        self.rowsToShow = min(rowsToShow, AppConstants.vestaboardRows)
        self.showTimestamp = showTimestamp
        self.carouselIndicator = carouselIndicator
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            // Vestaboard grid
            boardView
                .padding(8)

            // Timestamp footer
            if showTimestamp {
                timestampView
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)
            }
        }
        .background(Color.vestaboardBlack)
        .widgetURL(URL(string: AppConstants.appURLScheme + "://open"))
    }

    // MARK: - View Components

    /// Vestaboard character grid
    private var boardView: some View {
        VStack(spacing: 2) {
            ForEach(0..<rowsToShow, id: \.self) { rowIndex in
                HStack(spacing: 1) {
                    ForEach(0..<AppConstants.vestaboardColumns, id: \.self) { colIndex in
                        CharacterCell(code: content.rows[rowIndex][colIndex])
                    }
                }
            }
        }
    }

    /// Timestamp display with optional carousel indicator
    private var timestampView: some View {
        HStack {
            // Carousel indicator (if present)
            if let indicator = carouselIndicator, !indicator.isEmpty {
                Image(systemName: "arrow.left.arrow.right.circle")
                    .font(.caption2)

                Text(indicator)
                    .font(.caption2)
                    .fontWeight(.medium)

                Spacer()
            }

            // Timestamp
            Image(systemName: "clock")
                .font(.caption2)

            Text(content.lastUpdated, style: .relative)
                .font(.caption2)

            if carouselIndicator == nil {
                Spacer()
            }
        }
        .foregroundColor(.white.opacity(0.7))
    }
}

/// Individual character cell in the Vestaboard display
struct CharacterCell: View {

    // MARK: - Properties

    let code: Int

    // MARK: - Body

    var body: some View {
        ZStack {
            // Background (black or color)
            backgroundColor

            // Character text (if not a color block)
            if !VestaboardCharacterSet.isColorCode(code) {
                Text(character)
                    .font(.system(size: fontSize, weight: .semibold, design: .monospaced))
                    .foregroundColor(Color.vestaboardCharacter)
                    .minimumScaleFactor(0.5)
            }
        }
        .aspectRatio(0.8, contentMode: .fit)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .cornerRadius(1)
    }

    // MARK: - Computed Properties

    /// Character to display
    private var character: String {
        return String(VestaboardCharacterSet.character(for: code))
    }

    /// Background color for the cell
    private var backgroundColor: Color {
        if VestaboardCharacterSet.isColorCode(code) {
            return Color.vestaboardColor(for: code)
        }
        return Color.vestaboardBlack.opacity(0.3)
    }

    /// Dynamic font size (will scale based on available space)
    private var fontSize: CGFloat {
        #if os(iOS)
        return 7
        #else
        return 10
        #endif
    }
}

// MARK: - Previews

struct VestaboardDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Full board
            VestaboardDisplayView(content: .sample, rowsToShow: 6)
                .previewContext(WidgetPreviewContext(family: .systemLarge))

            // Partial board (2 rows)
            VestaboardDisplayView(content: .sample, rowsToShow: 2)
                .previewContext(WidgetPreviewContext(family: .systemSmall))

            // With colors
            VestaboardDisplayView(content: .sampleWithColors, rowsToShow: 4)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}
