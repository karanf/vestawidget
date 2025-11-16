# VestaWidget Delivery System - Quick Reference

## 🚀 What's New

**Immediate Message Delivery System** with:
- ✅ Messages sent instantly (not on 15-min widget refresh)
- ✅ Automatic retry on failures
- ✅ Conflict detection for multi-user boards
- ✅ Background processing
- ✅ Real-time status UI
- ✅ Immediate widget updates

---

## 📁 Files Created

### New Services
1. **MessageQueue.swift** - Thread-safe queue
2. **MessageDeliveryManager.swift** - Orchestrates delivery
3. **MessageDeliveryStrategy.swift** - Delivery strategies
4. **BackgroundTaskManager.swift** - Background processing

### New UI
5. **DeliveryStatusView.swift** - Status UI component

---

## ✏️ Files Updated

1. **Constants.swift** - Added delivery config
2. **AppGroupStorage.swift** - Added queue persistence
3. **MessageComposerViewModel.swift** - Integrated delivery manager
4. **VestaboardAPI.swift** - Added conflict detection
5. **MessageComposerView.swift** - Added delivery status UI

---

## ⚙️ Setup Required (2 Steps)

### Step 1: Update VestaWidgetApp.swift

```swift
@main
struct VestaWidgetApp: App {
    init() {
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

### Step 2: Update Info.plist

Add:
```xml
<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
    <string>com.vestawidget.queueprocessing</string>
    <string>com.vestawidget.queuecleanup</string>
</array>
```

---

## 🔄 How It Works

```
User sends message
    ↓
Queue message
    ↓
Check network
    ↓
[Online] Send immediately
[Offline] Queue and retry when online
    ↓
Check for conflicts (optional)
    ↓
POST to Vestaboard API
    ↓
[Success] Update widget immediately
[Failure] Retry with backoff (2s, 4s, 8s, 16s, 32s)
    ↓
Show status in UI
```

---

## 🎯 Key Features

### 1. Automatic Queue
- Messages queued in memory + persisted to disk
- Survives app restart
- Max 50 messages
- 24-hour retention

### 2. Smart Retry
- 5 retry attempts (configurable)
- Exponential backoff: 2s → 4s → 8s → 16s → 32s
- Retries: Network errors, 500s, rate limits
- Doesn't retry: 401, 400, validation errors

### 3. Conflict Detection
- Read-before-write pattern
- Detects concurrent sends
- Strategies: Last-write-wins, Prevent overwrite, etc.

### 4. Real-time UI
- Shows delivery status
- Pending/failed counts
- Retry/cancel buttons
- Status messages

### 5. Widget Updates
- `WidgetCenter.reloadAllTimelines()` after send
- Immediate update (not 15-min wait)
- Updates shared storage

### 6. Background Processing
- Sends queued messages when app backgrounded
- Uses iOS BGTaskScheduler
- ~30 seconds execution time
- Requires real device (not simulator)

---

## 🔧 Configuration

### Change Retry Settings
**File**: `Constants.swift`
```swift
static let maxRetryAttempts = 5        // Change to 3 for faster failure
static let retryBaseDelay: TimeInterval = 2   // Change to 1 for faster retries
```

### Change Queue Size
```swift
static let maxQueueSize = 50           // Change to 100 for more messages
```

### Change Delivery Strategy
**File**: `MessageComposerViewModel.swift`
```swift
// Default (recommended)
let manager = MessageDeliveryManager()

// Multi-user safety (prevents overwrites)
let strategy = ConflictAwareStrategy()
let manager = MessageDeliveryManager(strategy: strategy)

