//
//  BackgroundTaskManager.swift
//  VestaWidget
//
//  Manages background task scheduling for message queue processing
//  Ensures messages are delivered even when app is backgrounded or terminated
//  Uses BGTaskScheduler for iOS background execution
//

import Foundation
import BackgroundTasks
import UIKit

/// Manages background tasks for processing message queue
/// Registers tasks with iOS and handles scheduling/execution
class BackgroundTaskManager {

    // MARK: - Task Identifiers

    /// Background task identifier for queue processing
    /// This MUST match the identifier in Info.plist under BGTaskSchedulerPermittedIdentifiers
    static let queueProcessingTaskIdentifier = "com.vestawidget.queueprocessing"

    /// Background task identifier for queue cleanup
    static let queueCleanupTaskIdentifier = "com.vestawidget.queuecleanup"

    // MARK: - Singleton

    static let shared = BackgroundTaskManager()

    // MARK: - Properties

    /// Message delivery manager for processing
    private var deliveryManager: MessageDeliveryManager?

    /// Whether background tasks are registered
    private var isRegistered = false

    // MARK: - Initialization

    private init() {
        // Private initializer for singleton
    }

    // MARK: - Public Methods

    /// Registers background tasks with iOS
    /// Call this during app launch (in AppDelegate or App struct)
    func registerBackgroundTasks() {
        guard !isRegistered else { return }

        // Register queue processing task
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: Self.queueProcessingTaskIdentifier,
            using: nil
        ) { task in
            self.handleQueueProcessing(task: task as! BGProcessingTask)
        }

        // Register cleanup task
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: Self.queueCleanupTaskIdentifier,
            using: nil
        ) { task in
            self.handleQueueCleanup(task: task as! BGProcessingTask)
        }

        isRegistered = true

        print("✅ Background tasks registered")
    }

    /// Schedules background queue processing
    /// Call this when messages are queued and app enters background
    func scheduleQueueProcessing() {
        let request = BGProcessingTaskRequest(identifier: Self.queueProcessingTaskIdentifier)

        // Allow processing on cellular data (important for message delivery)
        request.requiresNetworkConnectivity = true
        request.requiresExternalPower = false

        // Process as soon as possible
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60)  // 1 minute from now

        do {
            try BGTaskScheduler.shared.submit(request)
            print("✅ Scheduled background queue processing")
        } catch {
            print("❌ Could not schedule background task: \(error)")
        }
    }

    /// Schedules background queue cleanup
    /// Removes old/stale messages from queue
    func scheduleQueueCleanup() {
        let request = BGProcessingTaskRequest(identifier: Self.queueCleanupTaskIdentifier)

        request.requiresNetworkConnectivity = false
        request.requiresExternalPower = false

        // Run cleanup daily
        request.earliestBeginDate = Date(timeIntervalSinceNow: 24 * 60 * 60)

        do {
            try BGTaskScheduler.shared.submit(request)
            print("✅ Scheduled background queue cleanup")
        } catch {
            print("❌ Could not schedule cleanup task: \(error)")
        }
    }

    /// Cancels all scheduled background tasks
    func cancelAllBackgroundTasks() {
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: Self.queueProcessingTaskIdentifier)
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: Self.queueCleanupTaskIdentifier)
        print("✅ Cancelled all background tasks")
    }

    /// Sets the delivery manager for background processing
    /// - Parameter deliveryManager: Manager to use for processing
    func setDeliveryManager(_ deliveryManager: MessageDeliveryManager) {
        self.deliveryManager = deliveryManager
    }

    // MARK: - Private Methods - Task Handlers

    /// Handles background queue processing task
    /// - Parameter task: The background processing task
    private func handleQueueProcessing(task: BGProcessingTask) {
        print("🔄 Background queue processing started")

        // Schedule next occurrence
        scheduleQueueProcessing()

        // Set expiration handler
        task.expirationHandler = {
            print("⏰ Background task expired")
            task.setTaskCompleted(success: false)
        }

        // Create background task for async work
        Task {
            do {
                // Create delivery manager if needed
                let manager = self.deliveryManager ?? MessageDeliveryManager()

                // Process pending messages
                let pendingCount = manager.pendingCount

                if pendingCount > 0 {
                    print("📤 Processing \(pendingCount) pending messages in background")

                    // Give ourselves up to 25 seconds (iOS gives ~30 seconds)
                    try await withThrowingTaskGroup(of: Void.self) { group in
                        group.addTask {
                            try await Task.sleep(seconds: 25)
                            throw BackgroundTaskError.timeout
                        }

                        group.addTask {
                            // Process messages (this will handle queueing internally)
                            await self.processQueueInBackground(manager: manager)
                        }

                        // Wait for first completion (either timeout or processing)
                        try await group.next()
                        group.cancelAll()
                    }

                    print("✅ Background processing completed")
                    task.setTaskCompleted(success: true)
                } else {
                    print("ℹ️ No pending messages to process")
                    task.setTaskCompleted(success: true)
                }

            } catch {
                print("❌ Background processing failed: \(error)")
                task.setTaskCompleted(success: false)
            }
        }
    }

    /// Handles background queue cleanup task
    /// - Parameter task: The background cleanup task
    private func handleQueueCleanup(task: BGProcessingTask) {
        print("🧹 Background queue cleanup started")

        // Schedule next cleanup
        scheduleQueueCleanup()

        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }

        Task {
            // Create queue and clean up stale messages
            let queue = MessageQueue()
            let storage = AppGroupStorage.shared

            // Remove messages older than 24 hours
            let staleMessages = queue.allMessages.filter { message in
                let age = Date().timeIntervalSince(message.enqueuedDate)
                return age > AppConstants.maxMessageAge && message.status == .failed
            }

            for message in staleMessages {
                queue.cancel(message.id)
            }

            print("🧹 Cleaned up \(staleMessages.count) stale messages")
            task.setTaskCompleted(success: true)
        }
    }

    /// Processes the message queue in background
    /// - Parameter manager: Delivery manager to use
    private func processQueueInBackground(manager: MessageDeliveryManager) async {
        // The delivery manager will handle processing automatically
        // Just wait for pending messages to be processed
        var lastCount = manager.pendingCount

        while manager.pendingCount > 0 {
            // Wait a bit for processing
            try? await Task.sleep(seconds: 2)

            let currentCount = manager.pendingCount

            // Check if we're making progress
            if currentCount == lastCount {
                // No progress after 2 seconds, likely stuck
                print("⚠️ Queue processing stalled")
                break
            }

            lastCount = currentCount
        }
    }
}

