//
//  VestaWidgetBundle.swift
//  VestaWidgets
//
//  Widget bundle that groups all VestaWidget sizes together
//  Main entry point for the widget extension
//

import SwiftUI
import WidgetKit

/// Main widget bundle containing all VestaWidget sizes
/// This is the entry point for the widget extension
@main
struct VestaWidgetBundle: WidgetBundle {

    // MARK: - Body

    var body: some Widget {
        // Include all three widget sizes
        SmallVestaWidget()
        MediumVestaWidget()
        LargeVestaWidget()
    }
}

// MARK: - Widget Bundle Info

/*
 VestaWidgetBundle Configuration:

 This widget bundle provides three sizes of Vestaboard widgets:

 1. Small Widget (systemSmall)
    - Displays first 2 rows of Vestaboard
    - Compact view for limited space
    - Perfect for quick glances

 2. Medium Widget (systemMedium)
    - Displays first 4 rows of Vestaboard
    - Balanced view with more context
    - Good compromise between space and content

 3. Large Widget (systemLarge)
    - Displays all 6 rows of Vestaboard
    - Full board representation
    - Complete view of Vestaboard content

 All widgets:
 - Auto-refresh every 15 minutes
 - Share data via App Group
 - Support light and dark mode
 - Tap to open main app
 - Show placeholder when unconfigured
 - Display errors gracefully

 Timeline Updates:
 - Generated for 24 hours (96 entries at 15-minute intervals)
 - Fetches latest content from Vestaboard API
 - Caches content in App Group storage
 - Falls back to cached content on errors

 Configuration Requirements:
 - App Group: group.com.vestawidget.shared
 - Keychain Access Group: com.vestawidget.shared
 - Network permissions for API access
 - Background refresh capability
 */
