# VestaWidget Message Delivery System

## Overview

The VestaWidget Message Delivery System is a production-grade, robust solution for sending messages to Vestaboard with guaranteed delivery, conflict detection, and real-time updates. Messages are delivered **immediately** when sent, not waiting for the 15-minute widget refresh cycle.

### Key Features

- **Immediate Delivery**: Messages POST to Vestaboard API instantly upon send
- **Reliable Queue**: Thread-safe, persistent FIFO queue that survives app restarts
- **Conflict Detection**: Read-before-write pattern detects concurrent message sends
- **Retry Logic**: Exponential backoff retry for transient failures
- **Real-time Updates**: Widgets update immediately after successful sends
- **Background Processing**: Handles queued messages even when app is backgrounded
- **Status Tracking**: Comprehensive delivery status (pending → sending → sent/failed)
- **User Feedback**: Real-time UI updates showing delivery progress

---

## Architecture

### System Components

```
┌─────────────────────────────────────────────────────────────┐
│                    User Interface Layer                      │
├─────────────────────────────────────────────────────────────┤
│  MessageComposerView  │  DeliveryStatusView                 │
│  MessageComposerViewModel                                   │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│               MessageDeliveryManager                         │
│  - Orchestrates delivery                                    │
│  - Manages queue processing                                 │
│  - Implements retry logic                                   │
│  - Detects conflicts                                        │
└────────────────┬────────────────────────────────────────────┘
                 │
       ┌─────────┴──────────┬──────────────┬─────────────┐
       ▼                    ▼              ▼             ▼
┌─────────────┐    ┌──────────────┐  ┌─────────┐  ┌──────────┐
│ MessageQueue│    │VestaboardAPI │  │Strategy │  │Background│
│             │    │              │  │         │  │Task Mgr  │
│- FIFO Queue │    │- GET/POST    │  │- Queued │  │          │
│- Thread-safe│    │- Conflict    │  │- Immed. │  │- BGTask  │
│- Persistent │    │  check       │  │- Aware  │  │  Sched.  │
└─────────────┘    └──────────────┘  └─────────┘  └──────────┘
       │                    │
       ▼                    ▼
┌─────────────────────────────────┐
│      AppGroupStorage            │
│  - Queue persistence            │
│  - Content caching              │
│  - Cross-process access         │
└─────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────┐
│       WidgetKit                 │
│  - Immediate timeline reload    │
│  - 15-min scheduled refresh     │
└─────────────────────────────────┘
```

---

## Message Flow

### 1. Normal Message Send Flow

```
User taps "Send"
    ↓
MessageComposerViewModel.postMessage()
    ↓
MessageDeliveryManager.sendMessage()
    ↓
MessageQueue.enqueue() ──────┐
    ↓                         │
[Persisted to App Group]      │
    ↓                         │
MessageDeliveryManager.processQueue() ←┘
    ↓
Check network connectivity
    ↓
[If offline] → Queue remains, retry when online
    ↓
[If online] → Continue
    ↓
MessageQueue.dequeue() → Status: "sending"
    ↓
Strategy: Should check conflicts?
    ↓
[Yes] VestaboardAPI.getCurrentMessage() (read-before-write)
    ↓
Compare with last known state
    ↓
[Conflict?] → Handle per strategy (default: last-write-wins)
    ↓
VestaboardAPI.postMessage() → POST to Vestaboard
    ↓
[Success] ──────────────────────────┐
    │                               │
    ↓                               │
Remove from queue                   │
Update App Group storage            │
WidgetCenter.reloadAllTimelines()   │
Save to history                     │
Update UI                           │
    ↓                               │
User sees: "Message sent!"          │
Widget updates immediately          │
                                    │
[Failure] ──────────────────────────┘
    ↓
Increment retry count
Calculate exponential backoff (2s, 4s, 8s, 16s, 32s)
Update queue status to "pending"
    ↓
[Retry count < max] → Wait for backoff → Retry
    ↓
[Retry count ≥ max] → Mark as "failed"
    ↓
User sees: "Failed after X attempts"
User can manually retry or cancel
```

### 2. Conflict Detection Flow