// MARK: - Background Task Errors

enum BackgroundTaskError: Error {
    case timeout
    case notRegistered
    case schedulingFailed
}

// MARK: - App Integration Helpers

extension BackgroundTaskManager {

    /// Call this when app enters background
    /// Schedules background processing if there are pending messages
    func handleAppDidEnterBackground() {
        let queue = MessageQueue()

        if queue.hasPendingMessages {
            print("📱 App backgrounded with \(queue.pendingCount) pending messages")
            scheduleQueueProcessing()
        }
    }

    /// Call this when app enters foreground
    /// Cancels background tasks as foreground processing will handle queue
    func handleAppWillEnterForeground() {
        print("📱 App foregrounded - cancelling background tasks")
        cancelAllBackgroundTasks()
    }

    /// Call this when app is about to terminate
    /// Ensures background task is scheduled for pending messages
    func handleAppWillTerminate() {
        let queue = MessageQueue()

        if queue.hasPendingMessages {
            print("⚠️ App terminating with \(queue.pendingCount) pending messages")
            scheduleQueueProcessing()
        }
    }
}

// MARK: - Testing/Debug Helpers

#if DEBUG
extension BackgroundTaskManager {

    /// Simulates a background task for testing in simulator
    /// Background tasks don't run in simulator, so this helps with testing
    func simulateBackgroundProcessing() {
        print("🧪 Simulating background processing (DEBUG)")

        Task {
            let manager = self.deliveryManager ?? MessageDeliveryManager()
            await processQueueInBackground(manager: manager)
        }
    }

    /// Prints current background task status
    func printBackgroundTaskStatus() {
        print("""
        📊 Background Task Status:
        - Registered: \(isRegistered)
        - Queue Processing Task: \(Self.queueProcessingTaskIdentifier)
        - Cleanup Task: \(Self.queueCleanupTaskIdentifier)
        """)
    }
}
#endif

// MARK: - Setup Instructions

/*
 SETUP INSTRUCTIONS:

 1. Add to Info.plist:
    <key>BGTaskSchedulerPermittedIdentifiers</key>
    <array>
        <string>com.vestawidget.queueprocessing</string>
        <string>com.vestawidget.queuecleanup</string>
    </array>

 2. In VestaWidgetApp.swift, register tasks on init:
    init() {
        BackgroundTaskManager.shared.registerBackgroundTasks()
    }

 3. Handle app lifecycle events:
    .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
        BackgroundTaskManager.shared.handleAppDidEnterBackground()
    }

    .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
        BackgroundTaskManager.shared.handleAppWillEnterForeground()
    }

 4. Set delivery manager after creating it:
    let deliveryManager = MessageDeliveryManager()
    BackgroundTaskManager.shared.setDeliveryManager(deliveryManager)

 5. Testing in Xcode:
    - Background tasks don't run in simulator
    - Use e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.vestawidget.queueprocessing"]
    - Or use BackgroundTaskManager.shared.simulateBackgroundProcessing() in DEBUG builds

 IMPORTANT:
 - Background tasks have ~30 seconds of execution time
 - iOS decides when to run tasks based on system conditions
 - Tasks may not run if battery is low or device is in Low Power Mode
 - Always handle expiration gracefully
 */
