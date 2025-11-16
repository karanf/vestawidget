# VestaWidget Message Carousel & Digest System
## User Guide

**Version**: 1.0.0
**Last Updated**: 2025-11-16

---

## Overview

VestaWidget now includes a **smart message handling system** that elegantly deals with multiple messages sent in a short timeframe. Instead of implementing battery-draining automatic rotation on the physical board, we use a **hybrid approach** that provides the best user experience across all devices.

### What's New?

1. **Widget Carousel**: iOS widgets rotate through your recent messages automatically
2. **Smart Digest Mode**: Multiple messages can be combined into a single summary view
3. **Enhanced History**: Full message history with manual controls in the app
4. **Carousel Indicators**: See "Message 3 of 10" in widgets to know there's more

---

## How It Works

### The Scenario: 10 Messages in 1 Minute

**What happens now:**

```
You send 10 messages within 1 minute
    ↓
📱 iPhone Widget: Rotates through all 10 messages every 15 minutes
📺 Physical Vestaboard: Shows the latest message (Message #10)
📖 App History: Shows all 10 messages with timestamps
```

**Why this approach?**

- **Physical Board**: Shows most recent (most relevant) message
- **Battery Efficient**: No constant API calls needed
- **Widget Carousel**: Passive awareness of all messages
- **User Control**: Can manually view/send any message from history

---

## Features

### 1. Widget Carousel

**What is it?**
Your iOS widgets automatically rotate through recent messages, showing a different message every 15 minutes.

**How it works:**
- Widgets refresh every 15 minutes (iOS standard)
- Each refresh shows the next message in your history
- Displays "Message 3 of 10" indicator
- Cycles through up to 10 most recent messages

**Example:**
```
2:00 PM - Widget shows Message #1 "Meeting at 2pm"
2:15 PM - Widget shows Message #2 "Lunch order by 1pm"
2:30 PM - Widget shows Message #3 "Deploy at 3pm"
2:45 PM - Widget shows Message #1 again (loop)
```

**To view:**
- Add VestaWidget to your home screen (any size)
- Widget automatically rotates through messages
- Tap widget to open app for full history

---

### 2. Smart Digest Mode

**What is it?**
When you send 3+ messages within 2 minutes, VestaWidget can automatically combine them into a single summary display on your board.

**How it works:**
- Detects "burst" of messages (3+ within 2 minutes)
- Combines messages into bullet-point format
- Sends single digest to board
- Fits within Vestaboard's 6×22 character limit

**Example Digest:**

```
╔════════════════════════╗
║     3 UPDATES          ║
║                        ║
║ • MEETING AT 2PM       ║
║ • LUNCH ORDER BY 1PM   ║
║ • DEPLOY AT 3PM        ║
╚════════════════════════╝
```

**When to use:**
- Sending multiple related updates (task list, reminders)
- Brief messages (< 20 characters each)
- Want all messages visible at once
- 2-4 messages work best

**Limitations:**
- Max 4 messages shown (5th+ shown as "+2 more")
- Messages truncated to ~20 characters
- Long messages lose detail

---

### 3. Enhanced Message History

**What is it?**
The app now shows complete message history with advanced controls.

**Features:**
- View all sent messages with timestamps
- "Send to Board" button on each message (manual rotation)
- Search and filter messages
- Bulk actions (clear history, resend all)
- Message status indicators

**How to use:**

1. **View History:**
   - Open app → "Message History" tab
   - See all messages chronologically
   - Tap message to expand details

2. **Manual Rotation:**
   - Find message in history
   - Tap "Send to Board" button
   - Message appears on physical board immediately

3. **Bulk Send:**
   - Select multiple messages
   - Tap "Send All to Board"
   - Messages send sequentially (1 second apart)

---

### 4. Carousel Indicators

**What are they?**
Visual indicators in widgets showing your position in the message carousel.

**Types:**

- **Full**: "Message 3 of 10" (Medium/Large widgets)
- **Short**: "3/10" (Small widget)
- **Icon**: Circular arrows icon (indicates carousel mode)

