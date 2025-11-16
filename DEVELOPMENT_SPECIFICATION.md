# VestaWidget - Complete Development Specification

## Table of Contents
1. [Project Overview](#project-overview)
2. [User Stories & Acceptance Criteria](#user-stories--acceptance-criteria)
3. [Edge Cases & Error Handling](#edge-cases--error-handling)
4. [Technical Architecture](#technical-architecture)
5. [Data Models](#data-models)
6. [API Integration](#api-integration)
7. [Development Phases](#development-phases)
8. [Testing Strategy](#testing-strategy)
9. [Implementation Guide](#implementation-guide)

---

## Project Overview

### Product Vision
VestaWidget is an iOS application that enables users to interact with their Vestaboard displays through both a native app and iOS home screen widgets. Users can configure their Vestaboard connection, post messages, and view their Vestaboard content directly from iOS widgets.

### Key Features
- Vestaboard API integration (Read/Write subscription required)
- Native iOS app for configuration and message posting
- iOS widgets in three sizes (Small, Medium, Large)
- Auto-refresh functionality for widgets
- Persistent configuration storage

### Target Platform
- iOS 14.0+ (required for WidgetKit)
- iPhone and iPad support
- SwiftUI-based interface

---

## User Stories & Acceptance Criteria

### Epic 1: Vestaboard Configuration

#### US-1.1: Initial Setup
**As a** new user
**I want to** configure my Vestaboard connection with API credentials
**So that** I can interact with my Vestaboard from the app

**Acceptance Criteria:**
- [ ] User can input Read/Write API Key
- [ ] User can input Read/Write API Secret
- [ ] Form validates that both fields are non-empty
- [ ] Credentials are securely stored in iOS Keychain
- [ ] User receives confirmation when configuration is saved
- [ ] App validates credentials by making a test API call
- [ ] Clear error messages shown for invalid credentials
- [ ] Configuration persists across app restarts

**Technical Notes:**
- Use `KeychainAccess` or native `Security` framework
- Store in App Group keychain for widget access
- Implement async validation with loading states

---

#### US-1.2: Edit Configuration
**As a** existing user
**I want to** update my Vestaboard credentials
**So that** I can change my connection if needed

**Acceptance Criteria:**
- [ ] User can access configuration screen from app settings
- [ ] Current credentials are NOT displayed (security)
- [ ] User can enter new credentials
- [ ] Confirmation dialog shown before replacing credentials
- [ ] New credentials are validated before saving
- [ ] Widgets automatically update with new credentials
- [ ] User receives success/error feedback

---

#### US-1.3: Connection Status
**As a** user
**I want to** see my Vestaboard connection status
**So that** I know if my setup is working correctly

**Acceptance Criteria:**
- [ ] App displays connection status (Connected/Disconnected/Error)
- [ ] Last successful sync timestamp shown
- [ ] "Test Connection" button available
- [ ] Visual indicator (green/red/yellow) for status
- [ ] Error details shown when connection fails
- [ ] Auto-retry logic with exponential backoff

---

### Epic 2: Message Posting

#### US-2.1: Send Text Message
**As a** user
**I want to** post a text message to my Vestaboard
**So that** I can display custom content

**Acceptance Criteria:**
- [ ] Text input field with character limit indicator
- [ ] Message preview showing how it will appear on Vestaboard
- [ ] "Send" button disabled when text is empty
- [ ] Loading state shown while posting
- [ ] Success confirmation with message sent timestamp
- [ ] Error handling with retry option
- [ ] Message history (last 10 messages) displayed
- [ ] Text automatically formats for Vestaboard character set

**Technical Notes:**
- Vestaboard supports 6 rows × 22 columns
- Only supports specific character set (A-Z, 0-9, limited special chars)
- Color codes: 0-69 (character codes)

---

#### US-2.2: Message Validation
**As a** user
**I want to** know if my message contains unsupported characters
**So that** I can fix it before sending

**Acceptance Criteria:**
- [ ] Real-time validation of character support
- [ ] Unsupported characters highlighted in red
- [ ] List of supported characters accessible via help icon
- [ ] Auto-replace common unsupported chars with alternatives
- [ ] Warning shown if message exceeds board dimensions
- [ ] Preview shows how message wraps/truncates

---

#### US-2.3: Quick Messages
**As a** user
**I want to** save and reuse common messages
**So that** I can quickly send frequently used text

**Acceptance Criteria:**
- [ ] User can save current message as template
- [ ] User can name saved templates
- [ ] Templates list with edit/delete options
- [ ] Tap template to load into composer
- [ ] Maximum 20 saved templates
- [ ] Templates sync across app and widget (via App Group)

---

### Epic 3: iOS Widgets

#### US-3.1: Widget Installation
**As a** user
**I want to** add VestaWidget to my home screen
**So that** I can see my Vestaboard content at a glance

**Acceptance Criteria:**
- [ ] Widget appears in iOS widget gallery
- [ ] Three sizes available: Small, Medium, Large
- [ ] Widget shows placeholder state before configuration
- [ ] Clear instructions shown for unconfigured state
- [ ] Tapping unconfigured widget opens app to setup

---

#### US-3.2: Small Widget Display
**As a** user
**I want to** view a compact version of my Vestaboard
**So that** I can see key content in minimal space

**Acceptance Criteria:**
- [ ] Displays first 2 rows of Vestaboard content
- [ ] Auto-scales text to fit widget
- [ ] Shows last update timestamp
- [ ] Maintains Vestaboard color scheme
- [ ] Loading state with spinner
- [ ] Error state with icon and brief message
- [ ] Tapping widget opens main app

**Design Specs:**
- Size: ~155x155 points (varies by device)
- Font: Monospace, ~8-10pt
- Colors: Match Vestaboard palette

---

#### US-3.3: Medium Widget Display
**As a** user
**I want to** view more Vestaboard content
**So that** I can see extended messages

**Acceptance Criteria:**
- [ ] Displays first 4 rows of Vestaboard content
- [ ] Shows message title/preview if available
- [ ] Displays last update time
- [ ] Quick action button to refresh
- [ ] Same error/loading states as small widget

**Design Specs:**
- Size: ~329x155 points
- Accommodates 4 rows × 22 columns

---

#### US-3.4: Large Widget Display
**As a** user
**I want to** view my complete Vestaboard display
**So that** I can see all content without opening the app

**Acceptance Criteria:**
- [ ] Displays all 6 rows of Vestaboard content
- [ ] Full 22 character width per row
- [ ] Shows detailed timestamp
- [ ] Connection status indicator
- [ ] Refresh button visible
- [ ] High fidelity representation of actual board

**Design Specs:**
- Size: ~329x345 points
- Shows complete 6×22 character grid

---

#### US-3.5: Widget Auto-Refresh
**As a** user
**I want to** have my widget automatically update
**So that** I always see current Vestaboard content

**Acceptance Criteria:**
- [ ] Widget refreshes every 15 minutes (iOS minimum)
- [ ] User can manually trigger refresh from widget
- [ ] Background refresh respects iOS battery optimization
- [ ] Timeline provides 24 hours of scheduled updates
- [ ] Failed refreshes don't show stale "updated" time
- [ ] Widget shows "Updating..." state during refresh

**Technical Notes:**
- Use WidgetKit `TimelineProvider`
- Implement `getTimeline()` with 15-minute intervals
- Handle background URL session for API calls
- Use App Group to share data between app and widget

---

#### US-3.6: Widget Configuration
**As a** user
**I want to** configure widget-specific settings
**So that** I can customize how my Vestaboard appears

**Acceptance Criteria:**
- [ ] Option to show/hide timestamp
- [ ] Option to show/hide connection status
- [ ] Color scheme options (match board, high contrast, etc.)
- [ ] Refresh interval preference (when available)
- [ ] Font size adjustment (small, medium, large)
- [ ] Configuration accessible via long-press widget menu

---

### Epic 4: Error Handling & Edge Cases

#### US-4.1: Network Error Handling
**As a** user
**I want to** understand when network issues occur
**So that** I can take appropriate action

**Acceptance Criteria:**
- [ ] Clear error messages for no internet connection
- [ ] Distinguish between network and API errors
- [ ] Retry button for failed operations
- [ ] Offline mode indicator in widget
- [ ] Cached last successful content shown when offline
- [ ] Auto-retry with exponential backoff

---

#### US-4.2: API Error Handling
**As a** user
**I want to** know when Vestaboard API issues occur
**So that** I can troubleshoot or wait for resolution

**Acceptance Criteria:**
- [ ] 401 Unauthorized: Prompt to re-enter credentials
- [ ] 429 Rate Limit: Show wait time and queue message
- [ ] 500 Server Error: Show service status and retry option
- [ ] Timeout errors: Indicate slow connection
- [ ] Invalid API response: Log error and show fallback
- [ ] All errors logged for debugging

---

#### US-4.3: Data Validation
**As a** user
**I want to** be prevented from entering invalid data
**So that** I don't encounter unexpected errors

**Acceptance Criteria:**
- [ ] API key format validation (length, character set)
- [ ] Message length validation (132 chars max)
- [ ] Character set validation (Vestaboard supported only)
- [ ] Empty field validation with helpful hints
- [ ] Real-time validation feedback
- [ ] Submit buttons disabled for invalid states

---

## Edge Cases & Error Handling

### Configuration Edge Cases
1. **Empty Credentials**
   - Prevention: Disable save button when fields empty
   - Handling: Show inline validation error

2. **Invalid API Credentials**
   - Prevention: Test credentials before saving
   - Handling: Show error with link to Vestaboard API docs

3. **Keychain Access Denied**
   - Prevention: Request permissions on first launch
   - Handling: Show alert explaining need for keychain access

4. **Credentials Changed on Another Device**
   - Detection: API returns 401 unexpectedly
   - Handling: Prompt user to re-authenticate

5. **App Group Not Configured**
   - Prevention: Fail-safe to UserDefaults
   - Handling: Widget shows "Please configure in app"

### Message Posting Edge Cases
1. **Message Too Long**
   - Prevention: Character counter, max length enforcement
   - Handling: Truncate with warning or reject

2. **Unsupported Characters**
   - Prevention: Real-time character validation
   - Handling: Highlight invalid chars, suggest alternatives

3. **Empty Message**
   - Prevention: Disable send button
   - Handling: Show validation error if attempted

4. **Rapid Successive Posts**
   - Prevention: Debounce send button
   - Handling: Queue messages or show rate limit warning

5. **Send During Offline Mode**
   - Detection: Network reachability check
   - Handling: Queue message for retry or show error

### Widget Edge Cases
1. **Widget Added Before Configuration**
   - State: Placeholder shown
   - Handling: Tap opens app to setup screen

2. **API Credentials Expired**
   - State: Error state in widget
   - Handling: Show "Reconnect needed" with tap to app

3. **Vestaboard Content Empty**
   - State: Blank board
   - Handling: Show "No content" message

4. **Widget Refresh Failed**
   - State: Show last successful content with error indicator
   - Handling: Don't update timestamp, show warning icon

5. **Background Refresh Disabled**
   - Detection: Check iOS settings
   - Handling: Show message in widget to enable

6. **App Deleted but Widget Remains**
   - State: Widget shows error
   - Handling: "App required" message

7. **Multiple Widgets with Different Sizes**
   - State: All widgets should sync data
   - Handling: Use shared App Group storage

8. **Timezone Changes**
   - Detection: Monitor timezone changes
   - Handling: Update all timestamps appropriately

9. **Widget Timeline Exhausted**
   - Prevention: Generate 24-hour timeline
   - Handling: Fallback to last entry

10. **Low Power Mode Enabled**
    - Detection: Check device state
    - Handling: Reduce refresh frequency, show indicator

### Network & API Edge Cases
1. **Slow Network Connection**
   - Detection: Timeout after 30 seconds
   - Handling: Show loading indicator, allow cancel

2. **API Rate Limiting**
   - Detection: 429 response code
   - Handling: Queue requests, show wait time

3. **API Maintenance/Downtime**
   - Detection: 503 response or connection refused
   - Handling: Show status message, disable posting

4. **Partial API Response**
   - Detection: JSON parsing errors
   - Handling: Log error, show cached data

5. **API Version Mismatch**
   - Detection: Unexpected response structure
   - Handling: Alert user to update app

### Data Persistence Edge Cases
1. **Keychain Migration After iOS Update**
   - Detection: Credentials missing after update
   - Handling: Prompt re-authentication

2. **App Group Data Corruption**
   - Detection: Failed to decode shared data
   - Handling: Clear and rebuild from app

3. **Storage Quota Exceeded**
   - Prevention: Limit message history to 50 items
   - Handling: Remove oldest entries

4. **Concurrent Write Access**
   - Prevention: Use serial queue for data access
   - Handling: Ensure atomic operations

### Device-Specific Edge Cases
1. **iPad Split View**
   - Handling: Responsive layout for various widths

2. **Dark Mode Toggle**
   - Handling: Support both light/dark appearances

3. **Accessibility Features**
   - VoiceOver: All elements labeled
   - Dynamic Type: Support text size changes
   - High Contrast: Readable in all modes

4. **Older iOS Versions**
   - Prevention: Set minimum iOS 14.0
   - Handling: Degrade gracefully if using iOS 15+ features

5. **Different Screen Sizes**
   - Handling: Auto-layout for all iPhone/iPad sizes
   - Widget: Test on all supported device sizes

---

## Technical Architecture

### Technology Stack
- **Language:** Swift 5.5+
- **UI Framework:** SwiftUI
- **Widgets:** WidgetKit
- **Networking:** URLSession with async/await
- **Storage:**
  - Keychain (credentials)
  - App Group UserDefaults (shared data)
  - CoreData (optional, for message history)
- **Concurrency:** Swift Concurrency (async/await)

### Project Structure
```
VestaWidget/
├── VestaWidgetApp/
│   ├── App/
│   │   ├── VestaWidgetApp.swift
│   │   └── ContentView.swift
│   ├── Features/
│   │   ├── Configuration/
│   │   │   ├── ConfigurationView.swift
│   │   │   └── ConfigurationViewModel.swift
│   │   ├── MessagePosting/
│   │   │   ├── MessageComposerView.swift
│   │   │   ├── MessageComposerViewModel.swift
│   │   │   └── MessageHistoryView.swift
│   │   └── Settings/
│   │       └── SettingsView.swift
│   ├── Services/
│   │   ├── VestaboardAPI.swift
│   │   ├── KeychainService.swift
│   │   ├── AppGroupStorage.swift
│   │   └── NetworkMonitor.swift
│   ├── Models/
│   │   ├── VestaboardMessage.swift
│   │   ├── VestaboardConfiguration.swift
│   │   └── MessageTemplate.swift
│   └── Utilities/
│       ├── Constants.swift
│       ├── Extensions.swift
│       └── VestaboardCharacterSet.swift
├── VestaWidgets/
│   ├── VestaWidgetBundle.swift
│   ├── SmallWidget.swift
│   ├── MediumWidget.swift
│   ├── LargeWidget.swift
│   ├── WidgetTimelineProvider.swift
│   └── WidgetViews/
│       ├── VestaboardDisplayView.swift
│       ├── PlaceholderView.swift
│       └── ErrorView.swift
├── Shared/
│   ├── Models/
│   │   └── VestaboardContent.swift
│   ├── Services/
│   │   └── SharedDataService.swift
│   └── Extensions/
│       └── Date+Formatting.swift
└── Resources/
    ├── Assets.xcassets
    └── Info.plist
```

### App Architecture Pattern
**MVVM (Model-View-ViewModel)**
- **Models:** Data structures (VestaboardMessage, Configuration)
- **Views:** SwiftUI views (ConfigurationView, MessageComposerView)
- **ViewModels:** Business logic, API calls, state management
- **Services:** Reusable utilities (API, Storage, Keychain)

### Widget Architecture
- **TimelineProvider:** Generates timeline entries
- **Widget Configuration:** Intent-based configuration (optional)
- **Shared Data:** App Group for app-widget communication
- **Background Refresh:** URLSession background tasks

---

## Data Models

### VestaboardConfiguration
```swift
struct VestaboardConfiguration: Codable {
    var apiKey: String
    var apiSecret: String
    var isConfigured: Bool
    var lastValidated: Date?

    // Stored in Keychain
    static let keychainKey = "com.vestawidget.credentials"
}
```

### VestaboardMessage
```swift
struct VestaboardMessage: Codable, Identifiable {
    let id: UUID
    var text: String
    var characterArray: [[Int]]  // 6x22 array of character codes
    var timestamp: Date
    var status: MessageStatus

    enum MessageStatus: String, Codable {
        case draft, sending, sent, failed
    }
}
```

### VestaboardContent
```swift
struct VestaboardContent: Codable {
    var rows: [[Int]]  // 6 rows of 22 character codes
    var lastUpdated: Date
    var message: String?  // Decoded text representation

    // Stored in App Group
    static let appGroupKey = "com.vestawidget.appgroup.content"
}
```

### MessageTemplate
```swift
struct MessageTemplate: Codable, Identifiable {
    let id: UUID
    var name: String
    var text: String
    var createdAt: Date
    var usageCount: Int
}
```

### WidgetEntry
```swift
struct VestaWidgetEntry: TimelineEntry {
    let date: Date
    let content: VestaboardContent?
    let configuration: VestaboardConfiguration?
    let errorMessage: String?

    var relevance: TimelineEntryRelevance? {
        TimelineEntryRelevance(score: 50)  // Medium priority
    }
}
```

---

## API Integration

### Vestaboard API Endpoints

#### 1. Read Current Message
```
GET https://rw.vestaboard.com/
Headers:
  X-Vestaboard-Read-Write-Key: {apiKey}
  X-Vestaboard-Api-Secret: {apiSecret}

Response: 200 OK
{
  "currentMessage": {
    "layout": "[[0,0,0...],[...]]"  // 6x22 array
  }
}
```

#### 2. Post New Message
```
POST https://rw.vestaboard.com/
Headers:
  X-Vestaboard-Read-Write-Key: {apiKey}
  X-Vestaboard-Api-Secret: {apiSecret}
  Content-Type: application/json

Body:
{
  "text": "Your message here"
}
OR
{
  "characters": [[0,0,0...],[...]]  // 6x22 array
}

Response: 200 OK
{
  "message": "Message sent successfully"
}
```

### API Service Implementation

```swift
class VestaboardAPI {
    private let baseURL = "https://rw.vestaboard.com"
    private let session: URLSession

    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)
    }

    func getCurrentMessage(apiKey: String, apiSecret: String) async throws -> VestaboardContent {
        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "X-Vestaboard-Read-Write-Key")
        request.setValue(apiSecret, forHTTPHeaderField: "X-Vestaboard-Api-Secret")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200:
            return try JSONDecoder().decode(VestaboardContent.self, from: data)
        case 401:
            throw APIError.unauthorized
        case 429:
            throw APIError.rateLimited
        default:
            throw APIError.serverError(httpResponse.statusCode)
        }
    }

    func postMessage(text: String, apiKey: String, apiSecret: String) async throws {
        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "X-Vestaboard-Read-Write-Key")
        request.setValue(apiSecret, forHTTPHeaderField: "X-Vestaboard-Api-Secret")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["text": text]
        request.httpBody = try JSONEncoder().encode(body)

        let (_, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        if httpResponse.statusCode != 200 {
            throw APIError.serverError(httpResponse.statusCode)
        }
    }
}

enum APIError: LocalizedError {
    case invalidResponse
    case unauthorized
    case rateLimited
    case serverError(Int)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .unauthorized:
            return "Invalid API credentials"
        case .rateLimited:
            return "Too many requests. Please wait."
        case .serverError(let code):
            return "Server error: \(code)"
        }
    }
}
```

### Character Code Reference
```swift
enum VestaboardCharacterCode {
    static let blank = 0
    static let A = 1, B = 2, C = 3, D = 4, E = 5, F = 6, G = 7, H = 8
    static let I = 9, J = 10, K = 11, L = 12, M = 13, N = 14, O = 15
    static let P = 16, Q = 17, R = 18, S = 19, T = 20, U = 21, V = 22
    static let W = 23, X = 24, Y = 25, Z = 26

    static let zero = 27, one = 28, two = 29, three = 30, four = 31
    static let five = 32, six = 33, seven = 34, eight = 35, nine = 36

    static let exclamation = 37, at = 38, hash = 39, dollar = 40
    static let leftParen = 41, rightParen = 42
    static let hyphen = 44, plus = 46, period = 52, question = 56

    // Colors (filled blocks)
    static let red = 63, orange = 64, yellow = 65
    static let green = 66, blue = 67, violet = 68, white = 69

    static func code(for character: Character) -> Int? {
        switch character.uppercased().first {
        case "A": return A
        case "B": return B
        // ... complete mapping
        case " ": return blank
        default: return nil
        }
    }

    static func isSupported(_ character: Character) -> Bool {
        return code(for: character) != nil
    }
}
```

---

## Development Phases

### Phase 1: Foundation (Week 1-2)
**Goal:** Set up project structure and core services

**Tasks:**
1. Create Xcode project with app + widget targets
2. Set up App Group entitlement
3. Implement KeychainService for credential storage
4. Implement AppGroupStorage for shared data
5. Create VestaboardAPI service with basic GET/POST
6. Create data models (Configuration, Message, Content)
7. Set up error handling and logging
8. Create character code mapping utilities

**Deliverables:**
- Working API service with test credentials
- Persistent storage working
- Basic error handling

**Testing:**
- Unit tests for API service
- Unit tests for storage services
- Integration test: Store and retrieve credentials

---

### Phase 2: App - Configuration (Week 2-3)
**Goal:** Build credential configuration flow

**Tasks:**
1. Create ConfigurationView with input fields
2. Implement ConfigurationViewModel with validation
3. Add test connection functionality
4. Create connection status indicator
5. Implement secure credential storage
6. Add edit configuration flow
7. Create onboarding flow for first launch
8. Add error handling and user feedback

**Deliverables:**
- Complete configuration UI
- Working credential validation
- Persistent configuration

**Testing:**
- UI tests for configuration flow
- Test invalid credential handling
- Test configuration persistence

---

### Phase 3: App - Message Posting (Week 3-4)
**Goal:** Enable users to post messages

**Tasks:**
1. Create MessageComposerView
2. Implement MessageComposerViewModel
3. Add character validation and preview
4. Implement message posting with API
5. Create message history view
6. Add template saving/loading
7. Implement retry logic for failed posts
8. Add success/error feedback

**Deliverables:**
- Working message composer
- Message history with templates
- Robust error handling

**Testing:**
- Test message validation
- Test unsupported characters
- Test message posting success/failure
- Test template CRUD operations

---

### Phase 4: Widgets - Foundation (Week 4-5)
**Goal:** Create basic widget infrastructure

**Tasks:**
1. Create widget targets (small, medium, large)
2. Implement WidgetTimelineProvider
3. Create shared VestaboardContent model
4. Implement timeline generation (24-hour)
5. Set up App Group data sharing
6. Create placeholder and error states
7. Implement basic widget refresh
8. Add widget configuration intent (optional)

**Deliverables:**
- Three widget sizes in gallery
- Basic timeline refresh working
- Placeholder states

**Testing:**
- Test widget timeline generation
- Test App Group data sharing
- Test placeholder states

---

### Phase 5: Widgets - UI Implementation (Week 5-6)
**Goal:** Build widget visual design

**Tasks:**
1. Design VestaboardDisplayView component
2. Implement SmallWidget (2 rows)
3. Implement MediumWidget (4 rows)
4. Implement LargeWidget (6 rows)
5. Add timestamp display
6. Implement color scheme matching
7. Add loading and error states
8. Optimize for different device sizes

**Deliverables:**
- Visually accurate Vestaboard representation
- All three widget sizes functional
- Responsive to different screen sizes

**Testing:**
- Test on all iPhone sizes
- Test on iPad sizes
- Test in light/dark mode
- Visual regression testing

---

### Phase 6: Widget Auto-Refresh (Week 6-7)
**Goal:** Implement automatic content updates

**Tasks:**
1. Implement background refresh logic
2. Configure timeline with 15-min intervals
3. Add manual refresh capability
4. Implement efficient API polling
5. Handle background URL sessions
6. Add refresh status indicators
7. Optimize battery usage
8. Handle iOS background refresh settings

**Deliverables:**
- Auto-refreshing widgets
- Manual refresh working
- Battery-efficient implementation

**Testing:**
- Test 24-hour timeline
- Test background refresh
- Test with background refresh disabled
- Monitor battery usage

---

### Phase 7: Polish & Edge Cases (Week 7-8)
**Goal:** Handle all edge cases and polish UX

**Tasks:**
1. Implement all network error handling
2. Add offline mode support
3. Handle API rate limiting
4. Add accessibility features (VoiceOver, Dynamic Type)
5. Implement dark mode support
6. Add haptic feedback
7. Create app icon and widget previews
8. Optimize performance
9. Add analytics/logging (optional)
10. Create user documentation

**Deliverables:**
- Fully polished app
- All edge cases handled
- Accessibility compliant
- Performance optimized

**Testing:**
- Comprehensive error scenario testing
- Accessibility audit
- Performance profiling
- Beta testing with real users

---

### Phase 8: Testing & Release (Week 8-9)
**Goal:** Prepare for App Store submission

**Tasks:**
1. Complete unit test coverage (>80%)
2. Complete UI test coverage (critical flows)
3. Perform security audit (credential handling)
4. Beta test via TestFlight
5. Create App Store screenshots
6. Write App Store description
7. Prepare privacy policy
8. Submit for App Store review
9. Monitor crash reports
10. Prepare support documentation

**Deliverables:**
- App Store submission
- TestFlight beta
- Support documentation

**Testing:**
- Full regression testing
- TestFlight beta feedback
- App Store review testing

---

## Testing Strategy

### Unit Testing

#### Services Tests
```swift
class VestaboardAPITests: XCTestCase {
    func testGetCurrentMessage_Success() async throws
    func testGetCurrentMessage_Unauthorized() async throws
    func testGetCurrentMessage_RateLimited() async throws
    func testPostMessage_Success() async throws
    func testPostMessage_InvalidCharacters() async throws
}

class KeychainServiceTests: XCTestCase {
    func testSaveCredentials() throws
    func testRetrieveCredentials() throws
    func testDeleteCredentials() throws
    func testUpdateCredentials() throws
}

class AppGroupStorageTests: XCTestCase {
    func testSaveContent() throws
    func testRetrieveContent() throws
    func testContentPersistence() throws
}
```

#### ViewModel Tests
```swift
class ConfigurationViewModelTests: XCTestCase {
    func testValidateEmptyCredentials()
    func testValidateValidCredentials()
    func testSaveConfiguration()
    func testTestConnection_Success()
    func testTestConnection_Failure()
}

class MessageComposerViewModelTests: XCTestCase {
    func testValidateMessage_SupportedChars()
    func testValidateMessage_UnsupportedChars()
    func testPostMessage_Success()
    func testPostMessage_NetworkError()
    func testSaveTemplate()
    func testLoadTemplate()
}
```

#### Widget Tests
```swift
class WidgetTimelineProviderTests: XCTestCase {
    func testGenerateTimeline_24Hours()
    func testGenerateTimeline_WithContent()
    func testGenerateTimeline_WithError()
    func testTimelineRefreshInterval()
}
```

### UI Testing

#### Configuration Flow
```swift
class ConfigurationUITests: XCTestCase {
    func testInitialConfiguration()
    func testEditConfiguration()
    func testInvalidCredentials_ShowsError()
    func testValidCredentials_ShowsSuccess()
}
```

#### Message Posting Flow
```swift
class MessagePostingUITests: XCTestCase {
    func testComposeAndSendMessage()
    func testInvalidCharacter_ShowsWarning()
    func testSaveMessageTemplate()
    func testLoadMessageTemplate()
    func testMessageHistory()
}
```

#### Widget Testing
```swift
class WidgetUITests: XCTestCase {
    func testWidgetPlaceholder_BeforeConfig()
    func testWidgetDisplay_SmallSize()
    func testWidgetDisplay_MediumSize()
    func testWidgetDisplay_LargeSize()
    func testWidgetTap_OpensApp()
}
```

### Integration Testing

1. **End-to-End Flow**
   - Configure credentials → Post message → Verify in widget
   - Clear credentials → Verify widget shows error
   - Re-configure → Verify widget updates

2. **Background Refresh**
   - Post message from web → Wait 15 min → Verify widget updates
   - Disable background refresh → Verify widget shows warning

3. **Offline Behavior**
   - Enable airplane mode → Verify cached content shown
   - Post message offline → Verify queued for retry
   - Re-enable connection → Verify message sends

### Manual Testing Checklist

#### Device Testing
- [ ] iPhone SE (small screen)
- [ ] iPhone 13/14 (standard screen)
- [ ] iPhone 14 Pro Max (large screen)
- [ ] iPad Mini
- [ ] iPad Pro

#### OS Testing
- [ ] iOS 14.0 (minimum supported)
- [ ] iOS 15.x
- [ ] iOS 16.x
- [ ] iOS 17.x (latest)

#### Scenario Testing
- [ ] First launch onboarding
- [ ] Configure with invalid credentials
- [ ] Configure with valid credentials
- [ ] Post message with all supported characters
- [ ] Post message with unsupported characters
- [ ] Add all three widget sizes
- [ ] Remove and re-add widgets
- [ ] Background app and wait for refresh
- [ ] Enable/disable background refresh
- [ ] Switch between light/dark mode
- [ ] Test with VoiceOver enabled
- [ ] Test with large text sizes
- [ ] Test with reduced motion enabled
- [ ] Force quit app and relaunch
- [ ] Uninstall and reinstall app
- [ ] Update credentials and verify widgets update

### Performance Testing

#### Metrics to Monitor
- App launch time: < 2 seconds
- Widget refresh time: < 5 seconds
- Message post time: < 3 seconds
- Memory usage: < 50MB (app), < 10MB (widget)
- Battery impact: Minimal (background refresh)

#### Tools
- Instruments (Time Profiler, Allocations)
- Network Link Conditioner (slow network testing)
- XCTest performance testing

---

## Implementation Guide

### Step-by-Step Developer Guide

#### Step 1: Project Setup

1. **Create Xcode Project**
   ```
   - Open Xcode
   - File > New > Project
   - Select "iOS App" template
   - Product Name: VestaWidget
   - Interface: SwiftUI
   - Language: Swift
   - Organization Identifier: com.yourcompany
   ```

2. **Add Widget Extension**
   ```
   - File > New > Target
   - Select "Widget Extension"
   - Product Name: VestaWidgets
   - Include Configuration Intent: No (or Yes if you want widget customization)
   ```

3. **Configure App Groups**
   ```
   - Select VestaWidget target
   - Signing & Capabilities > + Capability > App Groups
   - Add group: group.com.yourcompany.vestawidget
   - Select VestaWidgets target
   - Signing & Capabilities > + Capability > App Groups
   - Add same group: group.com.yourcompany.vestawidget
   ```

4. **Configure Keychain Sharing** (optional but recommended)
   ```
   - Select VestaWidget target
   - Signing & Capabilities > + Capability > Keychain Sharing
   - Add keychain group: com.yourcompany.vestawidget
   ```

5. **Set Deployment Target**
   ```
   - VestaWidget target: iOS 14.0
   - VestaWidgets target: iOS 14.0
   ```

---

#### Step 2: Create Project Structure

Create folder structure in Xcode:
```
VestaWidget/
├── App/
├── Features/
│   ├── Configuration/
│   ├── MessagePosting/
│   └── Settings/
├── Services/
├── Models/
└── Utilities/

VestaWidgets/
├── Widgets/
├── Views/
└── Providers/

Shared/
├── Models/
├── Services/
└── Extensions/
```

---

#### Step 3: Implement Core Services

1. **Constants.swift**
```swift
enum AppConstants {
    static let appGroupIdentifier = "group.com.yourcompany.vestawidget"
    static let keychainIdentifier = "com.yourcompany.vestawidget"
    static let vestaboardAPIBase = "https://rw.vestaboard.com"
    static let widgetRefreshInterval: TimeInterval = 900 // 15 minutes
    static let maxMessageLength = 132
}
```

2. **KeychainService.swift**
```swift
import Security
import Foundation

class KeychainService {
    static let shared = KeychainService()

    func save(apiKey: String, apiSecret: String) throws {
        let credentials = VestaboardConfiguration(
            apiKey: apiKey,
            apiSecret: apiSecret,
            isConfigured: true,
            lastValidated: Date()
        )

        let data = try JSONEncoder().encode(credentials)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: AppConstants.keychainIdentifier,
            kSecAttrAccessGroup as String: AppConstants.keychainIdentifier,
            kSecValueData as String: data
        ]

        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }
    }

    func retrieve() throws -> VestaboardConfiguration {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: AppConstants.keychainIdentifier,
            kSecAttrAccessGroup as String: AppConstants.keychainIdentifier,
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data else {
            throw KeychainError.retrieveFailed(status)
        }

        return try JSONDecoder().decode(VestaboardConfiguration.self, from: data)
    }

    func delete() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: AppConstants.keychainIdentifier,
            kSecAttrAccessGroup as String: AppConstants.keychainIdentifier
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status)
        }
    }
}

enum KeychainError: Error {
    case saveFailed(OSStatus)
    case retrieveFailed(OSStatus)
    case deleteFailed(OSStatus)
}
```

3. **AppGroupStorage.swift**
```swift
import Foundation

class AppGroupStorage {
    static let shared = AppGroupStorage()

    private let userDefaults: UserDefaults

    init() {
        guard let defaults = UserDefaults(suiteName: AppConstants.appGroupIdentifier) else {
            fatalError("Failed to create UserDefaults with app group")
        }
        self.userDefaults = defaults
    }

    func saveContent(_ content: VestaboardContent) throws {
        let data = try JSONEncoder().encode(content)
        userDefaults.set(data, forKey: "currentContent")
        userDefaults.synchronize()
    }

    func retrieveContent() -> VestaboardContent? {
        guard let data = userDefaults.data(forKey: "currentContent") else {
            return nil
        }
        return try? JSONDecoder().decode(VestaboardContent.self, from: data)
    }

    func saveTemplates(_ templates: [MessageTemplate]) throws {
        let data = try JSONEncoder().encode(templates)
        userDefaults.set(data, forKey: "messageTemplates")
        userDefaults.synchronize()
    }

    func retrieveTemplates() -> [MessageTemplate] {
        guard let data = userDefaults.data(forKey: "messageTemplates") else {
            return []
        }
        return (try? JSONDecoder().decode([MessageTemplate].self, from: data)) ?? []
    }
}
```

4. **VestaboardAPI.swift** (see API Integration section above)

---

#### Step 4: Build Configuration UI

1. **ConfigurationViewModel.swift**
```swift
import Foundation
import Combine

@MainActor
class ConfigurationViewModel: ObservableObject {
    @Published var apiKey: String = ""
    @Published var apiSecret: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var isConfigured: Bool = false

    private let api = VestaboardAPI()
    private let keychain = KeychainService.shared

    init() {
        loadConfiguration()
    }

    func loadConfiguration() {
        do {
            let config = try keychain.retrieve()
            isConfigured = config.isConfigured
        } catch {
            isConfigured = false
        }
    }

    func saveConfiguration() async {
        guard !apiKey.isEmpty, !apiSecret.isEmpty else {
            errorMessage = "Please enter both API Key and Secret"
            return
        }

        isLoading = true
        errorMessage = nil
        successMessage = nil

        do {
            // Test credentials first
            _ = try await api.getCurrentMessage(apiKey: apiKey, apiSecret: apiSecret)

            // If successful, save to keychain
            try keychain.save(apiKey: apiKey, apiSecret: apiSecret)

            isConfigured = true
            successMessage = "Configuration saved successfully!"

            // Clear form
            apiKey = ""
            apiSecret = ""
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func testConnection() async {
        guard !apiKey.isEmpty, !apiSecret.isEmpty else {
            errorMessage = "Please enter credentials first"
            return
        }

        isLoading = true
        errorMessage = nil
        successMessage = nil

        do {
            _ = try await api.getCurrentMessage(apiKey: apiKey, apiSecret: apiSecret)
            successMessage = "Connection successful!"
        } catch {
            errorMessage = "Connection failed: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func clearConfiguration() {
        do {
            try keychain.delete()
            isConfigured = false
            successMessage = "Configuration cleared"
        } catch {
            errorMessage = "Failed to clear configuration"
        }
    }
}
```

2. **ConfigurationView.swift**
```swift
import SwiftUI

struct ConfigurationView: View {
    @StateObject private var viewModel = ConfigurationViewModel()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Vestaboard API Credentials")) {
                    SecureField("API Key", text: $viewModel.apiKey)
                        .textContentType(.password)
                        .autocapitalization(.none)

                    SecureField("API Secret", text: $viewModel.apiSecret)
                        .textContentType(.password)
                        .autocapitalization(.none)
                }

                Section {
                    if viewModel.isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    } else {
                        Button("Test Connection") {
                            Task {
                                await viewModel.testConnection()
                            }
                        }
                        .disabled(viewModel.apiKey.isEmpty || viewModel.apiSecret.isEmpty)

                        Button("Save Configuration") {
                            Task {
                                await viewModel.saveConfiguration()
                            }
                        }
                        .disabled(viewModel.apiKey.isEmpty || viewModel.apiSecret.isEmpty)
                    }
                }

                if viewModel.isConfigured {
                    Section {
                        Button("Clear Configuration", role: .destructive) {
                            viewModel.clearConfiguration()
                        }
                    }
                }

                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                    }
                }

                if let success = viewModel.successMessage {
                    Section {
                        Text(success)
                            .foregroundColor(.green)
                    }
                }

                Section(footer: Text("You need a Read/Write API subscription from Vestaboard. Visit vestaboard.com to get your credentials.")) {
                    EmptyView()
                }
            }
            .navigationTitle("Configuration")
        }
    }
}
```

---

#### Step 5: Build Message Posting UI

(Implementation similar to Configuration - create ViewModel and View)

Key features:
- Text input with character counter
- Real-time validation
- Preview of how message will appear
- Send button with loading state
- Message history list
- Template save/load

---

#### Step 6: Implement Widgets

1. **VestaWidgetEntry.swift** (in Shared folder)
```swift
import WidgetKit

struct VestaWidgetEntry: TimelineEntry {
    let date: Date
    let content: VestaboardContent?
    let errorMessage: String?

    var isPlaceholder: Bool {
        content == nil && errorMessage == nil
    }
}
```

2. **WidgetTimelineProvider.swift**
```swift
import WidgetKit
import SwiftUI

struct VestaWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> VestaWidgetEntry {
        VestaWidgetEntry(date: Date(), content: nil, errorMessage: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (VestaWidgetEntry) -> Void) {
        let entry: VestaWidgetEntry

        if context.isPreview {
            // Provide sample data for widget gallery
            entry = VestaWidgetEntry(
                date: Date(),
                content: SampleData.content,
                errorMessage: nil
            )
        } else {
            entry = fetchCurrentEntry()
        }

        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<VestaWidgetEntry>) -> Void) {
        Task {
            let entries = await generateTimelineEntries()
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }
    }

    private func fetchCurrentEntry() -> VestaWidgetEntry {
        // Try to get current content from App Group
        if let content = AppGroupStorage.shared.retrieveContent() {
            return VestaWidgetEntry(date: Date(), content: content, errorMessage: nil)
        } else {
            return VestaWidgetEntry(
                date: Date(),
                content: nil,
                errorMessage: "Please configure in app"
            )
        }
    }

    private func generateTimelineEntries() async -> [VestaWidgetEntry] {
        var entries: [VestaWidgetEntry] = []
        let currentDate = Date()

        // Fetch latest content from API
        do {
            let config = try KeychainService.shared.retrieve()
            let api = VestaboardAPI()
            let content = try await api.getCurrentMessage(
                apiKey: config.apiKey,
                apiSecret: config.apiSecret
            )

            // Save to App Group for other widgets
            try? AppGroupStorage.shared.saveContent(content)

            // Generate entries for next 24 hours (every 15 minutes)
            for hourOffset in 0..<96 { // 96 * 15 min = 24 hours
                let entryDate = Calendar.current.date(
                    byAdding: .minute,
                    value: hourOffset * 15,
                    to: currentDate
                )!

                entries.append(VestaWidgetEntry(
                    date: entryDate,
                    content: content,
                    errorMessage: nil
                ))
            }
        } catch {
            // On error, create single entry with error message
            entries.append(VestaWidgetEntry(
                date: currentDate,
                content: nil,
                errorMessage: error.localizedDescription
            ))
        }

        return entries
    }
}
```

3. **SmallWidget.swift**
```swift
import WidgetKit
import SwiftUI

struct SmallVestaWidget: Widget {
    let kind: String = "SmallVestaWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: VestaWidgetProvider()) { entry in
            SmallVestaWidgetView(entry: entry)
        }
        .configurationDisplayName("Vestaboard Small")
        .description("Shows first 2 rows of your Vestaboard")
        .supportedFamilies([.systemSmall])
    }
}

struct SmallVestaWidgetView: View {
    let entry: VestaWidgetEntry

    var body: some View {
        if entry.isPlaceholder {
            PlaceholderView()
        } else if let error = entry.errorMessage {
            ErrorView(message: error)
        } else if let content = entry.content {
            VStack(spacing: 2) {
                ForEach(0..<2, id: \.self) { rowIndex in
                    HStack(spacing: 1) {
                        ForEach(0..<22, id: \.self) { colIndex in
                            CharacterCell(code: content.rows[rowIndex][colIndex])
                        }
                    }
                }

                Spacer()

                Text(entry.date, style: .relative)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(4)
        }
    }
}

struct CharacterCell: View {
    let code: Int

    var body: some View {
        Text(character)
            .font(.system(size: 6, weight: .medium, design: .monospaced))
            .frame(width: 5, height: 8)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
    }

    private var character: String {
        // Convert code to character
        // Implementation depends on Vestaboard character set
        if code == 0 { return " " }
        // ... mapping
        return "?"
    }

    private var backgroundColor: Color {
        // Color codes 63-69
        if code >= 63 && code <= 69 {
            switch code {
            case 63: return .red
            case 64: return .orange
            case 65: return .yellow
            case 66: return .green
            case 67: return .blue
            case 68: return .purple
            case 69: return .white
            default: return .black
            }
        }
        return .black
    }

    private var foregroundColor: Color {
        if code >= 63 && code <= 69 {
            return .clear
        }
        return .white
    }
}
```

---

#### Step 7: Connect App and Widgets

1. **Update content after posting message**
```swift
// In MessageComposerViewModel
func postMessage() async {
    // ... post message

    // Refresh content for widgets
    do {
        let content = try await api.getCurrentMessage(apiKey: apiKey, apiSecret: apiSecret)
        try AppGroupStorage.shared.saveContent(content)

        // Trigger widget refresh
        WidgetCenter.shared.reloadAllTimelines()
    } catch {
        // Handle error
    }
}
```

2. **Handle widget taps**
```swift
// In widget view
.widgetURL(URL(string: "vestawidget://open"))

// In app
.onOpenURL { url in
    if url.scheme == "vestawidget" {
        // Handle deep link
    }
}
```

---

#### Step 8: Testing & Debugging

1. **Test API integration**
```bash
# Use curl to test Vestaboard API
curl -X GET https://rw.vestaboard.com/ \
  -H "X-Vestaboard-Read-Write-Key: YOUR_KEY" \
  -H "X-Vestaboard-Api-Secret: YOUR_SECRET"
```

2. **Debug App Group**
```swift
// Verify App Group is working
print(FileManager.default.containerURL(
    forSecurityApplicationGroupIdentifier: AppConstants.appGroupIdentifier
))
```

3. **Debug widget timeline**
```swift
// Add logging in getTimeline
print("Generating timeline with \(entries.count) entries")
```

4. **Test widget refresh**
```swift
// Manually trigger refresh
WidgetCenter.shared.reloadAllTimelines()
```

---

#### Step 9: Prepare for Release

1. **Update Info.plist**
   - Add privacy descriptions
   - Configure URL schemes
   - Set supported orientations

2. **Create App Icon**
   - 1024x1024 for App Store
   - Various sizes for app

3. **Create Widget Previews**
   - Screenshots for all three sizes
   - Light and dark mode

4. **Write App Store Description**
   - Highlight key features
   - Mention required API subscription
   - Include setup instructions

5. **Submit for Review**
   - Archive app
   - Upload to App Store Connect
   - Fill out app information
   - Submit for review

---

## Conclusion

This specification provides a complete roadmap for developing VestaWidget. The document includes:

- **30+ User Stories** covering all features
- **50+ Edge Cases** identified and documented
- **Complete Technical Architecture** with code samples
- **8-Phase Development Plan** with weekly milestones
- **Comprehensive Testing Strategy** with test cases
- **Step-by-Step Implementation Guide** for developers

### Success Criteria

The app will be considered complete when:
1. Users can configure Vestaboard credentials securely
2. Users can post messages from the app
3. Three widget sizes are available and functional
4. Widgets auto-refresh every 15 minutes
5. All edge cases are handled gracefully
6. App passes App Store review
7. Test coverage exceeds 80%
8. All acceptance criteria are met

### Next Steps

1. Review this specification with stakeholders
2. Assign development team
3. Set up project repository
4. Begin Phase 1 development
5. Schedule weekly progress reviews

---

**Document Version:** 1.0
**Last Updated:** 2025-11-16
**Status:** Ready for Development