```
MessageDeliveryManager preparing to send
    ↓
Strategy.shouldCheckConflicts? → Yes
    ↓
GET current board state from API
    ↓
Compare with cached content from storage
    ↓
[Same] → No conflict, proceed with send
    ↓
[Different] → Conflict detected!
    ↓
Strategy.shouldPreventConflicts?
    ↓
[No - Last-write-wins] ────────────┐
    │                              │
    ↓                              │
Update cached content              │
Notify delegate of conflict        │
Proceed with send anyway           │
    ↓                              │
POST message (overwrites board)    │
    ↓                              │
Success                            │
                                   │
[Yes - Prevent overwrites] ────────┘
    ↓
Do NOT send message
Mark message as "failed" with conflict error
Notify user
    ↓
User options:
  - Cancel message
  - Retry (will re-check, may succeed if resolved)
  - Force send (future enhancement)
```

### 3. Background Processing Flow

```
App enters background
    ↓
BackgroundTaskManager.handleAppDidEnterBackground()
    ↓
Check if queue has pending messages
    ↓
[No pending] → Do nothing
    ↓
[Has pending] → Schedule BGProcessingTask
    ↓
iOS decides when to run task (based on system conditions)
    ↓
Task executes (up to ~30 seconds)
    ↓
BackgroundTaskManager.handleQueueProcessing()
    ↓
Create/use MessageDeliveryManager
    ↓
Process queue (same flow as foreground)
    ↓
Task completes or expires
    ↓
[Expired] → Schedule another task for remaining messages
    ↓
[Completed] → All messages sent or queue empty
```

---

## Component Details

### MessageQueue

**Purpose**: Thread-safe, persistent FIFO queue for pending messages.

**Key Features**:
- Serial dispatch queue ensures thread safety
- Automatic persistence to App Group UserDefaults
- Stale message cleanup (removes messages older than 24 hours)
- Status tracking: pending, sending, failed
- Retry count and backoff date tracking

**Key Methods**:
- `enqueue()`: Add message to queue
- `dequeue()`: Get next pending message (changes status to "sending")
- `peek()`: View next message without removing
- `markAsSent()`: Remove successfully sent message
- `markAsFailed()`: Update failed message with retry info
- `cancel()`: Remove message from queue
- `retry()`: Reset failed message to pending

**Thread Safety**: All operations wrapped in serial DispatchQueue.

**Persistence**: Automatically saves to `AppGroupStorage` after every modification.

### MessageDeliveryManager

**Purpose**: Orchestrates the entire delivery lifecycle.

**Key Responsibilities**:
- Queue management (enqueue incoming messages)
- Network connectivity checking
- Periodic queue processing
- Conflict detection coordination
- Retry logic with exponential backoff
- Widget updates after successful sends
- Delegate notifications for delivery events

**Key Properties**:
- `@Published isDelivering`: Whether currently sending
- `@Published statusMessage`: Current status for UI
- `@Published queueState`: Current queue state (idle, pending, delivering, etc.)
- `pendingCount`: Number of pending messages
- `failedCount`: Number of failed messages

**Key Methods**:
- `sendMessage(text)`: Queue a text message for delivery
- `sendMessage(message)`: Queue a VestaboardMessage
- `cancelMessage(id)`: Cancel a queued message
- `retryMessage(id)`: Retry a failed message
- `clearFailedMessages()`: Remove all failed messages

**Processing**:
- Automatic processing starts on init
- Timer checks queue every 10 seconds
- Processes messages sequentially to avoid conflicts
- 1-second delay between messages to avoid rate limiting

### MessageDeliveryStrategy

**Purpose**: Defines behavior for delivery and conflict handling.

**Available Strategies**:

1. **QueuedDeliveryStrategy** (Default)
   - Queues all messages
   - Checks for conflicts (read-before-write)
   - Last-write-wins on conflicts
   - Full retry logic

2. **ImmediateDeliveryStrategy**
   - No queueing
   - No conflict checking
   - Fastest delivery
   - Use for single-user scenarios

3. **ConflictAwareStrategy**
   - Queues messages
   - Checks for conflicts
   - Prevents overwrites (fails on conflict)
   - User must resolve conflicts
   - Best for multi-user boards

4. **OptimisticDeliveryStrategy**
   - Queues messages
   - No conflict checking
   - Assumes conflicts are rare
   - Faster than conflict-aware

5. **RetryOnlyStrategy**
   - No queueing
   - Inline retry logic
   - No conflict detection

**Choosing a Strategy**:
```swift
// Default (recommended for most users)
let manager = MessageDeliveryManager()

// Single-user, speed priority
let manager = MessageDeliveryManager(
    strategy: ImmediateDeliveryStrategy()
)

// Multi-user, safety priority
let manager = MessageDeliveryManager(
    strategy: ConflictAwareStrategy()
)
```