**When shown:**
- Only when you have 2+ messages in history
- Updates with each widget refresh
- Disappears if only 1 message exists

---

## Common Scenarios

### Scenario 1: Single Message

**You send:** "Meeting in 5 minutes"

**Result:**
- Physical Board: Shows "Meeting in 5 minutes"
- Widget: Shows same message (no carousel)
- History: Shows 1 message
- Indicator: None (single message)

**Recommendation:** Nothing special needed. Works like before.

---

### Scenario 2: Multiple Messages (No Burst)

**You send:**
- 9:00 AM: "Good morning team!"
- 12:00 PM: "Lunch at 1pm"
- 3:00 PM: "Deploy complete"

**Result:**
- Physical Board: Shows "Deploy complete" (latest)
- Widget: Rotates through all 3 messages
- History: Shows all 3 with timestamps
- Indicator: "Message 1 of 3", "Message 2 of 3", etc.

**Recommendation:** Widget provides passive awareness. Check history for older messages.

---

### Scenario 3: Message Burst (Digest Mode ON)

**You send (within 1 minute):**
- "Meeting at 2pm"
- "Lunch order by 1pm"
- "Deploy at 3pm"

**Result:**
- Physical Board: Shows digest (all 3 combined)
- Widget: Shows same digest
- History: Shows all 3 individual messages
- Digest Message: Appears as special "digest" entry

**Recommendation:** Great for task lists. All visible at once.

---

### Scenario 4: Message Burst (Digest Mode OFF)

**You send (within 1 minute):**
- "Message 1"
- "Message 2"
- ...
- "Message 10"

**Result:**
- Physical Board: Shows "Message 10" (latest)
- Widget: Rotates through all 10
- History: Shows all 10
- Indicator: "Message 1 of 10", etc.

**Recommendation:** Widget carousel lets you see all messages over time.

---

### Scenario 5: Manual Rotation

**You want to show old message on board**

**How to:**
1. Open app → Message History
2. Find old message (e.g., "Meeting at 2pm" from yesterday)
3. Tap "Send to Board" button
4. Message appears on board immediately

**Result:**
- Physical Board: Shows selected message
- Widget: Updates to show current board state
- History: Message marked as "resent"

**Recommendation:** Use when you need to bring back important messages.

---

## Settings & Configuration

### Digest Settings

**Location:** App → Settings → Message Digest

**Options:**

1. **Enable Smart Digest** (ON/OFF)
   - Turns digest mode on/off
   - Default: ON

2. **Burst Detection Window**
   - How quickly messages must arrive to be grouped
   - Options: 1 min, 2 min (default), 5 min, 10 min

3. **Minimum Messages for Digest**
   - How many messages trigger digest
   - Options: 2, 3 (default), 4, 5

4. **Max Messages in Digest**
   - How many messages to show in digest
   - Options: 3, 4 (default), 5, 6

**Recommendations:**
- **Personal board**: Keep defaults (2 min window, 3 min messages)
- **Shared board**: Increase window to 5 min to catch more messages
- **Brief updates**: Set max to 5-6 messages
- **Long messages**: Disable digest (messages get truncated)

---

### Widget Carousel Settings

**Location:** App → Settings → Widget Carousel

**Options:**

1. **Carousel Size**
   - How many messages to include in rotation
   - Options: 5, 10 (default), 20, All

2. **Show Carousel Indicator** (ON/OFF)
   - Shows "Message X of Y" in widget
   - Default: ON

**Recommendations:**
- **10 messages**: Good balance (default)
- **All messages**: If you have few messages (<20)
- **5 messages**: Faster rotation, recent messages only

---

## Tips & Best Practices

### When to Use Digest Mode

✅ **Good for:**
- Task lists ("Meeting at 2pm", "Lunch at 1pm", "Deploy at 3pm")
- Brief reminders (< 20 characters each)
- Related updates
- 2-4 messages

❌ **Not good for:**
- Long messages (get truncated)
- 5+ messages (overflow not visible)
- Unrelated messages (confusing)
- Time-sensitive updates (hard to distinguish)

