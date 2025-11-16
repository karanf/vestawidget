# VestaWidget Product Requirements Document

**Version:** 1.0
**Last Updated:** 2025-11-16
**Product Owner:** TBD
**Engineering Lead:** TBD

---

## 1. Executive Summary

### Product Overview

VestaWidget is a multi-platform messaging widget system for iOS, macOS, and visionOS that brings the nostalgic charm of split-flap displays (like the iconic Vestaboard) to digital screens. Users can send ephemeral messages to friends and family that animate with realistic split-flap motion, complete with authentic clicking sounds and mid-century modern aesthetics.

Unlike traditional messaging apps, VestaWidget displays only the most recent message—creating a unique, present-focused communication experience. Messages appear as beautiful homescreen, lockscreen, or desktop widgets, transforming devices into personal message boards that blend digital convenience with analog warmth.

### Target Audience

**Primary Audience:**
- Couples and close friends who want a dedicated, intimate messaging channel
- Families staying connected across distances
- Colleagues sharing quick updates or inspirational quotes
- Design-conscious users who appreciate retro-futuristic aesthetics
- Apple ecosystem enthusiasts (iPhone, Mac, Apple Watch, Vision Pro owners)

**Secondary Audience:**
- Artists and designers using it for creative expression
- Remote teams using it for daily stand-up updates
- Gift-givers looking for unique digital experiences

### Key Differentiators

1. **Authentic Split-Flap Simulation**: Realistic 3D animation with sequential character flipping, clicking sounds, and haptic feedback
2. **Ephemeral by Design**: No message history—only the present moment matters
3. **Widget-First Experience**: Native integration with iOS homescreen, lockscreen, macOS desktop, and visionOS spaces
4. **Multi-Recipient Broadcasting**: Send one message to multiple recipients simultaneously
5. **Multi-Sender Display**: Receive and display messages from different senders
6. **Rich Content Support**: Text, emoji, unicode, and abstract color pattern art
7. **Cross-Platform Apple Ecosystem**: Seamless experience across iPhone, iPad, Mac, and Vision Pro

---

## 2. Product Goals & Success Metrics

### Primary Objectives

1. **Deliver Delightful Messaging**: Create a messaging experience that brings joy through beautiful animation and sound design
2. **Simplify Intimate Communication**: Remove friction from sending quick messages to close contacts
3. **Widget Adoption**: Drive daily engagement through widget placement on homescreens and lockscreens
4. **Platform Showcase**: Demonstrate best-in-class SwiftUI and WidgetKit implementation

### Key Performance Indicators (KPIs)

**Engagement Metrics:**
- Daily Active Users (DAU) / Monthly Active Users (MAU) ratio > 40%
- Average messages sent per user per day > 2
- Widget installation rate > 80% of users
- Message response rate > 60% within 24 hours
- Session frequency: Average 3+ app opens per day

**Technical Metrics:**
- Message delivery latency < 2 seconds (p95)
- Widget refresh success rate > 95%
- Animation frame rate > 60 fps on supported devices
- Crash-free session rate > 99.5%

**Growth Metrics:**
- Month-over-month user growth > 15%
- Viral coefficient (invites sent per user) > 1.5
- Week 1 retention > 50%
- Week 4 retention > 30%

**User Satisfaction:**
- App Store rating > 4.5 stars
- NPS (Net Promoter Score) > 50
- Animation quality rating > 4.7/5

---

## 3. User Personas & Use Cases

### User Persona 1: The Romantic Partner

**Name:** Emma, 28
**Occupation:** Marketing Manager
**Devices:** iPhone 15 Pro, MacBook Air, Apple Watch
**Tech Savvy:** High

**Behaviors & Motivations:**
- Wants to stay connected with long-distance partner
- Sends good morning/good night messages daily
- Appreciates thoughtful, curated communication over chat noise
- Values aesthetic, beautiful digital experiences
- Willing to pay for premium features

**Pain Points:**
- Regular messaging apps feel too cluttered
- Message history creates pressure to respond to everything
- Wants something more special than iMessage for partner

**Use Case:** Emma sends her partner a morning message that appears as an animated widget on his lockscreen when he wakes up. The split-flap animation brings a smile to his face, and he sends a quick emoji reply that flips onto her homescreen widget.

---

### User Persona 2: The Family Connector

**Name:** David, 45
**Occupation:** Software Engineer
**Devices:** iPhone 14, iPad Pro, Mac Studio
**Tech Savvy:** Very High

**Behaviors & Motivations:**
- Manages family communication across time zones
- Sends updates to parents, siblings, and kids
- Appreciates nostalgia and retro design
- Early adopter of new Apple technologies
- Wants fun ways to engage with technology

**Pain Points:**
- Family group chats become overwhelming
- Difficult to send quick updates without long conversations
- Wants everyone to see important messages prominently

**Use Case:** David sends a message to his family group announcing dinner plans. The message flips onto lockscreen widgets for his wife, kids, and parents simultaneously. Everyone sees it without needing to open an app.

---

### User Persona 3: The Creative Professional

**Name:** Priya, 32
**Occupation:** Graphic Designer
**Devices:** iPhone 15 Pro Max, MacBook Pro, Vision Pro
**Tech Savvy:** High

**Behaviors & Motivations:**
- Uses devices as creative canvases
- Explores new design tools and experiences
- Creates daily inspiration for design team
- Values craft and attention to detail
- Experiments with color and typography

**Pain Points:**
- Wants more creative messaging options
- Desires tools that blend art and communication
- Seeks unique ways to express ideas visually

**Use Case:** Priya creates an abstract color pattern message using the app's pattern composer and sends it to her design team. The pattern animates across their widgets throughout the day, serving as shared visual inspiration.

---

### Primary Use Cases

#### Use Case 1: Good Morning Message
**Actor:** User A (sender)
**Goal:** Send morning greeting to partner

**Flow:**
1. User wakes up, opens VestaWidget app
2. Selects partner from favorites
3. Types "Good morning, love you! ☀️"
4. Previews split-flap animation
5. Taps send
6. Message delivers to partner's lockscreen widget
7. Partner wakes up, sees animated message on lockscreen
8. Widget plays flip animation with sound

**Success Criteria:** Message delivers within 2 seconds, animation plays smoothly at 60fps

---

#### Use Case 2: Multi-Recipient Broadcast
**Actor:** User B (sender)
**Goal:** Announce event to family group

**Flow:**
1. Opens app, taps "New Message"
2. Selects multiple recipients: Mom, Dad, Sister
3. Types "Sunday BBQ at 3pm, bring dessert!"
4. Confirms send to all
5. Message fans out to all recipients
6. Each recipient's widget updates independently
7. Recipients see message on homescreens/lockscreens

**Success Criteria:** All recipients receive message within 3 seconds, no delivery failures

---

#### Use Case 3: Multi-Sender Monitoring
**Actor:** User C (recipient)
**Goal:** Monitor messages from boss and spouse

**Flow:**
1. User adds two widgets: one for spouse, one for boss
2. Spouse sends "Running late, start dinner without me"
3. First widget animates with spouse's message
4. Boss sends "Meeting moved to 4pm"
5. Second widget animates with boss's message
6. User sees both messages on homescreen without opening app

**Success Criteria:** Widgets update independently, correct sender attribution, no message mixing

---

#### Use Case 4: Emoji & Pattern Creation
**Actor:** User D (creator)
**Goal:** Send creative color pattern

**Flow:**
1. Opens app, taps "Create Pattern"
2. Enters pattern composer mode (grid interface)
3. Selects colors from palette or uses emoji
4. Arranges pattern in 6x22 grid (Vestaboard dimensions)
5. Previews animation
6. Sends to friend
7. Friend's widget displays colorful animated pattern

**Success Criteria:** Pattern renders correctly, colors match exactly, animation smooth

---

#### Use Case 5: First-Time Setup
**Actor:** New User
**Goal:** Get started with VestaWidget

**Flow:**
1. Downloads app from App Store
2. Opens app, sees onboarding
3. Creates account (email or phone)
4. Grants notification permissions
5. Adds first widget to homescreen (guided)
6. Invites first friend via contact picker
7. Sends first test message
8. Sees animation play on widget

**Success Criteria:** Setup completes in < 3 minutes, user sends first message successfully

---

## 4. Feature Requirements

### 4.1 Core Features

#### 4.1.1 Split-Flap Display Simulation ⭐ (MVP)

**Description:** Authentic recreation of mechanical split-flap display animation with realistic physics, sound, and visual design.

**Requirements:**

**Animation System:**
- 3D rotating character flaps using SwiftUI's `rotation3DEffect`
- Sequential character progression (must flip through all intermediate characters)
- Configurable flip timing: 50-200ms per character (default 120ms)
- Easing function: `easeInOut` or custom cubic bezier
- Perspective depth: 600-800px equivalent
- Hardware-accelerated rendering using Metal where possible

**Character Set:**
- Standard 40-character set: [blank], A-Z, 0-9, !, ?, +
- Extended 52-character set: Add emojis (❤️, 👍, 🎉, ⭐, etc.)
- Case normalization: Auto-convert to uppercase for mechanical authenticity
- Character sequence order: blank → A-Z → 0-9 → symbols

