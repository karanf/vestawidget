//
//  MessageHistoryView.swift
//  VestaWidget
//
//  SwiftUI view displaying history of sent messages
//  Allows viewing, reloading, and resending previous messages
//

import SwiftUI

/// View displaying message history
struct MessageHistoryView: View {

    // MARK: - Properties

    @ObservedObject var viewModel: MessageComposerViewModel
    @Environment(\.dismiss) private var dismiss

    // MARK: - Body

    var body: some View {
        NavigationView {
            List {
                if viewModel.messageHistory.isEmpty {
                    emptyState
                } else {
                    ForEach(viewModel.messageHistory) { message in
                        MessageHistoryRow(message: message) {
                            viewModel.loadMessage(message)
                            dismiss()
                        } onResend: {
                            Task {
                                await viewModel.resendMessage(message)
                                dismiss()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Message History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }

                if !viewModel.messageHistory.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(role: .destructive, action: {
                            viewModel.clearHistory()
                        }) {
                            Label("Clear", systemImage: "trash")
                        }
                    }
                }
            }
            .onAppear {
                viewModel.loadHistory()
            }
        }
    }

    // MARK: - View Components

    /// Empty state when no history exists
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.badge.questionmark")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text("No Message History")
                .font(.title3)
                .fontWeight(.semibold)

            Text("Messages you send will appear here")
                .font(.callout)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Message History Row

/// Individual row in message history list
struct MessageHistoryRow: View {
    let message: VestaboardMessage
    let onLoad: () -> Void
    let onResend: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Status and timestamp
            HStack {
                statusBadge
                Spacer()
                Text(message.timestamp.shortDateTimeString)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Message text
            Text(message.text)
                .font(.body)
                .lineLimit(3)

            // Error message if failed
            if let error = message.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .italic()
            }

            // Action buttons
            HStack(spacing: 12) {
                Button(action: onLoad) {
                    Label("Load", systemImage: "square.and.pencil")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)

                if message.status == .failed {
                    Button(action: onResend) {
                        Label("Retry", systemImage: "arrow.clockwise")
                            .font(.caption)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 8)
    }

    /// Status badge view
    private var statusBadge: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)

            Text(statusText)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(statusColor)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(statusColor.opacity(0.15))
        .cornerRadius(12)
    }

    private var statusColor: Color {
        switch message.status {
        case .sent:
            return .green
        case .failed:
            return .red
        case .sending:
            return .blue
        case .draft:
            return .orange
        }
    }

    private var statusText: String {
        switch message.status {
        case .sent:
            return "Sent"
        case .failed:
            return "Failed"
        case .sending:
            return "Sending"
        case .draft:
            return "Draft"
        }
    }
}

// MARK: - Previews

struct MessageHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        MessageHistoryView(viewModel: MessageComposerViewModel())
    }
}