### BackgroundTaskManager

**Purpose**: Handles background queue processing using iOS BGTaskScheduler.

**Setup Requirements**:

1. **Info.plist** - Add background task identifiers:
```xml
<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
    <string>com.vestawidget.queueprocessing</string>
    <string>com.vestawidget.queuecleanup</string>
</array>
```

2. **App Initialization** - Register tasks:
```swift
// In VestaWidgetApp.swift
init() {
    BackgroundTaskManager.shared.registerBackgroundTasks()
}
```

3. **Lifecycle Handling** - Schedule on background:
```swift
.onReceive(NotificationCenter.default.publisher(
    for: UIApplication.didEnterBackgroundNotification
)) { _ in
    BackgroundTaskManager.shared.handleAppDidEnterBackground()
}
```

**Task Types**:
- **Queue Processing**: Sends pending messages (runs when scheduled by iOS)
- **Queue Cleanup**: Removes stale failed messages (runs daily)

**Limitations**:
- iOS controls when tasks run (not guaranteed)
- ~30 seconds execution time limit
- May not run if battery is low or Low Power Mode active
- Does not run in iOS Simulator (use debug simulation method)

### DeliveryStatusView

**Purpose**: SwiftUI view showing delivery status and queue.

**Features**:
- Real-time status updates
- Pending message count
- Failed message count
- Expandable queue details
- Per-message actions (retry, cancel)
- Status icons and colors
- Clear failed messages button

**Usage**:
```swift
// In MessageComposerView
DeliveryStatusView(deliveryManager: viewModel.deliveryManager)
    .padding()

// Compact badge for toolbar
DeliveryStatusBadge(deliveryManager: viewModel.deliveryManager)
```

---

## Retry Logic

### Exponential Backoff

Failed messages are retried with increasing delays:

```
Attempt 1: Immediate
Attempt 2: 2 seconds delay
Attempt 3: 4 seconds delay
Attempt 4: 8 seconds delay
Attempt 5: 16 seconds delay
Attempt 6: 32 seconds delay
```

Formula: `delay = baseDelay * 2^(attemptCount - 1)`

### Retryable Errors

The system retries these errors:
- Network errors (URLError)
- Rate limiting (429)
- Server errors (5xx)
- Timeouts

### Non-Retryable Errors

These errors fail immediately:
- Unauthorized (401) - Invalid credentials
- Bad request (400) - Invalid message format
- Invalid message - Unsupported characters

### Maximum Retries

Default: 5 attempts (configurable in Constants.swift)

After max retries, message status → "failed"

User can manually retry or cancel

---

## Conflict Resolution

### Conflict Scenarios

**Scenario 1: Concurrent Sends (Same User)**
```
User sends "Hello" at 2:00:00
User sends "World" at 2:00:01

Queue:
1. "Hello" (pending)
2. "World" (pending)

Processing:
- "Hello" sends → Success
- Board now shows "Hello"
- "World" sends → Success (overwrites "Hello")
- Board now shows "World"

Result: Last message wins (expected behavior)
```

**Scenario 2: Multi-User Conflict**
```
User A sends "Meeting at 2pm" at 2:00:00
User B sends "Lunch at 1pm" at 2:00:05

User A's flow:
- Message queued
- Read board: [previous content]
- Send "Meeting at 2pm" → Success

User B's flow (5 seconds later):
- Message queued
- Read board: "Meeting at 2pm" (changed!)
- Cached content was [previous content]
- Conflict detected!

Default behavior (QueuedDeliveryStrategy):
- Last-write-wins
- Send "Lunch at 1pm" anyway
- Board shows "Lunch at 1pm"
- User A's message is overwritten

ConflictAwareStrategy behavior:
- Prevent send
- Mark as failed
- Notify User B: "Board content changed"
- User B can review and decide to resend or cancel
```

### Conflict Detection Implementation

```swift
// Read-before-write pattern
let currentContent = try await api.getCurrentMessage(...)
let cachedContent = storage.retrieveContent()

if currentContent != cachedContent {
    // Conflict detected
    if strategy.shouldPreventConflicts {
        // Don't send, notify user
        return .failure(.conflictDetected)
    } else {
        // Send anyway (last-write-wins)
        // Update cache to current state
        try storage.saveContent(currentContent)
    }
}

// Send message
try await api.postMessage(...)
```

---

## Integration Guide

### Basic Setup

1. **Use in MessageComposerViewModel**:

The delivery manager is already integrated in `MessageComposerViewModel`. No changes needed for basic usage.

```swift
// When user taps send
await viewModel.postMessage()

// The ViewModel uses:
let result = await deliveryManager.sendMessage(messageText)
```

2. **Show Delivery Status in UI**:

Add the `DeliveryStatusView` to your `MessageComposerView`:

```swift
struct MessageComposerView: View {
    @StateObject private var viewModel = MessageComposerViewModel()

    var body: some View {
        VStack {
            // ... existing UI ...

            // Add delivery status
            DeliveryStatusView(deliveryManager: viewModel.deliveryManager)
                .padding()
        }
    }
}
```

3. **Enable Background Processing**:

In `VestaWidgetApp.swift`:

```swift
@main
struct VestaWidgetApp: App {

    init() {
        // Register background tasks
        BackgroundTaskManager.shared.registerBackgroundTasks()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onReceive(NotificationCenter.default.publisher(
                    for: UIApplication.didEnterBackgroundNotification
                )) { _ in
                    BackgroundTaskManager.shared.handleAppDidEnterBackground()
                }
                .onReceive(NotificationCenter.default.publisher(
                    for: UIApplication.willEnterForegroundNotification
                )) { _ in
                    BackgroundTaskManager.shared.handleAppWillEnterForeground()
                }
        }
    }
}
```

4. **Add Info.plist Entries**:

Add these keys to your Info.plist:

```xml
<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
    <string>com.vestawidget.queueprocessing</string>
    <string>com.vestawidget.queuecleanup</string>
</array>
```

### Advanced Configuration

**Custom Delivery Strategy**:

```swift
// Create ViewModel with specific strategy
let strategy = ConflictAwareStrategy()
let deliveryManager = MessageDeliveryManager(strategy: strategy)
let viewModel = MessageComposerViewModel(
    deliveryManager: deliveryManager
)
```

**Custom Delivery Configuration**:

```swift
// In Constants.swift, modify these values:
static let maxRetryAttempts = 5
static let retryBaseDelay: TimeInterval = 2
static let maxQueueSize = 50
static let maxMessageAge: TimeInterval = 24 * 60 * 60
```

**Implement Delivery Delegate**:

```swift
class MyViewController: UIViewController, MessageDeliveryDelegate {

    let deliveryManager = MessageDeliveryManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        deliveryManager.delegate = self
    }

    func deliveryManager(_ manager: MessageDeliveryManager,
                        didSendMessage message: QueuedMessage) {
        print("✅ Message sent: \(message.message.text)")
    }

    func deliveryManager(_ manager: MessageDeliveryManager,
                        didFailMessage message: QueuedMessage,
                        error: Error) {
        print("❌ Message failed: \(error)")
    }

    func deliveryManager(_ manager: MessageDeliveryManager,
                        didDetectConflictForMessage message: QueuedMessage,
                        currentContent: VestaboardContent) {
        print("⚠️ Conflict detected!")
        // Show alert, ask user how to proceed
    }
}
```

---

## Testing

### Unit Testing

Test the message queue:

```swift
func testMessageQueue() async {
    let queue = MessageQueue()
    let message = QueuedMessage(
        message: VestaboardMessage(text: "Test")
    )

    // Test enqueue
    let result = queue.enqueue(message)
    XCTAssertTrue(result.isSuccess)
    XCTAssertEqual(queue.count, 1)

    // Test dequeue
    let dequeued = queue.dequeue()
    XCTAssertNotNil(dequeued)
    XCTAssertEqual(dequeued?.status, .sending)

    // Test mark as sent
    queue.markAsSent(message.id)
    XCTAssertEqual(queue.count, 0)
}
```

### Integration Testing

Test the delivery manager:

```swift
func testDeliveryManager() async {
    let mockAPI = MockVestaboardAPI()
    let manager = MessageDeliveryManager(api: mockAPI)

    // Send message
    let result = await manager.sendMessage("Test")

    switch result {
    case .success(let id):
        XCTAssertNotNil(id)
    case .failure(let error):
        XCTFail("Delivery failed: \(error)")
    }
}
```

### Debugging Background Tasks

Background tasks don't run in simulator. To test:

**Option 1: Use Debug Method**
```swift
#if DEBUG
BackgroundTaskManager.shared.simulateBackgroundProcessing()
#endif
```

**Option 2: Use Xcode Console**
```
e -l objc -- (void)[[BGTaskScheduler sharedScheduler]
  _simulateLaunchForTaskWithIdentifier:@"com.vestawidget.queueprocessing"]
```