**Visual Design:**
- Character split: Horizontal line at exact vertical midpoint
- Color scheme: White (#FFFFFF) text on black (#000000) background
- Alternate themes: Black text on white, custom color modes
- Typography: SF Pro Rounded Bold (Apple native) or custom split-flap font
- Shadow effects: Inner shadows for depth (`inset 2px 2px 15px #444`)
- Flap gap: 2pt gap between upper and lower halves
- Grid layout: 6 rows × 22 columns (132 characters total, matching Vestaboard)
- Module borders: 1pt separator lines between characters

**Sound Design:**
- Authentic "clack" sound (50-100ms duration)
- Positional audio: Trigger at 90° rotation point
- Volume variation: Slight randomization (±10%) for organic feel
- Multi-character timing: Overlapping sounds for simultaneous flips
- Sound toggle: User preference to enable/disable
- Haptic feedback: Light impact haptics synchronized with sound (iOS)

**Performance:**
- Target: 60fps animation on iPhone 12 and newer
- Graceful degradation: 30fps on older devices (iPhone X-11)
- Lazy loading: Only animate visible characters in viewport
- Animation queue: Limit simultaneous flips based on device capability
- Memory footprint: < 50MB for full animation system

**Accessibility:**
- VoiceOver: Read final message content, skip animation
- Reduce Motion: Instant character change without flipping
- Reduce Transparency: Disable shadow effects
- High Contrast: Increase character stroke weight

**Technical Implementation:**
```swift
struct SplitFlapCharacter: View {
    let character: Character
    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            // Upper flap
            Text(String(character).prefix(1))
                .mask(Rectangle().frame(height: height/2), alignment: .top)
                .rotation3DEffect(.degrees(rotation), axis: (1, 0, 0))

            // Lower flap
            Text(String(character).prefix(1))
                .mask(Rectangle().frame(height: height/2), alignment: .bottom)
                .rotation3DEffect(.degrees(rotation + 180), axis: (1, 0, 0))
        }
        .animation(.easeInOut(duration: 0.12), value: rotation)
    }
}
```

**Acceptance Criteria:**
- [ ] Animation runs at minimum 60fps on iPhone 12+
- [ ] Sequential flipping through character set works correctly
- [ ] Sound synchronized within ±20ms of visual flip
- [ ] Reduce Motion setting disables animation
- [ ] Memory usage < 50MB during animation
- [ ] Works offline (animation only, no message delivery)

---

#### 4.1.2 Message Composition & Sending ⭐ (MVP)

**Description:** Interface for creating and sending messages with text, emoji, and pattern support.

**Requirements:**

**Text Composer:**
- Full-screen composition interface
- Live character counter: Show X/132 characters used
- Real-time preview: Miniature split-flap preview as user types
- Character validation: Only allow supported characters, show error for invalid
- Auto-capitalization: Convert to uppercase with toggle override
- Line breaks: Support 6 lines max, 22 characters per line
- Emoji picker: Quick access to extended character set
- Smart suggestions: Recent messages, suggested phrases

**Pattern Composer:**
- Grid interface: 6×22 touch-responsive grid
- Color palette: 8 predefined colors matching Vestaboard colors
  - Black, Red, Orange, Yellow, Green, Blue, Violet, White
- Emoji placement: Drag emoji onto grid cells
- Brush mode: Paint multiple cells by dragging
- Fill tool: Flood-fill connected regions
- Clear tool: Reset grid to blank
- Symmetry mode: Mirror patterns horizontally/vertically
- Template library: Pre-made patterns (hearts, stars, gradients)

**Recipient Selection:**
- Contact picker: Integration with system contacts
- Search: Fuzzy search by name, email, phone
- Recents: Most frequently messaged contacts
- Favorites: Star important contacts for quick access
- Multi-select: Tap to select multiple recipients (max 10)
- Group creation: Save recipient groups (e.g., "Family", "Team")
- Visual indicators: Show online/offline status, last seen

**Send Controls:**
- Preview button: Full-screen animation preview before sending
- Send button: Primary CTA, disabled until valid recipient + content
- Schedule send: Optional future delivery time
- Sound preview: Hear flip animation sound
- Estimated animation duration: "Will flip for ~8 seconds"
- Send confirmation: Subtle haptic feedback on successful send

**Validation & Error Handling:**
- Empty message: Show error "Message cannot be empty"
- No recipient: Show error "Select at least one recipient"
- Invalid characters: Highlight and suggest removal
- Network error: Queue message for retry, show pending state
- Rate limiting: Max 50 messages per hour, show cooldown timer

**Technical Implementation:**
```swift
struct MessageComposer: View {
    @State private var message: String = ""
    @State private var selectedRecipients: [User] = []
    @StateObject private var viewModel: MessageComposerViewModel

    var isValid: Bool {
        !message.isEmpty &&
        !selectedRecipients.isEmpty &&
        message.count <= 132 &&
        message.allSatisfy { SplitFlapCharacterSet.contains($0) }
    }

    var body: some View {
        VStack {
            RecipientPicker(selection: $selectedRecipients)
            TextEditor(text: $message)
                .onChange(of: message) { validateMessage($0) }
            CharacterCounter(current: message.count, max: 132)
            AnimationPreview(message: message)
            SendButton(enabled: isValid) {
                viewModel.send(message, to: selectedRecipients)
            }
        }
    }
}
```

**Acceptance Criteria:**
- [ ] Text input validates character set in real-time
- [ ] Character counter updates instantly
- [ ] Multi-recipient selection works (2-10 recipients)
- [ ] Preview shows accurate animation before sending
- [ ] Send fails gracefully with clear error messages
- [ ] Message queues for retry if network unavailable

---

#### 4.1.3 Message Receiving & Display ⭐ (MVP)

**Description:** Widget-based message display with automatic updates and animation playback.

**Requirements:**

**Widget Types:**

*iOS Widgets (WidgetKit):*
- **Small Widget** (2×2): 6×6 character grid, shows truncated message
- **Medium Widget** (4×2): 6×11 character grid, shows half message
- **Large Widget** (4×4): Full 6×22 character grid, complete message
- **Lockscreen Widget** (circular/rectangular): Show latest sender + truncated message
- **StandBy Mode**: Full-screen split-flap display when in landscape charging

*macOS Widgets (WidgetKit):*
- **Small**: 6×11 grid
- **Medium**: 6×22 grid
- **Large**: Double height, 12×22 grid (for multi-sender view)

*visionOS Widgets:*
- **Floating Window**: 3D split-flap display in space
- **Depth**: Characters appear at different Z-depths during flip
- **Spatial Audio**: Positional clicking sounds

**Widget Behavior:**

**Initial State (No Messages):**
- Display placeholder: "No messages yet"
- Subtle animation: Idle flipping through random characters
- Onboarding hint: "Add friends to get started"

**Message Arrival:**
- Push notification triggers widget refresh
- Animation begins immediately when widget visible
- If widget not visible (background): Show final state when viewed
- Timeline entry created with animation metadata

**Animation Playback:**
- Start from previous message (or blank if first message)
- Flip each character sequentially to new message
- Calculate optimal path (forward vs backward through character set)
- Stagger timing: Left-to-right, top-to-bottom cascade (20ms delay per column)
- Total animation duration: Dynamic based on character differences (typically 3-10 seconds)

**Message Persistence:**
- Store only latest message per sender
- No message history stored locally
- Messages expire after 48 hours (auto-clear to blank)
- Deleted messages immediately clear from widget

**Multi-Sender Support:**
- User can install multiple widgets, each tied to specific sender
- Widget configuration: Select which sender to display
- Different widgets update independently
- Widget title shows sender name/avatar

**Interactive Features (iOS 17+):**
- Tap widget: Open app to sender's conversation
- Long press: Quick reply with emoji reactions
- App Intent: "Show message from [name]"

**Offline Behavior:**
- Last received message remains visible
- No animation without network
- Sync on reconnection: Play missed animation

**Technical Implementation:**
```swift
struct VestaWidget: Widget {
    let kind: String = "VestaWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: SelectSenderIntent.self,
            provider: MessageTimelineProvider()
        ) { entry in
            SplitFlapWidgetView(entry: entry)
                .containerBackground(.black, for: .widget)
        }
        .configurationDisplayName("VestaWidget")
        .description("Split-flap message display")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge,
                           .accessoryRectangular, .accessoryCircular])
    }
}

struct MessageTimelineProvider: AppIntentTimelineProvider {
    func timeline(for configuration: SelectSenderIntent,
                  in context: Context) async -> Timeline<MessageEntry> {
        let message = await fetchLatestMessage(from: configuration.sender)
        let entry = MessageEntry(date: Date(),
                                message: message,
                                animationState: .playing)

        // Refresh after animation completes
        let animationDuration = calculateDuration(message)
        let nextUpdate = Date().addingTimeInterval(animationDuration)

        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }
}
```

**Acceptance Criteria:**
- [ ] Widget refreshes within 2 seconds of message arrival
- [ ] Animation plays smoothly in widget (30fps minimum)
- [ ] Multiple widgets for different senders work independently
- [ ] Lockscreen widget displays correctly
- [ ] StandBy mode shows full-screen display
- [ ] Offline behavior: Last message remains visible

---

#### 4.1.4 User Identification & Authentication ⭐ (MVP)

**Description:** Secure user registration and friend connection system.

**Requirements:**

**Account Creation:**
- **Primary Identifier Options:**
  - Email address (validated via confirmation link)
  - Phone number (validated via SMS OTP)
  - Apple ID (Sign in with Apple - preferred)

- **Username Selection:**
  - Unique username (3-20 characters, alphanumeric + underscore)
  - Display name (optional, 1-30 characters, any unicode)
  - Username availability check in real-time

- **Privacy Settings:**
  - Discoverability: Allow/prevent lookup by email/phone
  - Profile visibility: Public, friends-only, private

**Friend Discovery:**
- **Contact Sync:**
  - Request contacts permission
  - Hash phone numbers/emails locally
  - Match against user database
  - Show "Friends using VestaWidget"

- **Search Methods:**
  - Search by username
  - Search by email (if user allows)
  - Search by phone number (if user allows)
  - QR code sharing (in-app QR generator)
  - Deep link sharing: `vestawidget://add/username`

- **Friend Requests:**
  - Send friend request to discovered users
  - Accept/decline incoming requests
  - Notifications for new requests
  - Pending request list

**Friend Management:**
- Friends list: All connected users
- Block user: Prevent receiving messages, hide from search
- Mute user: Receive messages but suppress notifications
- Remove friend: Disconnect, stop message sync
- Friend count limit: Max 100 friends (prevent spam)

**Security & Privacy:**
- **Encryption:** End-to-end encryption for messages (Signal Protocol)
- **Authentication Tokens:** JWT tokens with 30-day expiration
- **Biometric Auth:** Face ID / Touch ID to open app (optional)
- **2FA:** Optional two-factor authentication for account security
- **Rate Limiting:**
  - Max 10 friend requests per day
  - Max 50 messages per hour per user
- **Spam Prevention:**
  - Report user functionality
  - Auto-block users reported by multiple people
  - Shadowban detected spam accounts

**Account Management:**
- Edit profile (username, display name, avatar)
- Change email/phone
- Delete account (permanent, 30-day grace period)
- Export data (GDPR compliance)
- View active sessions, logout remotely

**Technical Implementation:**
```swift
// User Model
struct User: Codable, Identifiable {
    let id: UUID
    var username: String
    var displayName: String?
    var email: String?
    var phoneNumber: String?
    var appleID: String?
    var avatar: URL?
    var createdAt: Date
    var preferences: UserPreferences
}

// Friend Request Model
struct FriendRequest: Codable, Identifiable {
    let id: UUID
    let fromUserID: UUID
    let toUserID: UUID
    var status: RequestStatus
    let createdAt: Date

    enum RequestStatus: String, Codable {
        case pending, accepted, declined
    }
}

// Authentication Service
actor AuthenticationService {
    func signInWithApple(_ authorization: ASAuthorization) async throws -> User
    func signInWithEmail(_ email: String, code: String) async throws -> User
    func signInWithPhone(_ phone: String, otp: String) async throws -> User
    func refreshToken() async throws -> String
    func logout() async
}

// Friend Service
actor FriendService {
    func sendFriendRequest(to userID: UUID) async throws
    func acceptRequest(_ requestID: UUID) async throws
    func declineRequest(_ requestID: UUID) async throws
    func removeFriend(_ userID: UUID) async throws
    func blockUser(_ userID: UUID) async throws
    func fetchFriends() async throws -> [User]
}
```

**Acceptance Criteria:**
- [ ] Sign in with Apple works correctly
- [ ] Email/phone verification completes in < 2 minutes
- [ ] Contact sync finds existing users accurately
- [ ] Friend requests send and receive reliably
- [ ] Blocked users cannot send messages
- [ ] Account deletion removes all data within 30 days

---

#### 4.1.5 Multi-Recipient Broadcasting ⭐ (MVP)

**Description:** Send one message to multiple recipients simultaneously.

**Requirements:**

**Recipient Selection:**
- Multi-select UI: Checkboxes or tag-based selection
- Group creation: Save recipient groups
  - "Family" (Mom, Dad, Sister)
  - "Work Team" (5 colleagues)
  - "Book Club" (8 friends)
- Maximum recipients: 10 per message (prevent spam)
- Visual preview: Show all selected recipients with avatars

**Message Fanout:**
- Backend broadcasts message to all recipients atomically
- Each recipient receives identical message content
- Delivery confirmation per recipient
- Partial failure handling: Some recipients may succeed even if others fail
- Retry logic: Failed deliveries retry up to 3 times with exponential backoff

**Delivery Status Indicators:**
- Per-recipient status:
  - ✓ Delivered (message reached server)
  - ✓✓ Displayed (widget updated on recipient device)
  - ⊘ Failed (permanent delivery failure)
  - ⏱ Pending (queued for delivery)
- Aggregate status: "Delivered to 8/10 recipients"
- Tap to expand: See per-recipient details

**Recipient Experience:**
- Each recipient sees message as if sent directly to them
- No indication of other recipients (privacy)
- Reply sends only to original sender (not group reply)
- Sender attribution: "From [Sender Name]"

**Performance & Scalability:**
- Parallel delivery: Use async tasks for simultaneous fanout
- Rate limiting: Max 10 recipients × 50 messages/hour = 500 deliveries/hour
- Database sharding: Message copies stored per recipient
- Push notification batching: Single notification per message (not per recipient)

**Technical Implementation:**
```swift
actor MessageBroadcastService {
    func broadcast(_ message: Message, to recipients: [User]) async throws -> BroadcastResult {
        // Create message copies for each recipient
        let deliveryTasks = recipients.map { recipient in
            Task {
                try await deliverMessage(message, to: recipient)
            }
        }

        // Wait for all deliveries (with timeout)
        let results = try await withThrowingTaskGroup(of: DeliveryStatus.self) { group in
            for task in deliveryTasks {
                group.addTask { try await task.value }
            }

            var statuses: [DeliveryStatus] = []
            for try await status in group {
                statuses.append(status)
            }
            return statuses
        }

        return BroadcastResult(
            total: recipients.count,
            delivered: results.filter { $0.isSuccess }.count,
            failed: results.filter { !$0.isSuccess }.count,
            statuses: results
        )
    }

    private func deliverMessage(_ message: Message, to recipient: User) async throws -> DeliveryStatus {
        // Store message in recipient's inbox
        try await database.insert(message, for: recipient.id)

        // Send push notification
        try await pushService.notify(recipient, about: message)

        // Trigger widget refresh
        try await widgetService.refresh(for: recipient.id)

        return DeliveryStatus(recipientID: recipient.id, success: true)
    }
}

struct BroadcastResult {
    let total: Int
    let delivered: Int
    let failed: Int
    let statuses: [DeliveryStatus]
}
```

**Acceptance Criteria:**
- [ ] Can select up to 10 recipients
- [ ] Message delivers to all recipients within 5 seconds
- [ ] Partial failures don't block successful deliveries
- [ ] Delivery status updates in real-time
- [ ] Recipients don't see each other's identities
- [ ] Group lists save and load correctly

---

#### 4.1.6 Multi-Sender Display Support ⭐ (MVP)

**Description:** Display messages from multiple senders on different widgets.

**Requirements:**

**Widget Configuration:**
- During widget setup: User selects which sender to display
- Widget configuration UI:
  - List of all friends
  - Search/filter friends
  - Select sender
  - Preview widget with sender's last message
- Save configuration to widget intent

**Independent Widget Updates:**
- Each widget maintains separate timeline
- Message from Sender A updates only "Sender A" widgets
- Message from Sender B updates only "Sender B" widgets
- No cross-contamination between widgets

**Widget Labeling:**
- Widget title: Sender's display name
- Subtitle: Last message timestamp ("2m ago")
- Avatar: Small circular avatar in corner (optional)
- Visual distinction: Color-coded borders per sender (optional)

**Inbox Model:**
- Backend maintains per-sender message slots:
  ```
  User Inbox:
  ├─ From Alice: "Hello!"
  ├─ From Bob: "Meeting at 3pm"
  └─ From Carol: "🎉"
  ```
- Each sender gets one slot (latest message only)
- Old messages automatically replaced

**Widget Gallery:**
- In-app "My Widgets" screen
- Shows all installed widgets
- Preview current state
- Edit configuration
- Remove widget

**Notification Strategy:**
- Separate notification channels per sender
- Notification content: "[Sender] sent a message"
- Tap notification: Opens widget for that sender
- Notification badges: Show count of unread senders (not messages)

**Technical Implementation:**
```swift
// Widget Intent Configuration
struct SelectSenderIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Sender"

    @Parameter(title: "Sender")
    var sender: IntentUser?
}

struct IntentUser: AppEntity {
    let id: UUID
    let displayName: String
    let avatarURL: URL?

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        "Friend"
    }
}

// Timeline Provider with Sender Filtering
struct MessageTimelineProvider: AppIntentTimelineProvider {
    func timeline(for configuration: SelectSenderIntent,
                  in context: Context) async -> Timeline<MessageEntry> {
        guard let senderID = configuration.sender?.id else {
            return Timeline(entries: [.placeholder], policy: .never)
        }

        // Fetch latest message FROM this specific sender
        let message = await MessageStore.shared.latestMessage(from: senderID)

        let entry = MessageEntry(
            date: Date(),
            message: message,
            senderName: configuration.sender?.displayName ?? "Unknown",
            animationState: .playing
        )

        return Timeline(entries: [entry], policy: .atEnd)
    }
}

// Message Store with Sender Indexing
actor MessageStore {
    private var inbox: [UUID: Message] = [:] // [SenderID: Message]

    func store(_ message: Message, from senderID: UUID) {
        inbox[senderID] = message // Replace old message
        notifyWidgets(for: senderID)
    }

    func latestMessage(from senderID: UUID) -> Message? {
        inbox[senderID]
    }

    private func notifyWidgets(for senderID: UUID) {
        WidgetCenter.shared.reloadTimelines(ofKind: "VestaWidget.\(senderID)")
    }
}
```

**Acceptance Criteria:**
- [ ] User can install multiple widgets for different senders
- [ ] Each widget updates only when its sender sends message
- [ ] Widget configuration UI lists all friends
- [ ] Removing friend removes associated widgets
- [ ] Widgets show correct sender name/avatar
- [ ] No message mixing between sender widgets

---

### 4.2 Content Features

#### 4.2.1 Plain Text Support ⭐ (MVP)

**Requirements:**
- Support all uppercase letters A-Z
- Support digits 0-9
- Support basic punctuation: ! ? + . , - / :
- Auto-convert lowercase to uppercase
- Line wrapping: Auto-wrap at 22 characters
- Alignment options: Left, center, right
- Text validation: Block unsupported characters with helpful error

**Acceptance Criteria:**
- [ ] All supported characters render correctly
- [ ] Lowercase auto-converts to uppercase
- [ ] Line wrapping works at 22-character boundary

---

#### 4.2.2 Unicode & Emoji Support 🎯 (MVP)

**Requirements:**
- Extended character set: Common emoji (❤️ 👍 😊 🎉 ⭐ 🔥 💯 ✨)
- Emoji rendering: Full-color emoji in split-flap style
- Emoji animation: Flip to/from emoji same as text
- Emoji picker: Quick access to supported emoji
- Mixed content: Allow text + emoji in same message
- Fallback: Unsupported emoji show as [?] or closest text equivalent

**Technical Challenge:**
- Emoji positioning: Center emoji in character cell
- Size consistency: Emoji same height as text
- Color preservation: Maintain emoji colors in black background
- Font fallback: Handle missing emoji gracefully

**Acceptance Criteria:**
- [ ] 20+ common emoji supported
- [ ] Emoji flip animation smooth
- [ ] Mixed text+emoji messages work
- [ ] Unsupported emoji show fallback

---

#### 4.2.3 Color Pattern Creation 🎯 (Phase 2)

**Requirements:**
- 8-color palette matching Vestaboard:
  - Black (#000000)
  - Red (#FF0000)
  - Orange (#FF6600)
  - Yellow (#FFCC00)
  - Green (#00CC00)
  - Blue (#0066FF)
  - Violet (#6600CC)
  - White (#FFFFFF)

- Grid painter interface: 6×22 grid
- Drawing tools:
  - Brush (paint individual cells)
  - Fill (flood fill)
  - Line (draw straight lines)
  - Rectangle (draw filled/outline rectangles)
  - Eyedropper (sample color from grid)

- Pattern library:
  - Pre-made templates (gradients, hearts, flags)
  - User-saved patterns
  - Community-shared patterns (optional)

- Animation: Color cells flip to show color change
- Export: Save pattern as image

**Acceptance Criteria:**
- [ ] All 8 colors available
- [ ] Drawing tools work smoothly
- [ ] Pattern saves and loads correctly
- [ ] Color flip animation renders well

---

### 4.3 Platform-Specific Features

#### 4.3.1 iOS Widget Integration ⭐ (MVP)

**WidgetKit Requirements:**

**Homescreen Widgets:**
- Small (2×2): Show 6×6 grid, truncated message
- Medium (4×2): Show 6×11 grid, partial message
- Large (4×4): Show full 6×22 grid, complete message
- Extra Large (iPad): Show 12×22 grid, double-height display

**Lockscreen Widgets (iOS 16+):**
- Circular: Show sender avatar + unread indicator
- Rectangular: Show sender name + truncated message (1 line)
- Inline: Show sender name only

**StandBy Mode (iOS 17+):**
- Full-screen split-flap display when iPhone in landscape charging
- Large typography, high contrast
- Continuous subtle animation (idle flipping)
- Night mode: Dim brightness, red accent colors

**Interactive Widgets (iOS 17+):**
- Tap to open: Deep link to sender conversation
- Button: Quick reply with pre-set emoji
- App Intent: Siri integration ("Show my messages")

**Live Activities (iOS 16.1+):**
- Dynamic Island: Show incoming message animation
- Lock screen: Real-time flip animation as message arrives
- Notification: Expand to show full split-flap display

**Timeline Management:**
- Timeline policy: `.atEnd` - widget doesn't auto-refresh
- Refresh trigger: Push notification with background update
- Background refresh: Use BGTaskScheduler for periodic sync
- Animation playback: Timeline entry includes animation metadata

**Technical Implementation:**
```swift
// Homescreen Widget
@main
struct VestaWidgetBundle: WidgetBundle {
    var body: some Widget {
        VestaWidget() // Main widget
        VestaLockScreenWidget() // Lock screen
        VestaStandByWidget() // StandBy mode
    }
}

// Timeline Entry with Animation State
struct MessageEntry: TimelineEntry {
    let date: Date
    let message: Message?
    let senderName: String
    let animationState: AnimationState

    enum AnimationState {
        case idle
        case playing(from: String, to: String, progress: Double)
        case complete(String)
    }
}

// StandBy Widget (Full-Screen)
struct VestaStandByWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "StandBy", provider: Provider()) { entry in
            SplitFlapFullScreenView(entry: entry)
                .containerBackground(.black, for: .widget)
        }
        .configurationDisplayName("VestaWidget StandBy")
        .supportedFamilies([.systemExtraLarge])
    }
}
```

**Acceptance Criteria:**
- [ ] All widget sizes render correctly
- [ ] Lockscreen widgets display on iOS 16+
- [ ] StandBy mode shows full-screen display
- [ ] Interactive widgets respond to taps
- [ ] Timeline refreshes on message arrival

---

#### 4.3.2 macOS Widget Integration 🎯 (Phase 2)

**Requirements:**

**Notification Center Widgets:**
- Small: 6×11 grid
- Medium: 6×22 grid
- Large: 12×22 grid (multi-sender view)

**Desktop Widgets (macOS Sonoma):**
- Floating widgets on desktop
- Always-on-top option
- Transparency levels: 0%, 25%, 50%, 75%
- Snap to screen edges

**Menu Bar Integration:**
- Menu bar extra: Show unread count
- Dropdown: Quick view of latest messages
- Click to open: Full app window

**Continuity:**
- Handoff: Continue message composition on Mac
- Universal Clipboard: Copy message text
- iCloud Sync: Message state syncs across devices

**Acceptance Criteria:**
- [ ] macOS widgets display in Notification Center
- [ ] Desktop widgets stay on top
- [ ] Menu bar shows unread count
- [ ] Handoff works between iPhone and Mac

---

#### 4.3.3 visionOS Spatial Integration 🎯 (Phase 3)

**Requirements:**

**Spatial Windows:**
- 3D split-flap display in space
- Depth layers: Characters at different Z-depths during flip
- Size adjustability: Pinch to resize window
- Placement: Anchor to wall or float in space

**Spatial Audio:**
- Positional clicking: Sounds come from window location
- Distance attenuation: Quieter when far away
- 3D sound field: Surround sound for large displays

**Hand Tracking:**
- Pinch to select message
- Swipe to dismiss
- Tap in air to send quick reply

**Environments:**
- Overlay mode: Widget floats in real environment
- Immersive mode: Full split-flap wall
- Shared space: Multiple users see same message (multiplayer)

**Passthrough Integration:**
- Widget respects room lighting
- Auto-dim in bright environments
- Auto-brighten in dark rooms

**Acceptance Criteria:**
- [ ] visionOS app compiles and runs
- [ ] Spatial audio positioned correctly
- [ ] Hand gestures work reliably
- [ ] Window resizes smoothly

---

### 4.4 Technical Features

#### 4.4.1 Real-Time Message Delivery ⭐ (MVP)

**Requirements:**

**Push Notification System:**
- APNs integration for iOS/macOS
- Silent push: Trigger background refresh
- Alert push: Show banner notification
- Critical alerts: Override Do Not Disturb (optional, requires entitlement)

**WebSocket Fallback:**
- Maintain persistent WebSocket connection when app open
- Instant delivery without push delay
- Reconnection logic: Exponential backoff (1s, 2s, 4s, 8s, max 30s)

**Message Queue:**
- Server-side queue: Hold messages if recipient offline
- Max queue size: 10 messages per sender (FIFO)
- Expiration: Messages older than 48 hours deleted
- Delivery guarantee: At-least-once delivery

**Delivery Latency:**
- Target: p50 < 1 second, p95 < 2 seconds, p99 < 5 seconds
- Monitoring: Track delivery timestamps
- Alerting: Alert if p95 > 3 seconds

**Offline Handling:**
- Queue outgoing messages locally
- Retry on reconnection
- Show "Sending..." status
- Fail gracefully after 3 retries

**Technical Implementation:**
```swift
// Push Notification Service
actor PushNotificationService {
    func sendPush(to user: User, message: Message) async throws {
        let apnsPayload = APNSPayload(
            alert: APNSAlert(
                title: "\(message.sender.displayName) sent a message",
                body: message.preview
            ),
            sound: "flip.caf",
            badge: await calculateBadge(for: user),
            contentAvailable: true, // Background refresh
            mutableContent: true, // Notification service extension
            category: "MESSAGE",
            threadID: message.sender.id.uuidString,
            customData: [
                "messageID": message.id.uuidString,
                "senderID": message.sender.id.uuidString
            ]
        )

        try await apnsClient.send(apnsPayload, to: user.deviceToken)
    }
}

// WebSocket Manager
actor WebSocketManager {
    private var socket: URLSessionWebSocketTask?
    private var isConnected = false

    func connect() async throws {
        let url = URL(string: "wss://api.vestawidget.com/ws")!
        socket = URLSession.shared.webSocketTask(with: url)
        socket?.resume()
        isConnected = true

        // Start listening
        await listenForMessages()
    }

    private func listenForMessages() async {
        guard let socket = socket else { return }

        do {
            let message = try await socket.receive()
            switch message {
            case .string(let text):
                await handleMessage(text)
            case .data(let data):
                await handleMessage(data)
            @unknown default:
                break
            }

            // Continue listening
            await listenForMessages()
        } catch {
            // Reconnect with backoff
            await reconnect()
        }
    }
}
```

**Acceptance Criteria:**
- [ ] Messages deliver within 2 seconds (p95)
- [ ] Push notifications trigger widget refresh
- [ ] WebSocket reconnects automatically
- [ ] Offline messages queue and retry
- [ ] No duplicate deliveries

---

#### 4.4.2 Widget Refresh Mechanisms ⭐ (MVP)

**Requirements:**

**Refresh Triggers:**
1. **Push Notification:** Silent push triggers `WidgetCenter.shared.reloadTimelines()`
2. **Background Refresh:** BGTaskScheduler runs every 15-60 minutes
3. **App Launch:** Refresh all timelines when app opens
4. **User Interaction:** Tap widget to force refresh

**Timeline Strategy:**
- Policy: `.atEnd` - don't auto-refresh, wait for push
- Entry count: Single entry (current message)
- Relevance: High relevance for recent messages

**Background Update:**
```swift
// App Delegate / App Scene
func application(_ application: UIApplication,
                 didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                 fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

    // Parse message from push payload
    guard let messageID = userInfo["messageID"] as? String,
          let senderID = userInfo["senderID"] as? String else {
        completionHandler(.noData)
        return
    }

    // Fetch full message
    Task {
        let message = try await messageService.fetchMessage(messageID)
        await MessageStore.shared.store(message, from: UUID(uuidString: senderID)!)

        // Reload widget timelines
        WidgetCenter.shared.reloadTimelines(ofKind: "VestaWidget.\(senderID)")

        completionHandler(.newData)
    }
}

// Background Task
func registerBackgroundTasks() {
    BGTaskScheduler.shared.register(
        forTaskWithIdentifier: "com.vestawidget.refresh",
        using: nil
    ) { task in
        handleBackgroundRefresh(task: task as! BGAppRefreshTask)
    }
}

func handleBackgroundRefresh(task: BGAppRefreshTask) {
    scheduleNextBackgroundRefresh() // Schedule next run

    Task {
        // Sync messages
        try await messageService.syncAllMessages()

        // Reload all widgets
        WidgetCenter.shared.reloadAllTimelines()

        task.setTaskCompleted(success: true)
    }
}
```

**Rate Limiting:**
- Widget refresh: No system-imposed limit (we control via push)
- Background refresh: iOS determines frequency (typically 15-60 min intervals)
- Network calls: Cached for 30 seconds to prevent excessive requests

**Acceptance Criteria:**
- [ ] Push notification refreshes widget within 1 second
- [ ] Background refresh runs at least once per hour
- [ ] App launch refreshes all timelines
- [ ] No excessive network calls (max 1 per minute)

---

#### 4.4.3 Animation Performance Optimization ⭐ (MVP)

**Requirements:**

**Hardware Acceleration:**
- Use Metal for 3D transforms
- GPU rendering for shadow effects
- Offload animations to Graphics thread

**Lazy Loading:**
- Only animate characters in viewport
- Large widgets: Animate visible portion first
- Small widgets: Animate all characters (low count)

**Frame Rate Targets:**
- iPhone 12+: 60fps (16.67ms per frame)
- iPhone X-11: 30fps (33.33ms per frame)
- iPad Pro: 120fps (8.33ms per frame) - ProMotion

**Memory Management:**
- Animation cache: Pre-compute flip positions
- Texture atlas: Combine character textures
- Memory budget: < 50MB for animation system
- Purge cache: Clear after animation completes

**Performance Monitoring:**
```swift
// Animation Performance Tracker
class AnimationMetrics {
    static let shared = AnimationMetrics()

    func trackAnimation(characterCount: Int, duration: TimeInterval, frameRate: Double) {
        let metrics = [
            "character_count": characterCount,
            "duration_ms": duration * 1000,
            "fps": frameRate,
            "device": UIDevice.current.model
        ]

        Analytics.track("animation_performance", properties: metrics)

        if frameRate < 30 {
            Analytics.track("animation_low_fps", properties: metrics)
        }
    }
}

// In animation view
struct SplitFlapAnimationView: View {
    @State private var frameCount = 0
    @State private var startTime = Date()

    var body: some View {
        TimelineView(.animation) { timeline in
            animationContent
                .onChange(of: timeline.date) { _ in
                    frameCount += 1
                }
                .onDisappear {
                    let duration = Date().timeIntervalSince(startTime)
                    let fps = Double(frameCount) / duration
                    AnimationMetrics.shared.trackAnimation(
                        characterCount: message.count,
                        duration: duration,
                        frameRate: fps
                    )
                }
        }
    }
}
```

**Optimization Techniques:**
- **Reduce motion:** Instant updates if user enables accessibility setting
- **Low power mode:** Reduce animation complexity, lower frame rate to 30fps
- **Thermal throttling:** Detect device temperature, simplify animations if hot
- **Battery level:** Simplify animations below 20% battery

**Acceptance Criteria:**
- [ ] 60fps on iPhone 12+ for 132-character message
- [ ] 30fps minimum on iPhone X
- [ ] Memory usage < 50MB during animation
- [ ] No frame drops on first animation play
- [ ] Low Power Mode reduces complexity

---

## 5. Technical Architecture

### 5.1 Client Architecture (SwiftUI)

**App Structure:**
```
VestaWidget/
├── App/
│   ├── VestaWidgetApp.swift (main entry point)
│   ├── AppDelegate.swift (push notifications, background tasks)
│   └── SceneDelegate.swift (scene lifecycle)
├── Features/
│   ├── Authentication/
│   │   ├── Views/
│   │   │   ├── SignInView.swift
│   │   │   ├── OnboardingView.swift
│   │   │   └── ContactPermissionView.swift
│   │   ├── ViewModels/
│   │   │   └── AuthViewModel.swift
│   │   └── Services/
│   │       └── AuthService.swift
│   ├── Messaging/
│   │   ├── Views/
│   │   │   ├── MessageComposerView.swift
│   │   │   ├── RecipientPickerView.swift
│   │   │   ├── PatternComposerView.swift
│   │   │   └── MessagePreviewView.swift
│   │   ├── ViewModels/
│   │   │   ├── MessageComposerViewModel.swift
│   │   │   └── ConversationViewModel.swift
│   │   └── Services/
│   │       ├── MessageService.swift
│   │       └── MessageStore.swift
│   ├── SplitFlap/
│   │   ├── Views/
│   │   │   ├── SplitFlapDisplayView.swift
│   │   │   ├── SplitFlapCharacterView.swift
│   │   │   └── SplitFlapGridView.swift
│   │   ├── ViewModels/
│   │   │   └── SplitFlapAnimationViewModel.swift
│   │   ├── Models/
│   │   │   ├── CharacterSet.swift
│   │   │   ├── FlipAnimation.swift
│   │   │   └── AnimationState.swift
│   │   └── Utilities/
│   │       ├── AnimationCalculator.swift
│   │       └── SoundManager.swift
│   └── Friends/
│       ├── Views/
│       │   ├── FriendListView.swift
│       │   ├── FriendRequestsView.swift
│       │   └── UserSearchView.swift
│       ├── ViewModels/
│       │   └── FriendsViewModel.swift
│       └── Services/
│           └── FriendService.swift
├── Widgets/
│   ├── VestaWidget.swift (main widget)
│   ├── VestaLockScreenWidget.swift
│   ├── VestaStandByWidget.swift
│   ├── Providers/
│   │   └── MessageTimelineProvider.swift
│   ├── Views/
│   │   ├── WidgetSplitFlapView.swift
│   │   └── WidgetConfigurationView.swift
│   └── Intents/
│       └── SelectSenderIntent.swift
├── Shared/
│   ├── Models/
│   │   ├── User.swift
│   │   ├── Message.swift
│   │   ├── FriendRequest.swift
│   │   └── DeliveryStatus.swift
│   ├── Networking/
│   │   ├── APIClient.swift
│   │   ├── WebSocketManager.swift
│   │   └── NetworkMonitor.swift
│   ├── Storage/
│   │   ├── CoreDataStack.swift
│   │   ├── KeychainManager.swift
│   │   └── UserDefaultsManager.swift
│   ├── Utilities/
│   │   ├── Logger.swift
│   │   ├── Analytics.swift
│   │   └── ErrorHandler.swift
│   └── Extensions/
│       ├── String+Extensions.swift
│       ├── View+Extensions.swift
│       └── Color+Extensions.swift
└── Resources/
    ├── Assets.xcassets
    ├── Sounds/
    │   ├── flip.caf
    │   └── complete.caf
    ├── Fonts/
    │   └── SplitFlap-Bold.ttf
    └── Localization/
        ├── en.lproj
        └── es.lproj
```

**Key Architectural Patterns:**

**MVVM (Model-View-ViewModel):**
```swift
// Example: Message Composer

// Model
struct Message: Codable, Identifiable {
    let id: UUID
    let content: String
    let sender: User
    let recipients: [User]
    let timestamp: Date
}

// View
struct MessageComposerView: View {
    @StateObject private var viewModel = MessageComposerViewModel()

    var body: some View {
        VStack {
            RecipientPicker(selection: $viewModel.selectedRecipients)
            TextEditor(text: $viewModel.messageText)
            SendButton(enabled: viewModel.isValid) {
                viewModel.send()
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Text(viewModel.errorMessage)
        }
    }
}

// ViewModel
@MainActor
class MessageComposerViewModel: ObservableObject {
    @Published var messageText = ""
    @Published var selectedRecipients: [User] = []
    @Published var showError = false
    @Published var errorMessage = ""

    private let messageService: MessageService

    var isValid: Bool {
        !messageText.isEmpty &&
        !selectedRecipients.isEmpty &&
        messageText.count <= 132
    }

    func send() {
        Task {
            do {
                try await messageService.send(messageText, to: selectedRecipients)
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}
```

**Actor-Based Concurrency:**
```swift
// Thread-safe message store
actor MessageStore {
    private var messages: [UUID: Message] = [:]

    func store(_ message: Message, from senderID: UUID) {
        messages[senderID] = message
        notifyObservers()
    }

    func fetch(from senderID: UUID) -> Message? {
        messages[senderID]
    }

    private func notifyObservers() {
        NotificationCenter.default.post(name: .messageStoreUpdated, object: nil)
    }
}
```

**Dependency Injection:**
```swift
// Service container
class ServiceContainer {
    static let shared = ServiceContainer()

    lazy var authService: AuthService = AuthService(apiClient: apiClient)
    lazy var messageService: MessageService = MessageService(apiClient: apiClient)
    lazy var friendService: FriendService = FriendService(apiClient: apiClient)

    private lazy var apiClient: APIClient = APIClient(baseURL: Configuration.apiURL)
}

// Usage in views
struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel(
        messageService: ServiceContainer.shared.messageService
    )
}
```

---

### 5.2 Backend Architecture

**Technology Stack:**
- **Language:** Swift (Vapor framework) or Node.js (Express)
- **Database:** PostgreSQL (user data, relationships) + Redis (message cache)
- **Real-time:** WebSocket server (Socket.IO or native WebSocket)
- **Push:** APNs HTTP/2 provider
- **Hosting:** AWS (EC2, RDS, ElastiCache) or Heroku
- **CDN:** CloudFront for media assets

**API Architecture (REST + WebSocket):**

**REST Endpoints:**
```
Authentication:
POST   /api/v1/auth/signin/apple
POST   /api/v1/auth/signin/email
POST   /api/v1/auth/signin/phone
POST   /api/v1/auth/verify (email/phone verification)
POST   /api/v1/auth/refresh (token refresh)
DELETE /api/v1/auth/signout

Users:
GET    /api/v1/users/me
PATCH  /api/v1/users/me
DELETE /api/v1/users/me
GET    /api/v1/users/:id
GET    /api/v1/users/search?q=username

Friends:
GET    /api/v1/friends
POST   /api/v1/friends/requests (send request)
GET    /api/v1/friends/requests (list pending)
POST   /api/v1/friends/requests/:id/accept
POST   /api/v1/friends/requests/:id/decline
DELETE /api/v1/friends/:id (remove friend)
POST   /api/v1/friends/:id/block

Messages:
POST   /api/v1/messages (send message)
GET    /api/v1/messages/inbox (latest from each sender)
GET    /api/v1/messages/from/:senderID (latest from specific sender)
DELETE /api/v1/messages/:id

Device Tokens:
POST   /api/v1/devices (register device token)
DELETE /api/v1/devices/:token
```

**WebSocket Events:**
```
Client -> Server:
- authenticate: { token }
- ping

Server -> Client:
- authenticated: { user }
- message.new: { messageID, senderID, content, timestamp }
- message.delivered: { messageID, recipientID }
- friend.request: { requestID, fromUser }
- friend.accepted: { friendID }
- error: { code, message }
```

**Database Schema (PostgreSQL):**

```sql
-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(20) UNIQUE NOT NULL,
    display_name VARCHAR(30),
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(20) UNIQUE,
    apple_id VARCHAR(255) UNIQUE,
    password_hash VARCHAR(255), -- for email auth
    avatar_url TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Friend relationships (bidirectional)
CREATE TABLE friendships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    friend_id UUID REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id, friend_id)
);

-- Friend requests
CREATE TABLE friend_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    from_user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    to_user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    status VARCHAR(20) DEFAULT 'pending', -- pending, accepted, declined
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(from_user_id, to_user_id)
);

-- Messages (ephemeral, TTL 48 hours)
CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_id UUID REFERENCES users(id) ON DELETE CASCADE,
    recipient_id UUID REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    content_type VARCHAR(20) DEFAULT 'text', -- text, emoji, pattern
    created_at TIMESTAMP DEFAULT NOW(),
    expires_at TIMESTAMP DEFAULT (NOW() + INTERVAL '48 hours'),
    delivered_at TIMESTAMP,
    displayed_at TIMESTAMP
);

-- Index for fast inbox queries (latest message per sender)
CREATE INDEX idx_messages_recipient_sender ON messages(recipient_id, sender_id, created_at DESC);

-- Device tokens for push notifications
CREATE TABLE device_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    token VARCHAR(255) NOT NULL,
    platform VARCHAR(20) NOT NULL, -- ios, macos, visionos
    created_at TIMESTAMP DEFAULT NOW(),
    last_used_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id, token)
);

-- Auto-delete expired messages (run every hour)
CREATE OR REPLACE FUNCTION delete_expired_messages()
RETURNS void AS $$
BEGIN
    DELETE FROM messages WHERE expires_at < NOW();
END;
$$ LANGUAGE plpgsql;
```

**Redis Cache Schema:**
```
Keys:
- user:{userID}:inbox -> Hash { senderID: messageID }
- message:{messageID} -> JSON (full message object)
- user:{userID}:online -> String (WebSocket session ID)
- user:{userID}:device_tokens -> Set [token1, token2, ...]

TTL:
- Messages: 48 hours
- Inbox: No expiration (updated on new message)
- Online status: 5 minutes (refreshed by ping)
```

**Message Delivery Flow:**
```
1. Client sends POST /api/v1/messages
   {
     recipients: [userID1, userID2],
     content: "Hello!",
     contentType: "text"
   }

2. Server validates:
   - Auth token valid
   - Sender is friends with all recipients
   - Content within limits (132 chars)
   - Rate limit not exceeded

3. Server creates message copies:
   FOR EACH recipient:
     - INSERT INTO messages (sender_id, recipient_id, content)
     - Cache in Redis: message:{messageID}
     - Update Redis inbox: user:{recipientID}:inbox

4. Server sends push notifications:
   FOR EACH recipient:
     - Lookup device tokens from Redis
     - Send APNs push notification (silent + alert)
     - Log delivery status

5. Server sends WebSocket events:
   FOR EACH online recipient:
     - ws.send({ type: 'message.new', messageID, senderID })

6. Client receives push:
   - Triggers background fetch
   - Fetches message via GET /api/v1/messages/:id
   - Stores in local MessageStore
   - Reloads widget timeline

7. Widget timeline updates:
   - Fetches latest message from MessageStore
   - Generates timeline entry with animation
   - Displays split-flap animation
```

**Scalability Considerations:**
- **Horizontal scaling:** Stateless API servers behind load balancer
- **Database sharding:** Shard users by userID hash
- **Redis clustering:** Redis Cluster for cache distribution
- **WebSocket load balancing:** Sticky sessions or Redis Pub/Sub for cross-server messaging
- **Push notification batching:** Queue push jobs, process in batches of 100
- **Rate limiting:** Token bucket algorithm, 50 messages/hour per user

---

### 5.3 Data Synchronization Strategy

**Ephemeral Model:**
- No permanent message history stored
- Only latest message per sender kept
- Messages auto-delete after 48 hours
- Deleted messages immediately cleared from cache and widgets

**Sync Triggers:**
1. **App launch:** Fetch latest messages from all friends
2. **Push notification:** Fetch specific new message
3. **Background refresh:** Periodic sync every 15-60 minutes
4. **Manual pull-to-refresh:** User-initiated sync

**Conflict Resolution:**
- No conflicts possible (single source of truth: server)
- Latest message always wins (no merging needed)
- Widget always displays server state

**Offline Support:**
- **Read:** Display last cached message
- **Write:** Queue outgoing messages, send on reconnection
- **Sync:** Full inbox sync when app comes online

**Implementation:**
```swift
actor SyncManager {
    private let apiClient: APIClient
    private let messageStore: MessageStore

    func syncInbox() async throws {
        // Fetch latest messages from all friends
        let inbox = try await apiClient.fetchInbox()

        // Update local store
        for (senderID, message) in inbox {
            await messageStore.store(message, from: senderID)
        }

        // Reload all widgets
        WidgetCenter.shared.reloadAllTimelines()
    }

    func syncMessage(from senderID: UUID) async throws {
        let message = try await apiClient.fetchLatestMessage(from: senderID)
        await messageStore.store(message, from: senderID)

        // Reload specific sender widget
        WidgetCenter.shared.reloadTimelines(ofKind: "VestaWidget.\(senderID)")
    }
}
```

---

## 6. Design Requirements

### 6.1 Visual Design System

**Color Palette:**

**Primary (Split-Flap Classic):**
- Background: `#000000` (Pure Black)
- Text: `#FFFFFF` (Pure White)
- Accent: `#FF6600` (Orange) - for buttons, highlights

**Secondary (White Variant):**
- Background: `#FFFFFF` (Pure White)
- Text: `#000000` (Pure Black)
- Accent: `#0066FF` (Blue)

**Extended (Pattern Colors):**
- Red: `#FF0000`
- Orange: `#FF6600`
- Yellow: `#FFCC00`
- Green: `#00CC00`
- Blue: `#0066FF`
- Violet: `#6600CC`

**System Integration:**
- Dark Mode: Use black background variant
- Light Mode: Use white background variant
- Accent color: User-customizable (iOS Settings)

---

**Typography:**

**Display Font (Split-Flap Characters):**
- Family: Custom "SplitFlap Bold" or SF Pro Rounded Bold
- Weight: 700 (Bold)
- Style: Sans-serif, monospaced
- Characteristics:
  - Uniform stroke weight
  - Clear horizontal split line
  - High contrast, legible at distance
  - Optimized for 1:2 aspect ratio cells

**UI Font (App Interface):**
- Family: SF Pro (system default)
- Weights:
  - Regular (400): Body text
  - Medium (500): Labels
  - Semibold (600): Buttons
  - Bold (700): Headings
- Dynamic Type: Support all accessibility sizes

**Character Specifications:**
- Cell size: 40pt × 80pt (1:2 ratio)
- Font size: 60pt (75% of cell height)
- Line height: 80pt (100% of cell height)
- Letter spacing: 0pt (monospaced)
- Split line: 1pt stroke at 50% height

---

**Layout Grid:**

**6×22 Vestaboard Grid:**
```
┌────┬────┬────┬───...───┬────┬────┐
│ A1 │ A2 │ A3 │   ...   │A21 │A22 │ Row 1
├────┼────┼────┼───...───┼────┼────┤
│ B1 │ B2 │ B3 │   ...   │B21 │B22 │ Row 2
├────┼────┼────┼───...───┼────┼────┤
│ C1 │ C2 │ C3 │   ...   │C21 │C22 │ Row 3
├────┼────┼────┼───...───┼────┼────┤
│ D1 │ D2 │ D3 │   ...   │D21 │D22 │ Row 4
├────┼────┼────┼───...───┼────┼────┤
│ E1 │ E2 │ E3 │   ...   │E21 │E22 │ Row 5
├────┼────┼────┼───...───┼────┼────┤
│ F1 │ F2 │ F3 │   ...   │F21 │F22 │ Row 6
└────┴────┴────┴───...───┴────┴────┘
```

**Cell Spacing:**
- Gap between cells: 2pt
- Border width: 1pt
- Border color: `#222222` (dark gray)

**Widget Layouts:**
- **Small (2×2):** 6×6 grid (36 characters)
- **Medium (4×2):** 6×11 grid (66 characters)
- **Large (4×4):** 6×22 grid (132 characters)
- **Lockscreen Circular:** 3×3 grid (9 characters)
- **Lockscreen Rectangular:** 2×11 grid (22 characters)

---

**3D Depth & Shadows:**

**Perspective:**
```swift
.modifier(SplitFlapPerspective())

struct SplitFlapPerspective: ViewModifier {
    func body(content: Content) -> some View {
        content
            .perspectiveTransformEffect()
            .environment(\.perspective, 600)
    }
}
```

**Character Shadows:**
```swift
.shadow(color: .black.opacity(0.8), radius: 4, x: 0, y: 2) // Outer shadow
.overlay(
    LinearGradient(
        colors: [.clear, .black.opacity(0.3)],
        startPoint: .top,
        endPoint: .bottom
    )
) // Inner gradient for depth
```

**Flap Shadows (during flip):**
- Top flap (rotating down): Shadow on bottom edge
- Bottom flap (rotating up): Shadow on top edge
- Shadow opacity: 0.6 at 90° (perpendicular), 0 at 0°/180°

---

**Animation Specifications:**

**Flip Timing:**
- Duration per character: 120ms (default)
- Easing: `easeInOut` cubic bezier `(0.42, 0, 0.58, 1)`
- Stagger delay: 20ms per column (left-to-right)
- Row delay: 50ms per row (top-to-bottom)

**Rotation Angles:**
- Top flap: `rotateX(0°)` → `rotateX(-90°)` → `rotateX(-180°)`
- Bottom flap: `rotateX(180°)` → `rotateX(90°)` → `rotateX(0°)`

**Keyframe Animation:**
```swift
.keyframeAnimator(initialValue: AnimationValues()) { content, value in
    content
        .rotationEffect(.degrees(value.angle), axis: (1, 0, 0))
        .opacity(value.opacity)
} keyframes: { _ in
    KeyframeTrack(\.angle) {
        CubicKeyframe(0, duration: 0)
        CubicKeyframe(-90, duration: 0.06) // Half flip
        CubicKeyframe(-180, duration: 0.06) // Full flip
    }
    KeyframeTrack(\.opacity) {
        CubicKeyframe(1, duration: 0.05)
        CubicKeyframe(0.5, duration: 0.02) // Dim at 90°
        CubicKeyframe(1, duration: 0.05) // Full brightness
    }
}
```

---

### 6.2 Accessibility

**VoiceOver Support:**
- Widget content: Read final message text, skip animation
- Animation in-progress: Announce "Loading message"
- Empty state: "No messages from [Sender]"
- Button labels: Clear, descriptive labels for all controls
- Character composer: Announce character count as user types

**Reduce Motion:**
- Disable flip animation
- Instant character transitions (fade or no animation)
- Preference check: `UIAccessibility.isReduceMotionEnabled`

**Dynamic Type:**
- Support all text sizes (XS to XXXL)
- Scale widget grid proportionally
- Minimum cell size: 20pt × 40pt (for largest text size)

**High Contrast:**
- Increase border width: 2pt → 3pt
- Increase text stroke: Add 1pt outline
- Background/text contrast ratio: 21:1 (pure black/white)

**Color Blind Modes:**
- Provide alternative pattern palettes
- Add texture patterns (stripes, dots) in addition to colors
- Label colors with text in pattern composer

---

### 6.3 UI/UX Flows

**Onboarding Flow:**
```
1. Splash Screen (1s)
   ↓
2. Welcome Screen
   - "Welcome to VestaWidget"
   - Brief product description
   - [Get Started] button
   ↓
3. Sign In Options
   - [Continue with Apple] (recommended)
   - [Sign in with Email]
   - [Sign in with Phone]
   ↓
4. Account Setup
   - Choose username
   - Add display name (optional)
   - Upload avatar (optional)
   ↓
5. Permission Requests
   - Notifications: "Get notified when friends send messages"
   - Contacts: "Find friends already using VestaWidget"
   ↓
6. Add First Friend
   - Search contacts
   - Enter username
   - Scan QR code
   - [Skip for now]
   ↓
7. Install Widget Tutorial
   - Animated guide showing how to add widget
   - Platform-specific instructions (iOS/macOS)
   - [Show me later] or [Add Widget Now]
   ↓
8. First Message Prompt
   - "Send your first message!"
   - Pre-filled with "Hello! 👋"
   - [Send] or [Edit Message]
   ↓
9. Home Screen
   - Friends list
   - [+ New Message] button
   - Widget installation reminder banner (if not installed)
```

**Message Sending Flow:**
```
1. Home Screen
   ↓ Tap [+ New Message]
2. Recipient Selection
   - Search bar at top
   - Favorites section (starred friends)
   - All friends list (alphabetical)
   - [Select multiple] toggle
   - Selected recipients shown as chips at top
   ↓ Select recipient(s)
3. Composition Mode Selection
   - [Text Message] (default)
   - [Pattern Creator]
   - [Templates] (pre-made messages)
   ↓ Choose [Text Message]
4. Text Composer
   - Full-screen text editor
   - Character counter: "12 / 132"
   - Live preview (miniature split-flap)
   - [Preview Animation] button
   - Keyboard toolbar: Emoji picker, formatting
   ↓ Type message
5. Preview (optional)
   - Full-screen split-flap animation
   - Plays exactly as recipient will see it
   - [Edit] or [Send] buttons
   ↓ Tap [Send]
6. Sending State
   - Loading indicator
   - "Sending to [Recipient]..."
   - Haptic feedback on success
   ↓ Success
7. Confirmation
   - Checkmark animation
   - "Message sent!"
   - Delivery status per recipient
   - [Send Another] or [Done]
```

**Widget Installation Flow (iOS):**
```
1. In-App Prompt
   - "Add VestaWidget to your homescreen"
   - Visual preview of widget
   - [Show me how] button
   ↓
2. Tutorial Screen
   - Step 1: "Long-press on homescreen"
   - Step 2: "Tap the + button"
   - Step 3: "Search for VestaWidget"
   - Step 4: "Choose widget size"
   - Step 5: "Select which friend to display"
   - Animated GIF or video showing each step
   ↓
3. Deep Link (iOS 17+)
   - [Add Widget] button triggers system widget gallery
   - Opens directly to VestaWidget selection
   ↓
4. Configuration
   - System widget configuration sheet
   - "Select Sender" dropdown
   - List of all friends with avatars
   - [Add Widget] system button
```

---

## 7. Data Models

### 7.1 Core Data Models (Swift)

```swift
import Foundation

// MARK: - User

struct User: Codable, Identifiable, Hashable {
    let id: UUID
    var username: String
    var displayName: String?
    var email: String?
    var phoneNumber: String?
    var appleID: String?
    var avatarURL: URL?
    var createdAt: Date
    var updatedAt: Date
    var preferences: UserPreferences

    // Computed
    var effectiveName: String {
        displayName ?? username
    }
}

struct UserPreferences: Codable, Hashable {
    var soundEnabled: Bool = true
    var hapticsEnabled: Bool = true
    var animationSpeed: AnimationSpeed = .normal
    var theme: Theme = .classic
    var notificationsEnabled: Bool = true
    var discoverableByEmail: Bool = true
    var discoverableByPhone: Bool = true

    enum AnimationSpeed: String, Codable {
        case slow = "slow"       // 200ms per char
        case normal = "normal"   // 120ms per char
        case fast = "fast"       // 50ms per char
    }

    enum Theme: String, Codable {
        case classic = "classic" // Black bg, white text
        case white = "white"     // White bg, black text
        case custom = "custom"   // User-defined colors
    }
}

// MARK: - Message

struct Message: Codable, Identifiable, Hashable {
    let id: UUID
    let sender: User
    var recipients: [User]
    var content: String
    var contentType: ContentType
    var timestamp: Date
    var expiresAt: Date
    var deliveryStatus: [UUID: DeliveryStatus] // [RecipientID: Status]

    enum ContentType: String, Codable {
        case text
        case emoji
        case pattern
    }

    // Computed
    var isExpired: Bool {
        Date() > expiresAt
    }

    var preview: String {
        String(content.prefix(22)) // First line only
    }
}

struct DeliveryStatus: Codable, Hashable {
    let recipientID: UUID
    var status: Status
    var deliveredAt: Date?
    var displayedAt: Date?
    var failureReason: String?

    enum Status: String, Codable {
        case pending
        case delivered
        case displayed
        case failed
    }

    var isSuccess: Bool {
        status == .delivered || status == .displayed
    }
}

// MARK: - Friend & Relationships

struct Friend: Codable, Identifiable, Hashable {
    let id: UUID
    let user: User
    var friendshipDate: Date
    var lastMessageAt: Date?
    var isFavorite: Bool = false
    var isMuted: Bool = false
}

struct FriendRequest: Codable, Identifiable, Hashable {
    let id: UUID
    let fromUser: User
    let toUser: User
    var status: Status
    let createdAt: Date
    var updatedAt: Date

    enum Status: String, Codable {
        case pending
        case accepted
        case declined
    }
}

// MARK: - Split-Flap Models

struct SplitFlapCharacterSet {
    static let standard: [Character] = [
        " ", // Blank
        "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
        "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
        "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
        "!", "?", "+"
    ]

    static let extended: [Character] = standard + [
        "❤️", "👍", "😊", "🎉", "⭐", "🔥", "💯", "✨", "🎵", "☀️"
    ]

    static func contains(_ character: Character, inSet set: [Character] = standard) -> Bool {
        set.contains(character.uppercased().first ?? character)
    }

    static func normalize(_ text: String, useExtended: Bool = false) -> String {
        let characterSet = useExtended ? extended : standard
        return text.uppercased().filter { characterSet.contains($0) }
    }
}

struct FlipAnimation {
    let fromCharacter: Character
    let toCharacter: Character
    let path: [Character] // All intermediate characters
    let duration: TimeInterval

    init(from: Character, to: Character, characterSet: [Character] = SplitFlapCharacterSet.standard) {
        self.fromCharacter = from
        self.toCharacter = to

        guard let fromIndex = characterSet.firstIndex(of: from),
              let toIndex = characterSet.firstIndex(of: to) else {
            self.path = [from, to]
            self.duration = 0.12
            return
        }

        // Calculate shortest path (forward or backward)
        let forwardDistance = (toIndex - fromIndex + characterSet.count) % characterSet.count
        let backwardDistance = (fromIndex - toIndex + characterSet.count) % characterSet.count

        if forwardDistance <= backwardDistance {
            // Go forward
            let indices = (0...forwardDistance).map { (fromIndex + $0) % characterSet.count }
            self.path = indices.map { characterSet[$0] }
        } else {
            // Go backward
            let indices = (0...backwardDistance).map { (fromIndex - $0 + characterSet.count) % characterSet.count }
            self.path = indices.map { characterSet[$0] }
        }

        self.duration = Double(self.path.count - 1) * 0.12 // 120ms per flip
    }
}

struct GridPosition: Hashable {
    let row: Int // 0-5
    let column: Int // 0-21

    var isValid: Bool {
        (0..<6).contains(row) && (0..<22).contains(column)
    }

    var linearIndex: Int {
        row * 22 + column
    }

    init(row: Int, column: Int) {
        self.row = row
        self.column = column
    }

    init(linearIndex: Int) {
        self.row = linearIndex / 22
        self.column = linearIndex % 22
    }
}

struct ColorPattern: Codable, Hashable {
    var grid: [[VestaColor]] // 6×22 grid

    init() {
        self.grid = Array(repeating: Array(repeating: .black, count: 22), count: 6)
    }

    subscript(position: GridPosition) -> VestaColor {
        get { grid[position.row][position.column] }
        set { grid[position.row][position.column] = newValue }
    }
}

enum VestaColor: String, Codable, CaseIterable {
    case black, red, orange, yellow, green, blue, violet, white

    var color: Color {
        switch self {
        case .black: return Color(hex: "#000000")
        case .red: return Color(hex: "#FF0000")
        case .orange: return Color(hex: "#FF6600")
        case .yellow: return Color(hex: "#FFCC00")
        case .green: return Color(hex: "#00CC00")
        case .blue: return Color(hex: "#0066FF")
        case .violet: return Color(hex: "#6600CC")
        case .white: return Color(hex: "#FFFFFF")
        }
    }
}

// MARK: - Widget Models

struct MessageEntry: TimelineEntry {
    let date: Date
    let message: Message?
    let senderName: String
    let senderAvatarURL: URL?
    let animationState: AnimationState
    let configuration: SelectSenderIntent

    enum AnimationState {
        case idle
        case playing(from: String, to: String, progress: Double)
        case complete(String)
    }

    static var placeholder: MessageEntry {
        MessageEntry(
            date: Date(),
            message: nil,
            senderName: "Friend",
            senderAvatarURL: nil,
            animationState: .idle,
            configuration: SelectSenderIntent()
        )
    }
}

// MARK: - API Response Models

struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let data: T?
    let error: APIError?
}

struct APIError: Codable, Error {
    let code: String
    let message: String
    let details: [String: String]?
}

struct InboxResponse: Codable {
    let messages: [UUID: Message] // [SenderID: Message]
    let unreadCount: Int
}

struct BroadcastResult: Codable {
    let total: Int
    let delivered: Int
    let failed: Int
    let statuses: [DeliveryStatus]
}
```

---

### 7.2 Database Migrations

**Initial Schema (PostgreSQL):**

See section 5.2 for full SQL schema.

**Migration Strategy:**
- Use migration framework (Fluent for Vapor, or Alembic/TypeORM for Node.js)
- Version-controlled migrations
- Rollback capability for each migration
- Test migrations on staging before production

**Example Migration (Add display_name field):**
```sql
-- Migration: 002_add_display_name.sql
-- Up
ALTER TABLE users ADD COLUMN display_name VARCHAR(30);

-- Down
ALTER TABLE users DROP COLUMN display_name;
```

---

## 8. Privacy & Security

### 8.1 Data Encryption

**End-to-End Encryption (Signal Protocol):**
- Message content encrypted on sender device
- Decrypted only on recipient device
- Server cannot read message contents
- Uses Double Ratchet Algorithm for forward secrecy

**Implementation:**
```swift
import SignalProtocol

actor EncryptionService {
    private let signalStore: SignalStore

    func encryptMessage(_ plaintext: String, for recipient: User) async throws -> EncryptedMessage {
        let recipientAddress = SignalAddress(name: recipient.id.uuidString, deviceID: 1)

        // Encrypt using Signal Protocol
        let ciphertext = try await signalStore.encrypt(
            plaintext.data(using: .utf8)!,
            for: recipientAddress
        )

        return EncryptedMessage(
            recipientID: recipient.id,
            ciphertext: ciphertext.base64EncodedString(),
            version: 1
        )
    }

    func decryptMessage(_ encrypted: EncryptedMessage) async throws -> String {
        let senderAddress = SignalAddress(name: encrypted.senderID.uuidString, deviceID: 1)

        let ciphertext = Data(base64Encoded: encrypted.ciphertext)!
        let plaintext = try await signalStore.decrypt(ciphertext, from: senderAddress)

        return String(data: plaintext, encoding: .utf8)!
    }
}
```

**Transport Security:**
- TLS 1.3 for all API calls
- Certificate pinning for app-to-server communication
- HTTPS-only (no HTTP fallback)

**At-Rest Encryption:**
- Local storage encrypted using iOS Data Protection
- Keychain for sensitive data (tokens, keys)
- Database encryption for server-side data (AWS RDS encryption)

---

### 8.2 Authentication & Authorization

**JWT Token Structure:**
```json
{
  "sub": "user-uuid",
  "iat": 1699564800,
  "exp": 1702243200,
  "iss": "vestawidget.com",
  "aud": "vestawidget-app",
  "scope": ["read:messages", "write:messages", "read:friends"]
}
```

**Token Lifecycle:**
- Access token: 30-day expiration
- Refresh token: 90-day expiration
- Automatic refresh 7 days before expiration
- Revocation on logout or password change

**Biometric Authentication:**
```swift
import LocalAuthentication

func authenticateUser() async throws -> Bool {
    let context = LAContext()
    var error: NSError?

    guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
        throw AuthError.biometricsNotAvailable
    }

    return try await context.evaluatePolicy(
        .deviceOwnerAuthenticationWithBiometrics,
        localizedReason: "Unlock VestaWidget"
    )
}
```

---

### 8.3 Privacy Controls

**User Privacy Settings:**
- [ ] Discoverable by email
- [ ] Discoverable by phone number
- [ ] Allow friend requests from strangers
- [ ] Show online status
- [ ] Read receipts (displayed_at timestamp)

**Data Minimization:**
- No message history retention
- Auto-delete messages after 48 hours
- User data export includes only current state (no history)
- Account deletion permanently removes all data

**GDPR Compliance:**
- Right to access: Export user data
- Right to erasure: Delete account permanently
- Right to portability: Export in JSON format
- Right to rectification: Edit profile anytime
- Data processing agreement for EU users

**California Privacy Rights (CCPA):**
- Disclose data collection practices
- Allow opt-out of data selling (we don't sell data)
- Provide data deletion mechanism

---

### 8.4 Spam & Abuse Prevention

**Rate Limiting:**
- 50 messages per hour per user
- 10 friend requests per day per user
- 100 API requests per minute per user
- Exponential backoff for repeated violations

**Spam Detection:**
- Machine learning model detects spam patterns
- Keyword blacklist (profanity, scams)
- Behavior analysis (rapid-fire messages to strangers)
- User reports feed into model training

**Moderation Tools:**
- Report user functionality
- Block user (prevents all communication)
- Shadowban (user can send, but messages don't deliver)
- Account suspension (temporary or permanent)

**Trust & Safety Team:**
- Review reported users
- Manual moderation for edge cases
- Appeal process for false positives

---

## 9. Platform Capabilities & Limitations

### 9.1 iOS WidgetKit Constraints

**Refresh Frequency:**
- System determines refresh schedule (not developer-controlled)
- Typical: 4-6 refreshes per hour
- Push notifications can trigger immediate refresh (best approach)
- Background refresh budget varies by user engagement

**Widget Size Limits:**
- Memory: ~30MB per widget
- Network: Avoid network calls in widget view (use timeline provider)
- CPU: Keep rendering under 1 second
- Timeline entries: Limit to 10-20 entries

**Interactive Widgets (iOS 17+):**
- Button taps supported
- No text input or gestures
- App Intents for actions
- Limited to 2-3 buttons per widget

**Lock Screen Widgets:**
- More limited CPU/memory
- Simpler UI only (text + icon)
- No animations during rendering
- Updates via timeline only

**Workarounds & Best Practices:**
- Use silent push to trigger immediate refresh
- Pre-compute animation in timeline provider
- Keep timeline entry count low (1-2 entries)
- Optimize image assets (use SF Symbols where possible)

---

### 9.2 macOS Widget Differences

**Notification Center Widgets:**
- Larger screen real estate
- Mouse hover interactions
- Right-click context menus
- Less frequent refresh (lower priority than iOS)

**Desktop Widgets (Sonoma):**
- Always visible on desktop
- Higher refresh priority
- Transparency/blur effects
- Draggable positioning

**Limitations:**
- No touch gestures (mouse/trackpad only)
- Different layout constraints
- Less strict memory limits
- Potentially longer battery life impact

---

### 9.3 visionOS Considerations

**Spatial Computing:**
- 3D window placement in space
- Depth layers for UI elements
- Hand tracking for interactions
- Eye tracking for attention (privacy-preserving)

**Unique Capabilities:**
- True 3D split-flap display (characters at different depths)
- Spatial audio (sounds positioned in 3D)
- Immersive environments
- Shared spaces (multiplayer potential)

**Challenges:**
- Higher GPU/CPU requirements
- Limited user base (early adopter device)
- New interaction paradigms
- Accessibility considerations (spatial UI)

**Development Strategy:**
- Phase 3 feature (after iOS/macOS stable)
- Reuse SwiftUI codebase
- Add spatial modifiers for depth
- Test extensively on device (simulator insufficient)

---

## 10. Success Metrics & KPIs

### 10.1 Engagement Metrics

**Daily Active Users (DAU):**
- Target: 40% of MAU
- Measurement: Users who open app or receive message
- Goal: Increase DAU/MAU ratio over time

**Messages Sent per User per Day:**
- Target: 2+ messages
- Measurement: Average messages sent per DAU
- Segmentation: Power users (5+), casual (1-2), dormant (0)

**Widget Installation Rate:**
- Target: 80% of users install at least one widget
- Measurement: Percentage of users with active widgets
- Goal: Maximize widget installs to drive passive engagement

**Message Response Rate:**
- Target: 60% of messages receive reply within 24 hours
- Measurement: Percentage of messages that get response
- Goal: Encourage two-way communication

**Session Frequency:**
- Target: 3+ app opens per day
- Measurement: Average sessions per DAU
- Goal: Drive habitual usage

---

### 10.2 Technical Performance Metrics

**Message Delivery Latency:**
- Target: p50 < 1s, p95 < 2s, p99 < 5s
- Measurement: Time from send to recipient device notification
- Alerting: Alert if p95 > 3s

**Widget Refresh Success Rate:**
- Target: 95%+ successful refreshes
- Measurement: Percentage of refresh attempts that succeed
- Failure reasons: Network errors, timeline errors, rendering failures

**Animation Frame Rate:**
- Target: 60fps on iPhone 12+, 30fps on iPhone X-11
- Measurement: Average FPS during animation playback
- Segmentation: By device model, widget size

**Crash-Free Session Rate:**
- Target: 99.5%+
- Measurement: Percentage of sessions without crashes
- Monitoring: Firebase Crashlytics, Sentry

**API Response Time:**
- Target: p50 < 100ms, p95 < 500ms
- Measurement: Server response time for API endpoints
- Alerting: Alert if p95 > 1s

---

### 10.3 Growth Metrics

**Month-over-Month User Growth:**
- Target: 15%+ MoM growth
- Measurement: (New users - churned users) / previous month users
- Goal: Sustainable viral growth

**Viral Coefficient:**
- Target: > 1.5 invites sent per user
- Measurement: (Invites sent by user) / (Successful signups from invites)
- Goal: Achieve viral loop (K-factor > 1)

**Retention Rates:**
- **Week 1:** 50%+ (users who return after 7 days)
- **Week 4:** 30%+ (users who return after 28 days)
- **Month 3:** 20%+ (users still active after 90 days)
- Measurement: Cohort analysis
- Goal: Improve retention through product improvements

**App Store Rating:**
- Target: 4.5+ stars
- Measurement: Average rating across all reviews
- Goal: Maintain high quality perception

**Net Promoter Score (NPS):**
- Target: > 50
- Measurement: "How likely are you to recommend VestaWidget?" (0-10 scale)
- Segmentation: Promoters (9-10), Passives (7-8), Detractors (0-6)

---

### 10.4 Monetization Metrics (Future)

**Note:** Initial version is free. Monetization potential for future phases:

**Premium Conversion Rate:**
- Target: 5-10% of users upgrade to premium
- Features: Unlimited friends, advanced patterns, custom themes
- Price: $2.99/month or $19.99/year

**Average Revenue Per User (ARPU):**
- Target: $0.15-0.30 (blended free + premium)
- Measurement: Total revenue / MAU

**Customer Lifetime Value (LTV):**
- Target: $50+ per premium user
- Measurement: Average revenue per user over lifetime

---

## 11. Development Roadmap

### Phase 1: MVP (3-4 months)

**Month 1: Foundation**
- [ ] Project setup (Xcode, server, database)
- [ ] User authentication (Sign in with Apple, email, phone)
- [ ] Core data models
- [ ] API design and implementation
- [ ] Database schema and migrations

**Month 2: Core Features**
- [ ] Split-flap animation system
- [ ] Message composition UI
- [ ] Message sending/receiving backend
- [ ] Friend request system
- [ ] Push notification integration

**Month 3: Widgets**
- [ ] iOS homescreen widgets (small, medium, large)
- [ ] iOS lockscreen widgets
- [ ] Widget timeline provider
- [ ] Widget refresh mechanism
- [ ] Widget configuration (sender selection)

**Month 4: Polish & Launch**
- [ ] UI/UX refinement
- [ ] Animation performance optimization
- [ ] Bug fixes
- [ ] Beta testing (TestFlight)
- [ ] App Store submission
- [ ] Launch marketing

**MVP Feature Set:**
- ✅ Sign in with Apple, email, phone
- ✅ Friend requests and management
- ✅ Text message sending (plain text)
- ✅ Split-flap animation (6×22 grid)
- ✅ iOS widgets (homescreen, lockscreen)
- ✅ Multi-recipient broadcasting (up to 10)
- ✅ Multi-sender widget support
- ✅ Push notifications
- ✅ Sound effects and haptics

**Explicitly NOT in MVP:**
- ❌ macOS widgets
- ❌ visionOS support
- ❌ Color pattern creation
- ❌ Advanced emoji support (beyond basic set)
- ❌ Message templates
- ❌ Group management UI
- ❌ Analytics dashboard
- ❌ Monetization

---

### Phase 2: Expansion (2-3 months post-launch)

**Features:**
- [ ] macOS widget support
- [ ] Extended emoji character set (20+ emoji)
- [ ] Color pattern composer
- [ ] Pattern library and templates
- [ ] Message scheduling
- [ ] Group management UI
- [ ] StandBy mode optimization
- [ ] Interactive widgets (quick replies)
- [ ] User analytics dashboard (in-app)

**Goals:**
- Expand to macOS users
- Increase creative expression options
- Improve power user workflows
- Gather usage data for optimization

---

### Phase 3: Advanced Features (3-6 months post-Phase 2)

**Features:**
- [ ] visionOS app and spatial widgets
- [ ] 3D split-flap display in visionOS
- [ ] Spatial audio
- [ ] Live Activities (Dynamic Island)
- [ ] Apple Watch complications
- [ ] Siri Shortcuts integration
- [ ] Message reactions (emoji reactions to received messages)
- [ ] Custom theme creator
- [ ] Community pattern sharing
- [ ] Widget automation (IFTTT-style triggers)

**Goals:**
- Support full Apple ecosystem
- Enable advanced customization
- Build community features
- Explore automation use cases

---

### Phase 4: Monetization (Post-Phase 3)

**Premium Features:**
- [ ] Unlimited friends (free: 10 max)
- [ ] Advanced pattern tools (gradients, symmetry, shapes)
- [ ] Custom color themes
- [ ] Message templates library (100+)
- [ ] Priority delivery (faster push notifications)
- [ ] Read receipts
- [ ] Message scheduling
- [ ] Analytics (delivery stats, engagement metrics)

**Pricing:**
- Free tier: 10 friends, basic features
- Premium: $2.99/month or $19.99/year
- Family plan: $4.99/month (up to 6 users)

**Business Model:**
- Freemium (free core features, premium advanced features)
- No ads (preserves aesthetic and experience)
- Optional tips/donations (support development)

---

## 12. Dependencies & Risks

### 12.1 Third-Party Services

**Required:**
- **APNs (Apple Push Notification Service):** Critical for real-time delivery
  - Risk: APNs downtime = no message delivery
  - Mitigation: WebSocket fallback, message queue

- **Cloud Hosting (AWS/Heroku):** Server infrastructure
  - Risk: Outage = service unavailable
  - Mitigation: Multi-region deployment, auto-scaling

- **PostgreSQL Database:** User and message storage
  - Risk: Data loss or corruption
  - Mitigation: Daily backups, replication

- **Redis Cache:** Message caching, online status
  - Risk: Cache invalidation issues
  - Mitigation: TTL policies, cache warming

**Optional:**
- **Firebase Analytics:** User behavior tracking
  - Alternative: Self-hosted analytics (Plausible)

- **Sentry/Crashlytics:** Error monitoring
  - Alternative: Self-hosted Sentry instance

- **Twilio:** SMS verification for phone auth
  - Alternative: Email-only auth

- **SendGrid:** Email verification and notifications
  - Alternative: AWS SES

---

### 12.2 Technical Risks

**Risk 1: Widget Refresh Limitations**
- **Description:** iOS may not refresh widgets frequently enough for real-time messaging
- **Impact:** Messages appear delayed, poor user experience
- **Probability:** Medium
- **Mitigation:**
  - Use silent push notifications to trigger immediate refresh
  - Set user expectations (not instant messaging like iMessage)
  - Provide in-app notification as fallback

**Risk 2: Animation Performance on Older Devices**
- **Description:** Split-flap animation may be choppy on iPhone X or older
- **Impact:** Poor visual experience, user complaints
- **Probability:** High
- **Mitigation:**
  - Reduce animation complexity on low-end devices
  - Implement Reduce Motion fallback
  - Set minimum device requirement (iPhone X+)

**Risk 3: End-to-End Encryption Complexity**
- **Description:** Signal Protocol implementation is complex, prone to bugs
- **Impact:** Security vulnerabilities, delayed launch
- **Probability:** Medium
- **Mitigation:**
  - Use battle-tested library (libsignal-protocol-swift)
  - Thorough security audit before launch
  - Start with transport encryption only (TLS), add E2EE in Phase 2

**Risk 4: APNs Rate Limiting**
- **Description:** Sending too many push notifications may trigger APNs rate limits
- **Impact:** Messages fail to deliver
- **Probability:** Low (for typical usage), High (if viral spike)
- **Mitigation:**
  - Batch notifications where possible
  - Monitor APNs response codes
  - Implement exponential backoff

**Risk 5: Widget Timeline Complexity**
- **Description:** Managing animation state in WidgetKit timeline is complex
- **Impact:** Bugs, incorrect animations, state desync
- **Probability:** High
- **Mitigation:**
  - Simplify timeline to single entry (current state)
  - Pre-compute animation metadata in timeline provider
  - Extensive testing on device (not simulator)

---

### 12.3 Business Risks

**Risk 1: Low User Adoption**
- **Description:** Users don't understand the product or find it useful
- **Impact:** Low growth, product failure
- **Probability:** Medium
- **Mitigation:**
  - Clear onboarding explaining value proposition
  - Beta test with target audience (couples, families)
  - Marketing focus on nostalgia and design aesthetics

**Risk 2: Competition from Existing Apps**
- **Description:** iMessage, WhatsApp dominate messaging; widgets underutilized
- **Impact:** Difficulty acquiring users
- **Probability:** High
- **Mitigation:**
  - Position as complement to iMessage, not replacement
  - Focus on unique value (split-flap aesthetic, widget-first)
  - Target niche audiences (design enthusiasts, retro lovers)

**Risk 3: Platform Policy Changes**
- **Description:** Apple changes WidgetKit policies or capabilities
- **Impact:** Core features break or require redesign
- **Probability:** Low (but impactful)
- **Mitigation:**
  - Stay updated on WWDC announcements
  - Design flexible architecture
  - Build relationships with Apple Developer Relations

**Risk 4: Spam and Abuse**
- **Description:** Bad actors use platform for spam or harassment
- **Impact:** User trust erodes, app store removal
- **Probability:** Medium (as platform grows)
- **Mitigation:**
  - Rate limiting and spam detection (see section 8.4)
  - User reporting and moderation tools
  - Terms of Service and community guidelines

---

### 12.4 Resource Constraints

**Team Requirements (MVP):**
- 1 iOS Developer (SwiftUI, WidgetKit expert)
- 1 Backend Developer (Swift Vapor or Node.js)
- 1 Designer (UI/UX, animation design)
- 0.5 DevOps (server setup, CI/CD)

**Timeline Risk:**
- **Optimistic:** 3 months (tight schedule, minimal polish)
- **Realistic:** 4-5 months (includes testing, iteration)
- **Pessimistic:** 6+ months (if major technical issues)

**Budget Estimate (MVP):**
- Development: $80k-120k (4 months × $20-30k/month loaded cost)
- Infrastructure: $500-1000/month (AWS, APNs, tools)
- Apple Developer Program: $99/year
- Design tools: $50/month (Figma)
- **Total:** $85k-125k

---

## 13. Open Questions

### Product Questions

1. **Should we support group messaging or keep it 1-to-1 only?**
   - Option A: 1-to-1 only (simpler, MVP-friendly)
   - Option B: Multi-recipient broadcast (current design)
   - Option C: True group conversations (more complex)
   - **Recommendation:** Option B (multi-recipient broadcast without group chat)

2. **What happens if a user receives messages from 10 different senders?**
   - Do they need 10 separate widgets?
   - Or a single widget that cycles through senders?
   - **Recommendation:** Multiple widgets (clearer, more iOS-native)

3. **Should there be a companion Apple Watch app?**
   - Pros: Full ecosystem coverage, wrist notifications
   - Cons: Tiny screen, limited split-flap visibility
   - **Recommendation:** Phase 3 feature (complications showing latest sender)

4. **How do we handle emoji rendering in split-flap style?**
   - Option A: Full-color emoji (breaks aesthetic)
   - Option B: Monochrome emoji outlines (consistent style)
   - **Recommendation:** Option A for extended set, Option B for patterns

5. **Should users be able to send messages to non-users?**
   - Option A: App-only (recipient must have app installed)
   - Option B: SMS/email fallback (send link to message)
   - **Recommendation:** Option A (MVP), Option B (Phase 2)

---

### Technical Questions

6. **Which backend framework: Swift Vapor or Node.js?**
   - Vapor: Code sharing with iOS, type-safe
   - Node.js: Larger ecosystem, more libraries
   - **Recommendation:** Swift Vapor (team expertise, code reuse)

7. **Should we use Core Data or SwiftData for local storage?**
   - Core Data: Mature, battle-tested
   - SwiftData: Modern, SwiftUI-native (iOS 17+)
   - **Recommendation:** SwiftData (future-proof, simpler API)

8. **How to handle widget animation state across app termination?**
   - Store animation progress in UserDefaults?
   - Always restart animation from beginning?
   - **Recommendation:** Restart from beginning (simpler, acceptable UX)

9. **Should we build custom split-flap font or use SF Pro?**
   - Custom: Perfect aesthetic match
   - SF Pro: Free, no licensing issues
   - **Recommendation:** Custom font (core to experience), with SF Pro fallback

10. **What's the minimum iOS version?**
    - iOS 16: Lock screen widgets, newer WidgetKit APIs
    - iOS 17: Interactive widgets, StandBy mode
    - **Recommendation:** iOS 16 minimum, iOS 17 enhanced features

---

### Design Questions

11. **Should widgets have dark/light mode variants or always black?**
    - Always black: Brand consistency, Vestaboard aesthetic
    - Adaptive: Better iOS integration
    - **Recommendation:** Adaptive with user preference (default black)

12. **How much animation should play in widget vs app?**
    - Widget: Full animation (may drain battery)
    - Widget: First 2 seconds only, then static
    - **Recommendation:** Full animation once, then static until next message

13. **Should there be sound in widgets or only in app?**
    - Widgets can't play sound directly
    - Could trigger sound via App Intent (iOS 17)
    - **Recommendation:** Sound only in app and during notification

14. **What's the fallback experience if animation fails?**
    - Show final message text immediately
    - Show error state
    - **Recommendation:** Show final text (graceful degradation)

---

### Business Questions

15. **What's the monetization timeline?**
    - Launch with premium tier from day 1
    - Free for first 6-12 months, then add premium
    - **Recommendation:** Free for 6 months, gather feedback, then introduce premium

16. **Should there be a free tier limit?**
    - Unlimited friends (free)
    - 10 friend limit, upgrade for unlimited
    - **Recommendation:** Free MVP, 10-friend limit in Phase 4

17. **How to market the app?**
    - Product Hunt launch
    - Apple App Store feature pitch
    - Design community (Dribbble, Behance)
    - **Recommendation:** All of the above, focus on design communities

18. **Should we pursue Apple Design Award?**
    - High visibility if won
        - Significant effort to apply
    - **Recommendation:** Yes (aligns with design-first approach)

---

## Appendix A: Technical Specifications

### Animation Mathematics

**Character Flip Duration Calculation:**
```swift
func calculateFlipDuration(from: Character, to: Character) -> TimeInterval {
    let path = FlipAnimation(from: from, to: to).path
    let flipCount = path.count - 1
    let msPerFlip = 120.0 // milliseconds
    return Double(flipCount) * (msPerFlip / 1000.0)
}

// Example:
// 'A' → 'Z': 25 flips × 120ms = 3.0 seconds
// 'A' → 'B': 1 flip × 120ms = 0.12 seconds
// 'Z' → 'A': 1 flip × 120ms = 0.12 seconds (wraps around)
```

**Stagger Timing (Cascade Effect):**
```swift
func calculateStartDelay(row: Int, column: Int) -> TimeInterval {
    let columnDelay = Double(column) * 0.02 // 20ms per column
    let rowDelay = Double(row) * 0.05 // 50ms per row
    return columnDelay + rowDelay
}

// Example (3×5 grid):
// (0,0): 0ms
// (0,1): 20ms
// (0,2): 40ms
// (1,0): 50ms
// (1,1): 70ms
// ...
```

---

### API Rate Limiting

**Token Bucket Algorithm:**
```swift
actor RateLimiter {
    private var tokens: Int
    private let maxTokens: Int
    private let refillRate: Int // tokens per second
    private var lastRefill: Date

    init(maxTokens: Int, refillRate: Int) {
        self.tokens = maxTokens
        self.maxTokens = maxTokens
        self.refillRate = refillRate
        self.lastRefill = Date()
    }

    func consume(_ count: Int = 1) async -> Bool {
        await refill()

        if tokens >= count {
            tokens -= count
            return true
        }
        return false
    }

    private func refill() {
        let now = Date()
        let elapsed = now.timeIntervalSince(lastRefill)
        let newTokens = Int(elapsed * Double(refillRate))

        if newTokens > 0 {
            tokens = min(tokens + newTokens, maxTokens)
            lastRefill = now
        }
    }
}

// Usage:
let messageLimiter = RateLimiter(maxTokens: 50, refillRate: 1) // 50/hour
if await messageLimiter.consume() {
    // Send message
} else {
    throw APIError.rateLimitExceeded
}
```

---

### Push Notification Payload

**Silent Push (Widget Refresh):**
```json
{
  "aps": {
    "content-available": 1,
    "sound": ""
  },
  "messageID": "550e8400-e29b-41d4-a716-446655440000",
  "senderID": "650e8400-e29b-41d4-a716-446655440001",
  "type": "message.new"
}
```

**Alert Push (User Notification):**
```json
{
  "aps": {
    "alert": {
      "title": "Alice sent a message",
      "body": "HELLO WORLD!",
      "sound": "flip.caf"
    },
    "badge": 1,
    "mutable-content": 1,
    "category": "MESSAGE",
    "thread-id": "650e8400-e29b-41d4-a716-446655440001"
  },
  "messageID": "550e8400-e29b-41d4-a716-446655440000",
  "senderID": "650e8400-e29b-41d4-a716-446655440001"
}
```

---

## Appendix B: Design Assets

### Color Specifications

```swift
extension Color {
    // VestaWidget Brand Colors
    static let vestaBlack = Color(hex: "#000000")
    static let vestaWhite = Color(hex: "#FFFFFF")
    static let vestaOrange = Color(hex: "#FF6600")

    // Pattern Colors
    static let vestaRed = Color(hex: "#FF0000")
    static let vestaYellow = Color(hex: "#FFCC00")
    static let vestaGreen = Color(hex: "#00CC00")
    static let vestaBlue = Color(hex: "#0066FF")
    static let vestaViolet = Color(hex: "#6600CC")

    // Helper
    init(hex: String) {
        let scanner = Scanner(string: hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}
```

---

## Conclusion

VestaWidget is a unique messaging experience that combines the nostalgic charm of mechanical split-flap displays with modern widget technology across the Apple ecosystem. By focusing on ephemeral, present-moment communication with beautiful animations and sound design, it offers a refreshing alternative to traditional messaging apps.

The MVP phase will validate core assumptions around user adoption and widget engagement, while subsequent phases will expand platform support and creative capabilities. With careful attention to performance, privacy, and design quality, VestaWidget has the potential to become a beloved communication tool for design-conscious Apple users.

**Next Steps:**
1. Review and approve PRD with stakeholders
2. Finalize technical architecture decisions (answered open questions)
3. Create detailed sprint plan for Month 1
4. Begin development on authentication and core data models
5. Design first mockups and animation prototypes

---

**Document Version History:**
- v1.0 (2025-11-16): Initial comprehensive PRD created