// Single-user speed (no conflict checks)
let strategy = OptimisticDeliveryStrategy()
let manager = MessageDeliveryManager(strategy: strategy)
```

---

## 📊 Delivery Strategies

| Strategy | Queue | Conflicts | Use Case |
|----------|-------|-----------|----------|
| **Queued** (default) | ✅ | Check, allow | General use |
| **Immediate** | ❌ | No | Single-user, speed |
| **ConflictAware** | ✅ | Check, prevent | Multi-user |
| **Optimistic** | ✅ | No | Low-traffic |
| **RetryOnly** | ❌ | No | Simple retry |

---

## 🧪 Testing

### Test 1: Normal Send
1. Send message while online
2. **Expected**: Immediate delivery, widget updates

### Test 2: Offline Send
1. Enable airplane mode
2. Send message
3. **Expected**: Message queues, shows "Waiting for network"
4. Disable airplane mode
5. **Expected**: Message sends automatically

### Test 3: Failed Send
1. Invalid API credentials
2. Send message
3. **Expected**: Retries 5 times, then fails
4. **Expected**: Retry button appears

### Test 4: Background Processing
1. Send message offline
2. Enable network
3. Background app
4. Wait 2 minutes
5. Foreground app
6. **Expected**: Message sent

---

## 🐛 Troubleshooting

### Messages stuck in queue?
- Check network: Settings → WiFi
- Check credentials: Settings → Test Connection
- Check status view for errors
- Try manual retry

### Widget not updating?
- Verify WidgetCenter.reloadAllTimelines() called
- Check App Group ID matches
- Restart device

### Background tasks not running?
- Test on **real device** (not simulator)
- Check battery not low
- Check Low Power Mode off
- Debug: `BackgroundTaskManager.shared.simulateBackgroundProcessing()`

---

## 📖 Documentation

| Document | Purpose |
|----------|---------|
| **DELIVERY_SYSTEM.md** | Complete technical documentation |
| **INTEGRATION_GUIDE.md** | Step-by-step setup guide |
| **IMPLEMENTATION_SUMMARY.md** | What was implemented |
| **QUICK_REFERENCE.md** | This file - quick lookup |

---

## 🎨 UI Components

### DeliveryStatusView
Shows full delivery status with queue details.

**Usage**:
```swift
DeliveryStatusView(deliveryManager: viewModel.deliveryManager)
```

**Shows**:
- Current status (idle/pending/delivering/failed)
- Pending count
- Failed count
- Queue details (expandable)
- Retry/cancel actions

### DeliveryStatusBadge
Compact status indicator for toolbar.

**Usage**:
```swift
DeliveryStatusBadge(deliveryManager: viewModel.deliveryManager)
```

---

## 🔑 Key Classes

### MessageQueue
```swift
let queue = MessageQueue()
queue.enqueue(message)           // Add to queue
queue.dequeue()                  // Get next message
queue.markAsSent(id)            // Remove sent
queue.markAsFailed(id, error)   // Mark failed
queue.retry(id)                  // Retry
```

### MessageDeliveryManager
```swift
let manager = MessageDeliveryManager()
await manager.sendMessage("Hello")   // Send
manager.cancelMessage(id)            // Cancel
manager.retryMessage(id)             // Retry
manager.clearFailedMessages()        // Clear failed
```

### BackgroundTaskManager
```swift
BackgroundTaskManager.shared.registerBackgroundTasks()
BackgroundTaskManager.shared.handleAppDidEnterBackground()
BackgroundTaskManager.shared.handleAppWillEnterForeground()
```

---

## 📈 Performance

| Metric | Value |
|--------|-------|
| Queue size | 50 messages max |
| Memory per message | ~1KB |
| Max queue memory | ~50KB |
| Network requests per send | 1-2 (with conflict check) |
| Widget reload time | ~100ms |
| Background task time | ~30 seconds max |

---

## 🔒 Security

- ✅ Credentials in Keychain (encrypted)
- ✅ Queue in App Group UserDefaults
- ✅ HTTPS for all API calls
- ✅ No third-party services
- ✅ No new permissions required

---

## ✅ Checklist

- [ ] Update VestaWidgetApp.swift
- [ ] Update Info.plist
- [ ] Build project
- [ ] Test normal send
- [ ] Test offline send
- [ ] Test failed send + retry
- [ ] Test background processing (real device)
- [ ] Verify widget updates immediately

---

## 🚦 Status Codes

| Status | Meaning |
|--------|---------|
| **Pending** | Waiting to send |
| **Sending** | Currently posting to API |
| **Sent** | Successfully delivered |
| **Failed** | Max retries exceeded |

---

## 🎯 Quick Commands

### Send message
```swift
await viewModel.postMessage()
```

### Check queue status
```swift
let pending = deliveryManager.pendingCount
let failed = deliveryManager.failedCount
```

### Retry failed
```swift
deliveryManager.retryMessage(messageID)
```

### Cancel message
```swift
deliveryManager.cancelMessage(messageID)
```

---

## 💡 Tips

1. **Single User?** Use `OptimisticDeliveryStrategy` for speed
2. **Multi User?** Use `ConflictAwareStrategy` for safety
3. **Faster Failures?** Reduce `maxRetryAttempts` to 2-3
4. **More Messages?** Increase `maxQueueSize` to 100+
5. **Testing?** Use DEBUG simulator method for background tasks

---

## 🆘 Support

**Issue**: Messages not sending
→ Check network, credentials, status view

**Issue**: Widget not updating
→ Check App Group ID, WidgetCenter call

**Issue**: Background tasks not working
→ Test on real device, check battery/Low Power Mode

**Issue**: Conflicts always detected
→ Switch to OptimisticDeliveryStrategy or accept last-write-wins

---

## 🎉 Summary

**You now have**:
- ✅ Immediate message delivery
- ✅ Automatic retry logic
- ✅ Conflict detection
- ✅ Background processing
- ✅ Real-time status UI
- ✅ Instant widget updates

**Just complete the 2 setup steps and you're ready!**

---

**Files**:
- `/home/user/vestawidget/DELIVERY_SYSTEM.md` - Full docs
- `/home/user/vestawidget/INTEGRATION_GUIDE.md` - Setup guide
- `/home/user/vestawidget/IMPLEMENTATION_SUMMARY.md` - What's new
- `/home/user/vestawidget/QUICK_REFERENCE.md` - This file

**Last Updated**: 2025-11-16
