//
//  ContentView.swift
//  VestaWidget
//
//  Main content view with tab-based navigation
//  Provides access to message composer, configuration, and settings
//

import SwiftUI

/// Main content view with tab navigation
struct ContentView: View {

    // MARK: - State

    @State private var selectedTab = 0
    @State private var showingConfiguration = false
    @State private var isConfigured = false

    // MARK: - Initialization

    init() {
        // Check if app is configured on initialization
        _isConfigured = State(initialValue: KeychainService.shared.hasConfiguration())
    }

    // MARK: - Body

    var body: some View {
        Group {
            if isConfigured {
                mainTabView
            } else {
                onboardingView
            }
        }
        .onAppear {
            checkConfiguration()
            setupNotificationObservers()
        }
    }

    // MARK: - View Components

    /// Main tab view for configured app
    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            // Message Composer Tab
            MessageComposerView()
                .tabItem {
                    Label("Post Message", systemImage: "square.and.pencil")
                }
                .tag(0)

            // Configuration Tab
            ConfigurationView()
                .tabItem {
                    Label("Configuration", systemImage: "gear")
                }
                .tag(1)

            // Settings Tab
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "slider.horizontal.3")
                }
                .tag(2)
        }
    }

    /// Onboarding view for unconfigured app
    private var onboardingView: some View {
        NavigationView {
            VStack(spacing: 32) {
                Spacer()

                // App Icon/Logo
                Image(systemName: "square.grid.3x2.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.blue)

                // Welcome Text
                VStack(spacing: 16) {
                    Text("Welcome to VestaWidget")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    Text("Bring your Vestaboard to your iOS home screen")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                // Features
                VStack(alignment: .leading, spacing: 20) {
                    OnboardingFeature(
                        icon: "square.grid.3x3.fill",
                        title: "Home Screen Widgets",
                        description: "View your Vestaboard content at a glance"
                    )

                    OnboardingFeature(
                        icon: "paperplane.fill",
                        title: "Post Messages",
                        description: "Send messages directly from your device"
                    )

                    OnboardingFeature(
                        icon: "arrow.clockwise",
                        title: "Auto-Refresh",
                        description: "Widgets update automatically every 15 minutes"
                    )
                }
                .padding(.horizontal, 32)

                Spacer()

                // Get Started Button
                Button(action: {
                    showingConfiguration = true
                }) {
                    Text("Get Started")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingConfiguration) {
            ConfigurationView(isSheet: true)
                .onDisappear {
                    checkConfiguration()
                }
        }
    }

    // MARK: - Private Methods

    /// Checks if the app is configured
    private func checkConfiguration() {
        isConfigured = KeychainService.shared.hasConfiguration()
    }

    /// Sets up notification observers for deep links
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("OpenConfiguration"),
            object: nil,
            queue: .main
        ) { _ in
            selectedTab = 1
        }

        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("OpenComposer"),
            object: nil,
            queue: .main
        ) { _ in
            selectedTab = 0
        }
    }
}

// MARK: - Onboarding Feature Row

/// Individual feature row in onboarding view
struct OnboardingFeature: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Previews

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .preferredColorScheme(.light)

            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}
