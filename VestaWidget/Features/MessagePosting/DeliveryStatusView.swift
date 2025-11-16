//
//  DeliveryStatusView.swift
//  VestaWidget
//
//  SwiftUI view for displaying message delivery status and queue visualization
//  Shows real-time delivery progress, pending messages, and failed messages
//  Provides user actions for retry, cancel, and queue management
//

import SwiftUI

/// View displaying message delivery status and queue state
struct DeliveryStatusView: View {

    // MARK: - Properties

    /// Delivery manager to observe
    @ObservedObject var deliveryManager: MessageDeliveryManager

    /// Whether to show detailed queue list
    @State private var showQueueDetails = false

    /// Whether to show only failed messages
    @State private var showOnlyFailed = false

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            // Status header
            statusHeader

            // Queue summary
            if deliveryManager.pendingCount > 0 || deliveryManager.failedCount > 0 {
                queueSummary
                    .padding(.horizontal)
                    .padding(.vertical, 12)

                // Queue details (expandable)
                if showQueueDetails {
                    Divider()
                    queueDetailsList
                }
            }

            // Current delivery status
            if deliveryManager.isDelivering {
                Divider()
                currentDeliveryStatus
                    .padding()
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }

    // MARK: - Subviews

    /// Status header showing current state
    private var statusHeader: some View {
        HStack {
            // Status icon
            statusIcon

            VStack(alignment: .leading, spacing: 4) {
                Text(deliveryManager.queueState.description)
                    .font(.headline)

                if let statusMessage = deliveryManager.statusMessage {
                    Text(statusMessage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Toggle details button
            if deliveryManager.pendingCount > 0 || deliveryManager.failedCount > 0 {
                Button(action: {
                    withAnimation {
                        showQueueDetails.toggle()
                    }
                }) {
                    Image(systemName: showQueueDetails ? "chevron.up" : "chevron.down")
                        .foregroundColor(.accentColor)
                        .font(.caption.weight(.semibold))
                }
            }
        }
        .padding()
    }

    /// Icon representing current status
    private var statusIcon: some View {
        Group {
            switch deliveryManager.queueState {
            case .idle:
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)

            case .pending:
                Image(systemName: "clock.fill")
                    .foregroundColor(.orange)

            case .delivering:
                ProgressView()

            case .waitingForNetwork:
                Image(systemName: "wifi.slash")
                    .foregroundColor(.orange)

            case .hasFailed:
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
            }
        }
        .font(.title2)
    }

    /// Summary of queue state
    private var queueSummary: some View {
        HStack(spacing: 20) {
            // Pending count
            if deliveryManager.pendingCount > 0 {
                VStack(spacing: 4) {
                    Text("\(deliveryManager.pendingCount)")
                        .font(.title3.weight(.semibold))
                        .foregroundColor(.orange)

                    Text("Pending")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            // Failed count
            if deliveryManager.failedCount > 0 {
                VStack(spacing: 4) {
                    Text("\(deliveryManager.failedCount)")
                        .font(.title3.weight(.semibold))
                        .foregroundColor(.red)

                    Text("Failed")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                // Clear failed button
                Button(action: {
                    deliveryManager.clearFailedMessages()
                }) {
                    Text("Clear")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                }
            }

            Spacer()
        }
    }

    /// Current delivery status
    private var currentDeliveryStatus: some View {
        HStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())

            VStack(alignment: .leading, spacing: 4) {
                Text("Sending message...")
                    .font(.subheadline.weight(.medium))

                if let statusMessage = deliveryManager.statusMessage {
                    Text(statusMessage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()
        }
    }

    /// Detailed list of queued messages
    private var queueDetailsList: some View {
        VStack(spacing: 0) {
            // Filter toggle
            if deliveryManager.failedCount > 0 {
                HStack {
                    Text("Show Only Failed")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Toggle("", isOn: $showOnlyFailed)
                        .labelsHidden()

                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
            }

            // Message list
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(filteredMessages) { queuedMessage in
                        QueuedMessageRow(
                            queuedMessage: queuedMessage,
                            onRetry: {
                                deliveryManager.retryMessage(queuedMessage.id)
                            },
                            onCancel: {
                                deliveryManager.cancelMessage(queuedMessage.id)
                            }
                        )
                        Divider()
                    }
                }
            }
            .frame(maxHeight: 300)
        }
    }

    /// Filtered messages based on toggle
    private var filteredMessages: [QueuedMessage] {
        if showOnlyFailed {
            return deliveryManager.failedMessages
        } else {
            return deliveryManager.queuedMessages
        }
    }
}

// MARK: - Queued Message Row

/// Row view for a single queued message
struct QueuedMessageRow: View {

    let queuedMessage: QueuedMessage
    let onRetry: () -> Void
    let onCancel: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Status icon
            statusIcon
                .frame(width: 24, height: 24)

            // Message content
            VStack(alignment: .leading, spacing: 4) {
                Text(queuedMessage.message.text)
                    .font(.subheadline)
                    .lineLimit(2)

                HStack(spacing: 8) {
                    Text(queuedMessage.statusDescription)
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    if let lastError = queuedMessage.lastError {
                        Text("•")
                            .foregroundColor(.secondary)

                        Text(lastError)
                            .font(.caption2)
                            .foregroundColor(.red)
                            .lineLimit(1)
                    }
                }

                // Time info
                Text(queuedMessage.enqueuedDate.relativeTimeString)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Actions
            actions
        }
        .padding()
    }

    private var statusIcon: some View {
        Group {
            switch queuedMessage.status {
            case .pending:
                if queuedMessage.retryCount > 0 {
                    ZStack {
                        Circle()
                            .fill(Color.orange.opacity(0.2))
                        Image(systemName: "arrow.clockwise")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                } else {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.2))
                        Image(systemName: "clock")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }

            case .sending:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .accentColor))

            case .failed:
                ZStack {
                    Circle()
                        .fill(Color.red.opacity(0.2))
                    Image(systemName: "xmark")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
    }

    private var actions: some View {
        HStack(spacing: 8) {
            // Retry button for failed messages
            if queuedMessage.status == .failed && queuedMessage.canRetry {
                Button(action: onRetry) {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption)
                        .foregroundColor(.accentColor)
                        .frame(width: 28, height: 28)
                        .background(Color.accentColor.opacity(0.1))
                        .clipShape(Circle())
                }
            }

            // Cancel button for pending/failed messages
            if queuedMessage.status == .pending || queuedMessage.status == .failed {
                Button(action: onCancel) {
                    Image(systemName: "xmark")
                        .font(.caption)
                        .foregroundColor(.red)
                        .frame(width: 28, height: 28)
                        .background(Color.red.opacity(0.1))
                        .clipShape(Circle())
                }
            }
        }
    }
}

// MARK: - Compact Status Badge

/// Compact badge showing queue status (for toolbar/header)
struct DeliveryStatusBadge: View {

    @ObservedObject var deliveryManager: MessageDeliveryManager

    var body: some View {
        HStack(spacing: 6) {
            // Status indicator
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)

            // Count
            if deliveryManager.pendingCount > 0 {
                Text("\(deliveryManager.pendingCount)")
                    .font(.caption2.weight(.semibold))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private var statusColor: Color {
        switch deliveryManager.queueState {
        case .idle:
            return .green
        case .pending, .waitingForNetwork:
            return .orange
        case .delivering:
            return .blue
        case .hasFailed:
            return .red
        }
    }
}

// MARK: - Preview

#if DEBUG
struct DeliveryStatusView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Idle state
            DeliveryStatusView(deliveryManager: createManager(state: .idle))

            // Delivering state
            DeliveryStatusView(deliveryManager: createManager(state: .delivering))

            // With pending messages
            DeliveryStatusView(deliveryManager: createManager(state: .pending))

            // With failed messages
            DeliveryStatusView(deliveryManager: createManager(state: .hasFailed))
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }

    static func createManager(state: MessageDeliveryManager.QueueState) -> MessageDeliveryManager {
        let manager = MessageDeliveryManager()

        // Mock the state
        // In real usage, the manager would update based on queue changes

        return manager
    }
}
#endif
