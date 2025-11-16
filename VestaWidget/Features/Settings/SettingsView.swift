//
//  SettingsView.swift
//  VestaWidget
//
//  SwiftUI view for app settings and information
//  Provides access to configuration, app info, and help resources
//

import SwiftUI

/// Main settings view for the app
struct SettingsView: View {

    // MARK: - Properties

    @State private var showingConfiguration = false
    @State private var showingAbout = false

    // MARK: - Body

    var body: some View {
        NavigationView {
            List {
                // Configuration Section
                configurationSection

                // Widget Section
                widgetSection

                // About Section
                aboutSection

                // Help & Support Section
                helpSection
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingConfiguration) {
                ConfigurationView(isSheet: true)
            }
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
        }
    }

    // MARK: - View Components

    /// Configuration section
    private var configurationSection: some View {
        Section(header: Text("Vestaboard Configuration")) {
            Button(action: {
                showingConfiguration = true
            }) {
                HStack {
                    Label("API Credentials", systemImage: "key.fill")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            NavigationLink(destination: ConfigurationView()) {
                Label("Connection Settings", systemImage: "network")
            }
        }
    }

    /// Widget section
    private var widgetSection: some View {
        Section(header: Text("Widgets"), footer: Text("Add VestaWidget to your home screen to see your Vestaboard content at a glance.")) {
            HStack {
                Label("Available Sizes", systemImage: "square.grid.3x3")
                Spacer()
                Text("Small, Medium, Large")
                    .foregroundColor(.secondary)
            }

            HStack {
                Label("Update Frequency", systemImage: "clock")
                Spacer()
                Text("Every 15 minutes")
                    .foregroundColor(.secondary)
            }

            Link(destination: URL(string: "https://support.apple.com/en-us/HT207122")!) {
                Label("How to Add Widgets", systemImage: "questionmark.circle")
            }
        }
    }

    /// About section
    private var aboutSection: some View {
        Section(header: Text("About")) {
            Button(action: {
                showingAbout = true
            }) {
                HStack {
                    Label("About VestaWidget", systemImage: "info.circle")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            HStack {
                Label("Version", systemImage: "number")
                Spacer()
                Text(Bundle.main.fullVersion)
                    .foregroundColor(.secondary)
            }
        }
    }

    /// Help and support section
    private var helpSection: some View {
        Section(header: Text("Help & Support")) {
            Link(destination: URL(string: "https://www.vestaboard.com")!) {
                Label("Vestaboard Website", systemImage: "safari")
            }

            Link(destination: URL(string: "https://docs.vestaboard.com")!) {
                Label("API Documentation", systemImage: "doc.text")
            }

            Link(destination: URL(string: "https://docs.vestaboard.com/character-codes")!) {
                Label("Supported Characters", systemImage: "textformat")
            }

            Link(destination: URL(string: "mailto:support@vestaboard.com")!) {
                Label("Contact Support", systemImage: "envelope")
            }
        }
    }
}

// MARK: - About View

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // App Icon Placeholder
                    Image(systemName: "square.grid.3x2.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                        .padding(.top, 40)

                    // App Name and Version
                    VStack(spacing: 8) {
                        Text("VestaWidget")
                            .font(.title)
                            .fontWeight(.bold)

                        Text("Version \(Bundle.main.fullVersion)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Divider()
                        .padding(.horizontal)

                    // Description
                    VStack(alignment: .leading, spacing: 16) {
                        Text("About VestaWidget")
                            .font(.headline)

                        Text("VestaWidget brings your Vestaboard to your iOS home screen. View your Vestaboard content and post new messages directly from your iPhone or iPad.")
                            .font(.body)
                            .foregroundColor(.secondary)

                        Text("Features")
                            .font(.headline)
                            .padding(.top, 8)

                        VStack(alignment: .leading, spacing: 12) {
                            FeatureRow(icon: "square.grid.3x3", title: "Three Widget Sizes", description: "Small, Medium, and Large")
                            FeatureRow(icon: "arrow.clockwise", title: "Auto-Refresh", description: "Updates every 15 minutes")
                            FeatureRow(icon: "paperplane", title: "Post Messages", description: "Send messages from your device")
                            FeatureRow(icon: "doc.text", title: "Templates", description: "Save and reuse common messages")
                        }

                        Text("Requirements")
                            .font(.headline)
                            .padding(.top, 8)

                        Text("• iOS 14.0 or later\n• Vestaboard Read/Write API subscription\n• Active internet connection")
                            .font(.body)
                            .foregroundColor(.secondary)

                        Divider()
                            .padding(.vertical, 8)

                        Text("Made with ❤️ for Vestaboard users")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .padding(.horizontal, 24)

                    Spacer(minLength: 40)
                }
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Feature Row

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Previews

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SettingsView()
            AboutView()
        }
    }
}