---

## Troubleshooting

### Messages Not Sending

**Check**:
1. Network connectivity (NetworkMonitor.shared.isConnected)
2. API credentials valid (Settings → Test Connection)
3. Queue status (DeliveryStatusView)
4. Error messages in delivery status

**Solutions**:
- Retry failed messages manually
- Clear failed messages and resend
- Check console logs for errors
- Verify API rate limits not exceeded

### Conflicts Always Detected

**Possible Causes**:
1. Multiple users sending concurrently
2. Another app/service updating board
3. Board being manually updated

**Solutions**:
- Use `ConflictAwareStrategy` and coordinate with other users
- Switch to `OptimisticDeliveryStrategy` if conflicts are false positives
- Accept last-write-wins behavior (default)

### Background Tasks Not Running

**Possible Causes**:
1. Not running on real device (simulator doesn't support BGTasks)
2. Low Power Mode enabled
3. iOS hasn't scheduled task yet
4. App not properly registered tasks

**Solutions**:
- Test on real device
- Disable Low Power Mode
- Use debug simulation method
- Verify Info.plist has correct identifiers
- Check BackgroundTaskManager.shared.printBackgroundTaskStatus()

### Widget Not Updating Immediately

**Check**:
1. WidgetCenter.reloadAllTimelines() being called
2. App Group storage being updated
3. Widget target has App Group entitlement

**Solutions**:
- Verify App Group identifier matches in both targets
- Check console for widget errors
- Manually trigger widget refresh
- Restart device

---

## Performance Considerations

### Queue Size Limits

- **Max Queue Size**: 50 messages (configurable)
- **Max Message Age**: 24 hours
- Older messages are automatically cleaned up

### Network Efficiency

- Messages sent sequentially (prevents rate limiting)
- 1-second delay between sends
- Exponential backoff on failures
- Conflict checking adds 1 extra GET request per send

### Memory Management

- Queue persisted to disk, not held in memory
- Completed messages removed from queue
- Stale messages cleaned up automatically

### Battery Impact

- Background tasks limited to ~30 seconds
- Queue processing paused when battery is low
- Network requests use efficient URLSession

---

## Security Considerations

### Credential Storage

- API keys stored in Keychain (encrypted)
- Keychain access group allows widget access
- Credentials never stored in UserDefaults

### Queue Persistence

- Queue stored in App Group UserDefaults
- Only accessible by app and widgets (same App Group)
- No sensitive data in queue (just message text)

### Network Security

- All API calls use HTTPS
- API key and secret in request headers
- No credentials in URL or body

---

## Future Enhancements

### Planned Features

1. **User-Selectable Conflict Resolution**
   - Show dialog when conflict detected
   - Let user choose: overwrite, cancel, or merge

2. **Message Priority Levels**
   - High priority messages sent first
   - Low priority queued for later

3. **Scheduled Messages**
   - Send messages at specific times
   - Recurring messages

4. **Message Templates with Variables**
   - Templates with placeholders
   - Auto-fill with current data (date, weather, etc.)

5. **Multi-Board Support**
   - Queue messages for different boards
   - Switch between boards in UI

6. **Delivery Analytics**
   - Track send success rate
   - Average delivery time
   - Failure reasons

### Potential Optimizations

- Batch multiple pending messages (if API supports)
- Predictive queueing based on user patterns
- Adaptive retry delays based on error type
- Local caching of board state with versioning

---

## API Reference

See inline documentation in source files:

- `MessageQueue.swift` - Queue operations
- `MessageDeliveryManager.swift` - Delivery orchestration
- `MessageDeliveryStrategy.swift` - Strategy patterns
- `BackgroundTaskManager.swift` - Background processing
- `DeliveryStatusView.swift` - UI components
- `VestaboardAPI.swift` - API interactions

---

## Support

For issues or questions:
1. Check console logs for error messages
2. Review this documentation
3. Check inline code documentation
4. File issue on GitHub (if applicable)

---

## License

Part of VestaWidget iOS application.

---

## Changelog

### Version 1.0.0 (Initial Release)
- Message queue with persistence
- Delivery manager with retry logic
- Conflict detection support
- Background task processing
- Real-time UI updates
- Multiple delivery strategies
- Comprehensive error handling

---

**Last Updated**: 2025-11-16
**Author**: VestaWidget Development Team
**Document Version**: 1.0.0
