//
//  VestaWidgetApp.swift
//  VestaWidget
//
//  Main app entry point for VestaWidget
//  Initializes the app and handles lifecycle events
//

import SwiftUI
import WidgetKit

/// Main app structure - entry point for VestaWidget
@main
struct VestaWidgetApp: App {

    // MARK: - Properties

    @StateObject private var networkMonitor = NetworkMonitor.shared

    // MARK: - Initialization

    init() {
        // Perform any necessary setup
        configureAppearance()
    }

    // MARK: - Scene

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(networkMonitor)
                .onOpenURL { url in
                    handleDeepLink(url)
                }
        }
    }

    // MARK: - Private Methods

    /// Configures global app appearance
    private func configureAppearance() {
        // You can customize navigation bar appearance here if needed
        // Example:
        // let appearance = UINavigationBarAppearance()
        // appearance.configureWithDefaultBackground()
        // UINavigationBar.appearance().standardAppearance = appearance
    }

    /// Handles deep links from widgets or other sources
    /// - Parameter url: The deep link URL to handle
    private func handleDeepLink(_ url: URL) {
        guard url.scheme == AppConstants.appURLScheme else { return }

        // Handle different deep link paths
        switch url.host {
        case "configure":
            // Open configuration screen
            // This will be handled by ContentView's state
            NotificationCenter.default.post(
                name: NSNotification.Name("OpenConfiguration"),
                object: nil
            )

        case "compose":
            // Open message composer
            NotificationCenter.default.post(
                name: NSNotification.Name("OpenComposer"),
                object: nil
            )

        default:
            break
        }
    }
}