---

### When to Use Widget Carousel

✅ **Good for:**
- Passive awareness of recent messages
- Glancing at phone to see different message
- Knowing "there are more messages"
- Personal use

❌ **Not good for:**
- Urgent messages (might miss during rotation)
- Real-time updates (15-minute delay)
- Single message scenarios (no benefit)

---

### When to Use Manual Rotation

✅ **Good for:**
- Reviewing specific old messages
- Highlighting important message
- Demonstrating message to someone at board
- Testing different messages

❌ **Not good for:**
- Automated scenarios (use digest instead)
- Frequently changing messages (just send new one)

---

## Troubleshooting

### Widget Not Rotating

**Symptoms:**
- Widget shows same message for hours
- No carousel indicator visible
- "Message 1 of 1" or no indicator

**Solutions:**
1. ✅ Check message history (need 2+ messages)
2. ✅ Wait 15 minutes (widget refresh interval)
3. ✅ Manually refresh widget (tap widget → opens app)
4. ✅ Remove and re-add widget
5. ✅ Ensure Widget Carousel enabled in settings

---

### Digest Not Creating

**Symptoms:**
- Sent 3+ messages quickly
- Board shows last message (not digest)
- No digest in history

**Solutions:**
1. ✅ Check Settings → Digest Mode (ensure enabled)
2. ✅ Check burst window (messages must be within window)
3. ✅ Check minimum messages (need 3+ by default)
4. ✅ Ensure messages sent within configured window (default: 2 min)

---

### Carousel Indicator Not Showing

**Symptoms:**
- Widget shows content but no "Message X of Y"
- Should be rotating but no indicator

**Solutions:**
1. ✅ Check Settings → Show Carousel Indicator (ensure ON)
2. ✅ Ensure 2+ messages in history
3. ✅ Widget size supports indicator (Small uses "3/10", Medium/Large use full)
4. ✅ Update to latest widget timeline (wait 15 min or refresh)

---

### Messages Not Appearing in History

**Symptoms:**
- Sent message but not in history
- History shows wrong count

**Solutions:**
1. ✅ Ensure message sent successfully (check delivery status)
2. ✅ Refresh app (pull to refresh on history screen)
3. ✅ Check history size limit (Settings → max history)
4. ✅ Verify app has App Group access (Settings → About)

---

## Frequently Asked Questions

### Q: Does the physical board auto-rotate through messages?

**A:** No. The physical board shows the **latest message only**. This is intentional for battery efficiency and user experience. The widget rotates instead.

**Why?**
- Auto-rotating the board requires constant API calls (every 30-60 seconds)
- Drains battery significantly
- Confusing for viewers (walk up mid-rotation, see random message)
- iOS limits background updates
- Viewers don't know it's rotating

**Alternative:** Use the widget for rotation, or manually send old messages from history.

---

### Q: Can I control the rotation speed?

**A:** Widget rotation is tied to iOS's 15-minute refresh interval. This cannot be changed (iOS limitation).

**Why?**
- iOS restricts widget updates to preserve battery
- Faster updates drain battery
- 15 minutes is the minimum for automatic updates

**Alternative:** Use manual rotation from app for immediate control.

---

### Q: What happens if I send a new message during widget rotation?

**A:** The new message:
- Appears on physical board immediately (overwrites)
- Gets added to widget carousel
- Widget timeline regenerates with updated messages
- Next refresh includes new message in rotation

No special handling needed. Everything updates seamlessly.

---

### Q: Can I rotate messages backward (previous message)?

**A:** Not automatically in widgets (iOS limitation). But you can:
- Use Message History → "Send to Board" on any old message
- Manually select and send specific message
- Widget will update to show current board state

---

### Q: How long does message history keep messages?

**A:** By default, 50 messages are kept. Configurable in Settings → Message History → History Size.

**Options:**
- 25 messages (lightweight)
- 50 messages (default)
- 100 messages (more history)
- Unlimited (all messages, may impact performance)

Oldest messages are removed when limit reached.

---

### Q: Does digest work with long messages?

