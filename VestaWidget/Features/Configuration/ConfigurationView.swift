//
//  ConfigurationView.swift
//  VestaWidget
//
//  SwiftUI view for configuring Vestaboard API credentials
//  Provides input fields, validation, and connection testing
//

import SwiftUI

/// Main configuration view for entering and testing Vestaboard credentials
struct ConfigurationView: View {

    // MARK: - Properties

    @StateObject private var viewModel = ConfigurationViewModel()
    @Environment(\.dismiss) private var dismiss

    /// Whether to show configuration as a sheet (vs. full screen)
    var isSheet: Bool = false

    // MARK: - Body

    var body: some View {
        NavigationView {
            Form {
                // Status Section
                if viewModel.isConfigured {
                    statusSection
                }

                // Credentials Section
                credentialsSection

                // Actions Section
                actionsSection

                // Messages Section
                if viewModel.errorMessage != nil || viewModel.successMessage != nil {
                    messagesSection
                }

                // Help Section
                helpSection
            }
            .navigationTitle("Configuration")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if isSheet && viewModel.isConfigured {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
            }
            .onAppear {
                viewModel.loadConfiguration()
            }
        }
    }

    // MARK: - View Components

    /// Status display section
    private var statusSection: some View {
        Section(header: Text("Connection Status")) {
            HStack {
                Circle()
                    .fill(statusColor)
                    .frame(width: 12, height: 12)

                Text(viewModel.connectionStatus.description)
                    .font(.body)

                Spacer()

                if viewModel.connectionStatus == .testing {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }

            if let lastValidated = viewModel.lastValidated {
                HStack {
                    Text("Last Validated")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(lastValidated.relativeTimeString)
                        .foregroundColor(.secondary)
                }
            }

            Button(action: {
                Task {
                    await viewModel.checkStatus()
                }
            }) {
                Label("Refresh Status", systemImage: "arrow.clockwise")
            }
            .disabled(viewModel.isLoading)
        }
    }

    /// Credentials input section
    private var credentialsSection: some View {
        Section(header: Text("API Credentials")) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Read/Write API Key")
                    .font(.caption)
                    .foregroundColor(.secondary)

                SecureField("Enter API Key", text: $viewModel.apiKey)
                    .textContentType(.password)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textFieldStyle(.roundedBorder)
            }
            .padding(.vertical, 4)

            VStack(alignment: .leading, spacing: 8) {
                Text("Read/Write API Secret")
                    .font(.caption)
                    .foregroundColor(.secondary)

                SecureField("Enter API Secret", text: $viewModel.apiSecret)
                    .textContentType(.password)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textFieldStyle(.roundedBorder)
            }
            .padding(.vertical, 4)
        }
    }

    /// Actions section with buttons
    private var actionsSection: some View {
        Section {
            if viewModel.isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Text("Please wait...")
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding()
            } else {
                // Test Connection Button
                Button(action: {
                    Task {
                        await viewModel.testConnection()
                    }
                }) {
                    Label("Test Connection", systemImage: "network")
                        .frame(maxWidth: .infinity)
                }
                .disabled(viewModel.apiKey.isEmpty || viewModel.apiSecret.isEmpty)
                .buttonStyle(.bordered)

                // Save Configuration Button
                Button(action: {
                    Task {
                        await viewModel.saveConfiguration()
                    }
                }) {
                    Label(
                        viewModel.isConfigured ? "Update Configuration" : "Save Configuration",
                        systemImage: "checkmark.circle.fill"
                    )
                    .frame(maxWidth: .infinity)
                }
                .disabled(viewModel.apiKey.isEmpty || viewModel.apiSecret.isEmpty)
                .buttonStyle(.borderedProminent)

                // Clear Configuration Button
                if viewModel.isConfigured {
                    Button(role: .destructive, action: {
                        viewModel.clearConfiguration()
                    }) {
                        Label("Clear Configuration", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
    }

    /// Messages section for errors and success
    private var messagesSection: some View {
        Section {
            if let error = viewModel.errorMessage {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text(error)
                        .font(.callout)
                        .foregroundColor(.red)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.vertical, 8)
            }

            if let success = viewModel.successMessage {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text(success)
                        .font(.callout)
                        .foregroundColor(.green)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.vertical, 8)
            }
        }
    }

    /// Help and information section
    private var helpSection: some View {
        Section(header: Text("Help")) {
            VStack(alignment: .leading, spacing: 12) {
                Label {
                    Text("You need a Vestaboard Read/Write API subscription to use this app.")
                        .font(.callout)
                        .foregroundColor(.secondary)
                } icon: {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                }

                Divider()

                Text("To get your API credentials:")
                    .font(.callout)
                    .fontWeight(.semibold)

                VStack(alignment: .leading, spacing: 8) {
                    Text("1. Visit vestaboard.com")
                    Text("2. Log in to your account")
                    Text("3. Go to Settings → API")
                    Text("4. Enable Read/Write API")
                    Text("5. Copy your credentials here")
                }
                .font(.callout)
                .foregroundColor(.secondary)

                Divider()

                Link(destination: URL(string: "https://www.vestaboard.com")!) {
                    Label("Visit Vestaboard.com", systemImage: "safari")
                        .font(.callout)
                }
            }
            .padding(.vertical, 8)
        }
    }

    // MARK: - Computed Properties

    /// Color for connection status indicator
    private var statusColor: Color {
        switch viewModel.connectionStatus {
        case .notConfigured:
            return .gray
        case .testing:
            return .blue
        case .connected:
            return .green
        case .disconnected:
            return .orange
        case .error:
            return .red
        }
    }
}

// MARK: - Previews

struct ConfigurationView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Not configured
            ConfigurationView()
                .preferredColorScheme(.light)

            // Configured
            ConfigurationView()
                .preferredColorScheme(.dark)
        }
    }
}
