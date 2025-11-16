# Message Rotation System: Strategic Analysis

**Document Version**: 1.0.0
**Date**: 2025-11-16
**Status**: Recommendation Phase

---

## Executive Summary

This document analyzes the feasibility and desirability of implementing a **message rotation/carousel system** for VestaWidget to handle multiple messages sent within a short timeframe (e.g., 10 messages in 1 minute).

**Key Finding**: While message rotation is technically feasible, **it is NOT the recommended solution** for most use cases. Alternative approaches provide better user experience, lower battery impact, and fewer technical challenges.

**Recommended Solution**: **Hybrid: Smart Latest-Message Display + Widget Carousel + User Controls**

---

## Table of Contents

1. [Problem Statement](#problem-statement)
2. [Current System Analysis](#current-system-analysis)
3. [Message Rotation Evaluation](#message-rotation-evaluation)
4. [Alternative Solutions](#alternative-solutions)
5. [Comparative Analysis](#comparative-analysis)
6. [Recommendation](#recommendation)
7. [Implementation Plan](#implementation-plan)
8. [Edge Cases & Challenges](#edge-cases--challenges)

---

## Problem Statement

### Scenario

**User sends 10 messages within 1 minute**

**Current Behavior:**
- All 10 messages are queued in `MessageQueue`
- Messages are sent sequentially with 1-second delay between each
- Each message overwrites the previous one on the physical board
- **Only the last message (message #10) remains visible**
- Messages #1-9 briefly flashed on the board (for ~1 second each)
- Users never really "saw" messages #1-9

**User's Desired Behavior:**
- Each message should be visible for a reasonable duration (~1 minute)
- Messages should rotate/cycle through automatically
- All messages get fair display time (not just the last one)

### Root Cause

The current system is optimized for **immediate delivery** with **conflict detection**, not for **sustained visibility** of multiple messages. Once a message is sent to the Vestaboard API, it remains on the physical board until another message overwrites it.

**The Physical Constraint:**
- Vestaboard is a static display
- It doesn't have built-in rotation capability
- To "rotate" messages, the app must continuously POST new messages to the API
- Each rotation = 1 API call

---

## Current System Analysis

### How Messages Are Currently Handled

```
User sends Message #1 → Queued → Sent immediately → Displayed on board
User sends Message #2 → Queued → Sent 1 second later → Overwrites #1
User sends Message #3 → Queued → Sent 1 second later → Overwrites #2
...
User sends Message #10 → Queued → Sent 1 second later → Overwrites #9

Result: Board shows Message #10 permanently
```

### Current System Strengths

✅ **Immediate Delivery**: Messages POST within seconds
✅ **Reliability**: Queue with retry logic ensures delivery
✅ **Conflict Detection**: Read-before-write prevents overwrites
✅ **Battery Efficient**: Minimal API calls (1 per message)
✅ **Simple**: Easy to understand behavior

### Current System Weaknesses for Rotation

❌ **No Visibility for Early Messages**: Messages #1-9 are barely visible
❌ **No Rotation Logic**: Once sent, message stays until overwritten
❌ **No Duration Control**: Can't control how long messages display
❌ **No User Indication**: No way to know "there are 9 more messages"

---

## Message Rotation Evaluation

### What Is Message Rotation?

**Definition**: Automatically cycling through multiple messages on the Vestaboard, giving each message equal display time before moving to the next.

**Example Flow:**
```
10 messages sent within 1 minute
↓
System creates a "carousel" of 10 messages
↓
Message #1 displays for 60 seconds
Message #2 displays for 60 seconds (API POST)
Message #3 displays for 60 seconds (API POST)
...
Message #10 displays for 60 seconds (API POST)
↓
Total rotation time: 10 minutes
↓
What happens next?
  Option A: Repeat from #1 (infinite loop)
  Option B: Stop at #10 (last message stays)
  Option C: Clear board (blank)
```

### Technical Requirements for Rotation

To implement automatic rotation, the system needs:

1. **Carousel Manager**: Orchestrates rotation lifecycle
2. **Timer/Scheduler**: Triggers message updates every X seconds
3. **State Persistence**: Remembers current rotation position
4. **API Throttling**: Respects rate limits (unknown for Vestaboard)
5. **Background Updates**: Continue rotating when app is backgrounded
6. **User Controls**: Start/stop/pause carousel
7. **Status Indicators**: Show "Message 3 of 10" somewhere

### Pros of Message Rotation

✅ **Equal Visibility**: Every message gets display time
✅ **Automated**: No manual intervention needed
✅ **Fair**: First-in, first-displayed (respects chronology)
✅ **Familiar**: Common pattern (slideshow, carousel)
✅ **Scalable**: Can handle many messages

### Cons of Message Rotation

❌ **Battery Drain**: Constant API calls every X seconds
❌ **API Rate Limits**: Unknown Vestaboard API limits - could hit rate limiting
❌ **Network Dependency**: Requires constant connectivity
❌ **Viewer Confusion**: People walking up mid-rotation see random message
❌ **Context Loss**: Viewers don't know it's rotating or how many messages exist
❌ **Background Limitations**: iOS restricts background updates severely
❌ **Timing Issues**: 10 messages × 60 seconds = 10 minutes of rotation
❌ **Interruption Handling**: What if new message arrives during rotation?
❌ **Completion Ambiguity**: What happens when rotation finishes?
❌ **Multi-Device Conflicts**: What if multiple devices try to rotate?
❌ **Waste of Messages**: If no one is watching the board, rotation is pointless
❌ **Complexity**: Significant engineering effort for edge cases

### Use Cases Where Rotation Works Well

1. **Active Monitoring Scenario**
   - Board is in a command center with constant viewers
   - Users expect cycling information (dashboards, metrics)
   - Example: Stock ticker, KPI dashboard

2. **Scheduled Information Display**
   - Predetermined set of messages (morning announcements)
   - Users know to watch for rotation
   - Example: Daily schedule, cafeteria menu

3. **Low-Frequency Updates**
   - Few messages (2-3) sent occasionally
   - Long display duration (5+ minutes each)
   - Example: Morning greeting, lunch announcement, EOD summary

### Use Cases Where Rotation Does NOT Work Well

1. **High-Frequency Bursts** ⚠️ **← User's scenario**
   - 10 messages in 1 minute is probably a mistake or spam
   - Users likely want ONE message visible, not rotation
   - Example: Testing app, accidental multi-send

2. **Unattended Boards**
   - Board in hallway, people walk by occasionally
   - No one watching for full rotation cycle
   - Example: Office entrance board

3. **Time-Sensitive Messages**
   - "Meeting in 5 minutes!" is useless 8 minutes later
   - Rotation delays when message is visible
   - Example: Urgent notifications

4. **Single-User Boards**
   - Personal board in home
   - User sends messages intentionally
   - Likely wants LATEST message, not rotation

---

## Alternative Solutions

### Solution 1: Smart Latest-Message Display (Recommended Base)

**Description**: Show only the latest message, but track all messages in history. Widget shows carousel.

**How It Works:**
```
User sends 10 messages in 1 minute
↓
All 10 queued and sent immediately (current behavior)
↓
Physical board shows: Message #10 (latest)
↓
iOS Widget shows: Rotating carousel of all 10 messages
↓
App shows: Full message history with timestamps
```

**Pros:**
- ✅ Simple (uses existing system)
- ✅ Battery efficient (no extra API calls)
- ✅ Fast delivery (immediate)
- ✅ Widget provides carousel view
- ✅ App provides full history
- ✅ Board shows most relevant (latest) message
- ✅ No background processing needed

**Cons:**
- ❌ Physical board doesn't rotate (only shows latest)
- ❌ Older messages only visible in widget/app

**Best For:**
- Personal boards
- Time-sensitive updates
- Most users (95% of cases)

---

### Solution 2: Smart Grouping with Auto-Rotation

**Description**: Only trigger rotation when 2+ messages arrive within a configurable window (e.g., 2 minutes).

**How It Works:**
```
User sends Message #1 at 2:00:00 → Sent immediately, stays on board
User sends Message #2 at 2:00:05 (within 2-min window)
↓
System detects: Multiple messages in short window
↓
Creates carousel: [Message #1, Message #2]
↓
Starts rotation:
  - Message #1 displays for 60 seconds
  - Message #2 displays for 60 seconds
  - Repeat OR stop at last message
```

**Configuration:**
- **Grouping Window**: 1-5 minutes (default: 2 minutes)
- **Rotation Duration**: 30-300 seconds per message (default: 60 seconds)
- **Completion Behavior**: Repeat, stop at last, or clear

**Pros:**
- ✅ Automatic (no manual intervention)
- ✅ Only rotates when needed
- ✅ Handles burst scenarios
- ✅ Configurable behavior

**Cons:**
- ❌ Still has battery drain during rotation
- ❌ Background update challenges
- ❌ Viewer confusion
- ❌ Complex state management

**Best For:**
- Scheduled announcements (morning, lunch, EOD)
- Multi-user boards with coordinated sends
- Known rotation scenarios

---

### Solution 3: Digest Mode (Combine Messages)

**Description**: Combine multiple messages into a single, summarized display.

**How It Works:**
```
User sends:
  - "Meeting at 2pm"
  - "Lunch order deadline 1pm"
  - "Deploy at 3pm"
↓
System creates digest:

  ╔════════════════════════╗
  ║   TODAY'S UPDATES      ║
  ║                        ║
  ║ • MEETING AT 2PM       ║
  ║ • LUNCH ORDER BY 1PM   ║
  ║ • DEPLOY AT 3PM        ║
  ╚════════════════════════╝
```

**Smart Digest Features:**
- Automatically formats as bullet list
- Truncates long messages
- Shows "3 messages" header
- Fits within 6×22 board constraints
- Stays on board permanently (until next update)

**Pros:**
- ✅ Single API call (efficient)
- ✅ All messages visible simultaneously
- ✅ No rotation needed
- ✅ Great for related messages
- ✅ Viewers see everything at once

**Cons:**
- ❌ Limited space (6 rows × 22 chars)
- ❌ Max ~3-4 messages can fit
- ❌ Truncation loses detail
- ❌ Not suitable for long messages
- ❌ Formatting challenges

**Best For:**
- Brief updates (< 20 chars each)
- Related messages (task list, reminders)
- Small number of messages (2-4)

---

### Solution 4: Manual Carousel Control

**Description**: Messages don't auto-rotate. User manually advances through them via app/widget.

**How It Works:**
```
User sends 10 messages
↓
Board shows: Message #1 (first message)
↓
Widget shows: "Message 1 of 10" + [Next] button
↓
User taps [Next] in widget/app
↓
App POSTs Message #2 to board
↓
Board shows: Message #2
↓
Widget updates: "Message 2 of 10" + [Next] button
```

**Widget UI:**
```
┌─────────────────────────┐
│  Message 1 of 10        │
│                         │
│  [Message Content]      │
│                         │
│  [← Prev]  [Next →]     │
└─────────────────────────┘
```

**Pros:**
- ✅ User controls pace
- ✅ No battery drain (on-demand)
- ✅ No background updates needed
- ✅ Clear status ("3 of 10")
- ✅ Works offline (messages cached)
- ✅ Viewers can pause and read

**Cons:**
- ❌ Requires manual interaction
- ❌ Not automatic
- ❌ Board doesn't update unless user acts

**Best For:**
- Review scenarios (checking sent messages)
- Educational content (step-by-step guides)
- Users who want full control

---

### Solution 5: Priority-Based Display

**Description**: Assign priority levels to messages. High-priority stays longer, low-priority rotates quickly.

**How It Works:**
```
User sends:
  - "URGENT: Fire drill in 5 min" (HIGH priority)
  - "Lunch menu: Pizza" (LOW priority)
  - "Reminder: Team meeting 2pm" (NORMAL priority)
↓
Rotation schedule:
  - HIGH: Displays for 5 minutes
  - NORMAL: Displays for 2 minutes
  - LOW: Displays for 30 seconds
↓
After rotation:
  - HIGH priority message stays on board
```

**Priority Levels:**
- **URGENT**: 5+ minutes, stays after rotation
- **NORMAL**: 2 minutes
- **LOW**: 30 seconds

**Pros:**
- ✅ Important messages get visibility
- ✅ Flexible duration
- ✅ Automatic priority handling
- ✅ After rotation, board shows most important message

**Cons:**
- ❌ User must assign priority (extra step)
- ❌ Still requires background rotation
- ❌ Complex scheduling logic
- ❌ Battery drain

**Best For:**
- Mixed-importance messages
- Alert systems
- Critical announcements

---

### Solution 6: Time-Slot Based Rotation

**Description**: Divide day into time slots. Each slot shows its most recent message.

**How It Works:**
```
Time Slots:
  - 8-10am: Morning announcements
  - 10-12pm: Mid-morning updates
  - 12-2pm: Lunch period
  - 2-4pm: Afternoon updates
  - 4-6pm: End-of-day

User sends 3 messages at 9am:
  - All sent immediately
  - Board shows latest of the 3
  - Messages only rotate within 8-10am slot
  - At 10am, board switches to "mid-morning" slot
```

**Pros:**
- ✅ Natural time boundaries
- ✅ Prevents stale messages
- ✅ Predictable behavior

**Cons:**
- ❌ Complex scheduling
- ❌ Not useful for most users
- ❌ Arbitrary time boundaries

**Best For:**
- Office environments
- Scheduled information (weather, news)
- Public displays

---

### Solution 7: Notification + Latest Message (Pragmatic)

**Description**: Board shows latest message. App sends local notification for each message.

**How It Works:**
```
User sends 10 messages
↓
All 10 sent immediately (current behavior)
↓
Board shows: Message #10 (latest)
↓
iOS Notifications:
  - "Message 1 sent: [preview]"
  - "Message 2 sent: [preview]"
  - ...
  - "Message 10 sent: [preview]"
↓
User can review all messages in:
  - Notification Center
  - Message History in app
  - Widget carousel
```

**Pros:**
- ✅ Zero battery drain (no rotation)
- ✅ Uses existing system
- ✅ Notifications provide awareness
- ✅ User controls when to review messages
- ✅ Simple implementation

**Cons:**
- ❌ Physical board doesn't show all messages
- ❌ Requires notification permissions

**Best For:**
- Personal boards
- Users who want awareness without rotation
- Battery-conscious users

---

### Solution 8: Hybrid - Smart Latest + Widget Carousel + User Control (RECOMMENDED)

**Description**: Combines best aspects of multiple solutions.

**How It Works:**

**Physical Board:**
- Shows latest message (Message #10)
- Updates immediately on new messages
- No automatic rotation (battery efficient)

**iOS Widget:**
- Shows rotating carousel of recent messages
- Auto-advances every 15 minutes (widget refresh)
- Displays "Message 3 of 10" indicator
- User can tap to open full history in app

**App:**
- Full message history with timestamps
- Manual carousel control (user can rotate board remotely)
- "Send all to board" feature for manual rotation
- Settings to configure behavior

**Optional: Smart Grouping**
- If 3+ messages within 2 minutes → show digest on board
- Example: Combines into bullet list

**Pros:**
- ✅ **Best of all worlds**
- ✅ Battery efficient (no background rotation)
- ✅ Physical board shows latest (most relevant)
- ✅ Widget provides carousel view
- ✅ App provides full control
- ✅ User can manually trigger rotation if desired
- ✅ Optional digest mode for bursts
- ✅ Simple, predictable behavior

**Cons:**
- ❌ Physical board doesn't auto-rotate (this is intentional)
- ❌ Requires user to check widget/app for older messages

**Best For:**
- **95% of users** (recommended default)
- Personal and shared boards
- Mix of urgent and non-urgent messages
- Battery-conscious users

---

## Comparative Analysis

### Comparison Matrix

| Solution | Battery Impact | API Calls | Complexity | User Control | Board Rotation | Best For |
|----------|---------------|-----------|------------|--------------|----------------|----------|
| **Current (Latest Only)** | ⚡ Minimal | 10 (once) | ⭐ Simple | ❌ None | ❌ No | Simple scenarios |
| **Auto-Rotation** | 🔋🔋🔋 High | 10+ every cycle | ⭐⭐⭐⭐⭐ Very Complex | ❌ Limited | ✅ Yes | Command centers |
| **Smart Grouping** | 🔋🔋 Medium | 10+ during rotation | ⭐⭐⭐⭐ Complex | ⚙️ Some | ✅ Conditional | Scheduled updates |
| **Digest Mode** | ⚡ Minimal | 1 (combined) | ⭐⭐ Moderate | ❌ None | ❌ No | Brief updates |
| **Manual Control** | ⚡ Minimal | On-demand | ⭐⭐ Moderate | ✅ Full | ✅ Manual | User review |
| **Priority-Based** | 🔋🔋 Medium | 10+ during rotation | ⭐⭐⭐⭐ Complex | ⚙️ Priority | ✅ Yes | Mixed importance |
| **Time-Slot** | 🔋🔋 Medium | Varies | ⭐⭐⭐⭐⭐ Very Complex | ❌ Limited | ✅ Yes | Office displays |
| **Notification + Latest** | ⚡ Minimal | 10 (once) | ⭐ Simple | ✅ Full | ❌ No | Personal boards |
| **🏆 HYBRID (Recommended)** | ⚡ Minimal | 10 (once) | ⭐⭐ Moderate | ✅ Full | ⚙️ Optional | **Most users** |

### Scoring Criteria

- **Battery Impact**: ⚡ Minimal → 🔋🔋🔋 High
- **Complexity**: ⭐ Simple → ⭐⭐⭐⭐⭐ Very Complex
- **Control**: ❌ None → ⚙️ Some → ✅ Full

---

## Recommendation

### Recommended Solution: Hybrid Approach

**Choice**: **Solution 8 - Hybrid: Smart Latest + Widget Carousel + User Control**

### Why This Solution?

#### 1. **User Experience**

**For Viewers at the Board:**
- Physical board shows latest message (most relevant)
- Clear, uninterrupted display (no confusing rotation)
- If viewer wants older messages → check phone/widget

**For Message Senders:**
- All messages sent immediately (no delay)
- Confidence that message is on board
- Can review all messages in app history
- Optional manual rotation if desired

**For Casual Observers:**
- Widget shows rotating carousel (passive awareness)
- No battery drain on phone
- Can dive deeper in app if interested

#### 2. **Technical Feasibility**

**Advantages:**
- ✅ Uses existing delivery infrastructure
- ✅ No background rotation needed (iOS limitation)
- ✅ Minimal battery impact
- ✅ No rate limiting concerns
- ✅ Simple state management
- ✅ Works offline (cached messages)

**Implementation Complexity: Moderate (2-3 days)**
- Enhance widget to show carousel
- Add manual rotation controls in app
- Optional: Add digest mode for bursts
- Update UI to show message count

#### 3. **Addresses User's Core Need**

**User's Problem**: "10 messages sent, only last one visible"

**Solution Addresses:**
- ✅ Latest message IS visible on board
- ✅ All messages preserved in history
- ✅ Widget provides carousel view
- ✅ User can manually rotate if needed
- ✅ Optional digest combines related messages

**What About the "Rotation" Request?**

The user's request for rotation comes from a valid concern: **early messages disappear**. However, automatic rotation introduces significant problems:

- Battery drain
- Viewer confusion
- Background update limitations
- API rate limiting risks

**The hybrid approach solves the underlying problem (message visibility) without the downsides of automatic rotation.**

#### 4. **Scalability**

**Handles Edge Cases:**
- 1 message → Shows on board (simple)
- 2-3 messages in burst → Optional digest mode
- 10+ messages in burst → Latest on board, all in widget/app
- Mixed priorities → User can manually rotate important ones
- Multi-device → Latest-write-wins (existing behavior)

#### 5. **Aligns with Platform Best Practices**

**iOS Widget Design:**
- Widgets are meant for glanceable, updating content
- Perfect for message carousel
- 15-minute refresh aligns with WidgetKit
- Low battery impact

**Vestaboard Usage Patterns:**
- Physical board for primary message
- Digital devices for history/details
- Manual interaction for advanced features

---

## Implementation Plan

### Phase 1: Enhanced Widget Carousel (Priority 1)

**Goal**: Widget shows rotating carousel of recent messages

**Components to Build:**

1. **`MessageCarouselEntry.swift`**
   - Model for carousel state
   - Tracks current message index
   - Contains array of recent messages

2. **Update `WidgetTimelineProvider.swift`**
   - Generate timeline with rotating messages
   - Each entry shows different message from history
   - Include "Message X of Y" indicator

3. **Update Widget Views**
   - Show current message from carousel
   - Display carousel indicator ("3 of 10")
   - Visual cue that more messages exist

**Effort**: 4-6 hours

---

### Phase 2: Message History UI Enhancement (Priority 2)

**Goal**: App shows comprehensive message history with manual controls

**Components to Build:**

1. **Update `MessageHistoryView.swift`**
   - Show all messages with timestamps
   - "Send to Board" button per message (manual rotation)
   - Bulk actions (send all, clear history)
   - Search/filter capabilities

2. **`MessageHistoryViewModel.swift`**
   - Manages history state
   - Handles manual rotation
   - Pagination for long history

**Effort**: 4-6 hours

---

### Phase 3: Smart Digest Mode (Priority 3 - Optional)

**Goal**: Combine burst messages into single digest display

**Components to Build:**

1. **`MessageDigestService.swift`**
   - Detects burst scenarios (3+ messages in 2 minutes)
   - Combines messages into formatted digest
   - Respects 6×22 board constraints

2. **`DigestFormatter.swift`**
   - Formats multiple messages as bullet list
   - Truncates intelligently
   - Adds "3 UPDATES" header

3. **Settings Toggle**
   - "Enable Smart Digest" setting
   - Configure: burst window, max messages

**Effort**: 6-8 hours

---

### Phase 4: Manual Carousel Control (Priority 4 - Optional)

**Goal**: User can manually rotate through messages on physical board

**Components to Build:**

1. **`ManualCarouselView.swift`**
   - SwiftUI view with [Prev] [Next] buttons
   - Shows "Message 3 of 10"
   - Displays current message content

2. **`ManualCarouselViewModel.swift`**
   - Manages carousel state
   - Handles prev/next navigation
   - Sends message to board on navigation

**Effort**: 4-6 hours

---

### Total Implementation Effort

- **Phase 1 (Required)**: 4-6 hours
- **Phase 2 (Recommended)**: 4-6 hours
- **Phase 3 (Optional)**: 6-8 hours
- **Phase 4 (Optional)**: 4-6 hours

**Minimum Viable**: 8-12 hours (Phases 1-2)
**Full Featured**: 18-26 hours (All phases)

---

## Edge Cases & Challenges

### Edge Case 1: New Message During Widget Carousel

**Scenario:**
```
Widget is showing Message #3 of 10
User sends Message #11
```

**Solution:**
- Latest message (#11) sent to board immediately
- Widget timeline regenerates with 11 messages
- Next widget refresh shows updated carousel
- Carousel now cycles through all 11 messages

**Result**: Graceful, no special handling needed

---

### Edge Case 2: Message Burst Detection (Digest Mode)

**Scenario:**
```
User sends Message #1 at 2:00:00
User sends Message #2 at 2:01:59 (within 2-min window)
User sends Message #3 at 2:04:30 (outside window)
```

**Solution:**
- Messages #1-2 → Digest created (within window)
- Message #3 → Separate message (outside window)
- Board shows: Digest of #1-2
- 1 second later: Message #3 overwrites

**Alternative**: Extend window on new messages (rolling window)

---

### Edge Case 3: Manual Rotation + Auto-Send Conflict

**Scenario:**
```
User is manually rotating messages (Message #5 visible)
Another user sends new message
```

**Solution:**
- New message sent to board (overwrites #5)
- Manual rotation stops (latest message takes priority)
- User can resume manual rotation from app

**UI Feedback**: "New message received. Carousel paused."

---

### Edge Case 4: Empty History

**Scenario:**
```
User opens widget/app
No messages sent yet
```

**Solution:**
- Widget shows: "Send your first message!"
- App shows: Empty state with "Compose" CTA
- No carousel (nothing to rotate)

---

### Edge Case 5: Very Long Message History

**Scenario:**
```
User has 100+ messages in history
Widget carousel would cycle through 100 messages
```

**Solution:**
- Limit widget carousel to recent X messages (default: 10)
- App shows full history with pagination
- Setting: "Widget Carousel Size" (5/10/20/All)

---

### Edge Case 6: Digest Too Long for Board

**Scenario:**
```
User sends 5 messages in burst
Combined digest exceeds 6×22 limit (132 chars)
```

**Solution:**
- Truncate older messages first
- Show "...+2 more" at bottom
- Full messages available in app
- Alternative: Send digest as multiple screens (digest rotation)

---

### Technical Challenge 1: Widget Timeline Limits

**Issue**: WidgetKit limits timeline entries

**Solution:**
- Generate up to 96 entries (24 hours / 15 min)
- Each entry shows next message in carousel
- When timeline exhausted, widget refreshes

---

### Technical Challenge 2: App Group Storage Size

**Issue**: Storing 100+ messages in UserDefaults

**Solution:**
- Limit stored history to 50 messages (configurable)
- Older messages archived or deleted
- Setting: "History Size" (25/50/100/Unlimited)

---

### Technical Challenge 3: Message Formatting for Digest

**Issue**: Different message lengths, formatting

**Solution:**
- Normalize to uppercase (Vestaboard standard)
- Truncate to 18 chars per line (leave space for bullet)
- Use standard bullet character (• or -)
- Smart truncation (preserve whole words)

---

## Conclusion

### Summary

**Problem**: 10 messages sent in 1 minute, only last message visible

**Analysis**: Automatic rotation has significant downsides (battery, complexity, UX)

**Recommendation**: Hybrid approach (Smart Latest + Widget Carousel + Manual Control)

**Rationale**:
- ✅ Solves core problem (message visibility)
- ✅ Battery efficient (no background rotation)
- ✅ Simple, predictable behavior
- ✅ User controls when/if to rotate
- ✅ Widget provides passive awareness
- ✅ App provides full history and control

**Implementation**: Moderate effort (8-12 hours MVP, 18-26 hours full-featured)

---

### Next Steps

1. **Get User Confirmation** on recommended approach
2. **Implement Phase 1**: Enhanced Widget Carousel
3. **Implement Phase 2**: Message History UI
4. **User Testing**: Validate UX with real scenarios
5. **Optional Phases**: Based on user feedback

---

### Alternative Paths

If user absolutely requires **physical board rotation**:

**Fallback**: Implement **Solution 2 (Smart Grouping)** with:
- Configurable grouping window (default: 2 min)
- Configurable rotation duration (default: 60 sec)
- Battery warning in settings
- Manual start/stop controls
- Completion behavior: stop at last message

**Effort**: 2-3 days (significantly more complex)

**Recommendation**: Start with hybrid approach, add rotation later if truly needed

---

**Document Status**: Ready for Implementation
**Recommendation**: **Hybrid Approach (Solution 8)**
**Next Action**: Implement Phase 1 & 2