**A:** Not well. Digest truncates messages to ~20 characters per line.

**Example:**
- Original: "Please remember to submit your timesheet by end of day Friday"
- Digest: "• PLEASE REMEMBER T…"

**Recommendation:** Use digest only for brief updates. Long messages should be sent individually.

---

### Q: Can I customize the digest format?

**A:** Not currently. Digest uses standard format:
- Header: "X UPDATES"
- Bullet points for each message
- "+X MORE" if overflow

Future versions may add customization.

---

### Q: What if multiple people send messages?

**A:** VestaWidget handles this gracefully:
- All messages added to history (regardless of sender)
- Digest groups messages from ALL senders
- Last message wins on physical board (existing behavior)
- Widget rotates through all messages (from all users)

**Note:** Digest doesn't distinguish between senders. All messages combined.

---

### Q: Can I disable carousel completely?

**A:** Yes. Settings → Widget Carousel → Carousel Size → 1 Message.

This shows only the latest message (no rotation).

---

### Q: Does carousel work offline?

**A:** Partially:
- Widget carousel uses cached messages (works offline)
- Can view message history offline
- Manual "Send to Board" requires network
- New messages require network

Widget rotation continues offline with cached data.

---

## Advanced Use Cases

### Use Case 1: Morning Announcements

**Goal:** Display 3 different announcements throughout the day

**Setup:**
1. Disable Digest Mode (Settings → Digest → OFF)
2. Set Widget Carousel Size → 3 Messages
3. Send 3 announcements in quick succession

**Result:**
- Board shows latest announcement
- Widget rotates through all 3 (every 15 minutes)
- Users see different announcement each time they check phone

---

### Use Case 2: Task List Display

**Goal:** Show today's tasks on board (all visible at once)

**Setup:**
1. Enable Digest Mode (Settings → Digest → ON)
2. Set Burst Window → 5 minutes
3. Set Max Messages → 6
4. Send all tasks within 5 minutes

**Result:**
- Board shows digest with all tasks
- Widget shows same digest
- History shows individual tasks

---

### Use Case 3: Message Review

**Goal:** Review past week's messages on board

**Setup:**
1. Open App → Message History
2. Filter messages (last 7 days)
3. Use "Send to Board" on each message
4. Board updates with each selection

**Result:**
- Manually control what appears on board
- Review messages one by one
- Return to latest when done

---

## Support

**Need help?**
- Check Message History for delivery errors
- Review Settings for configuration
- See CAROUSEL_ANALYSIS.md for technical details
- Contact support with error messages

**Report issues:**
- Include: iOS version, widget size, message count
- Attach: Screenshots of widget and settings
- Describe: Expected vs. actual behavior

---

## What's Next?

### Planned Features

- **Manual carousel controls in widget**: Skip to next/previous message
- **Widget configuration**: Choose which messages to show
- **Custom digest templates**: Customize digest format
- **Scheduled digest**: Send digest at specific time
- **Priority messages**: Mark messages as high-priority (stays on board longer)

### How to Provide Feedback

Your feedback shapes VestaWidget's future! Let us know:
- What features you use most
- What's confusing or unclear
- What features you'd like to see
- How you use VestaWidget

---

## Quick Reference

### Key Concepts

- **Physical Board**: Shows latest message only (battery efficient)
- **Widget Carousel**: Rotates through recent messages (15-min intervals)
- **Smart Digest**: Combines burst messages into single view
- **Message History**: Full control over all messages

### Default Settings

- Digest Mode: **ON**
- Burst Window: **2 minutes**
- Min Messages for Digest: **3**
- Max Messages in Digest: **4**
- Widget Carousel Size: **10 messages**
- Show Carousel Indicator: **ON**
- History Size: **50 messages**

### Keyboard Shortcuts

- **Send Message**: ⌘ + Return
- **Open History**: ⌘ + H
- **Settings**: ⌘ + ,
- **Refresh**: ⌘ + R

---

**Last Updated**: 2025-11-16
**Document Version**: 1.0.0
**App Version**: 1.0.0+

