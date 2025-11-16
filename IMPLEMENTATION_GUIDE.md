# VestaWidget - Implementation Guide

## Overview
This guide provides step-by-step instructions for setting up and building the VestaWidget iOS application in Xcode.

## Project Structure

The complete implementation includes:

```
VestaWidget/
├── VestaWidget/                    # Main app target
│   ├── App/
│   │   ├── VestaWidgetApp.swift   # App entry point
│   │   └── ContentView.swift      # Main navigation
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
│   │   ├── NetworkMonitor.swift
│   ├── Models/
│   │   ├── VestaboardConfiguration.swift
│   │   ├── VestaboardMessage.swift
│   │   └── MessageTemplate.swift
│   └── Utilities/
│       ├── Constants.swift
│       └── VestaboardCharacterSet.swift
│
├── VestaWidgets/                   # Widget extension target
│   ├── VestaWidgetBundle.swift    # Widget bundle entry point
│   ├── SmallWidget.swift          # Small widget (2 rows)
│   ├── MediumWidget.swift         # Medium widget (4 rows)
│   ├── LargeWidget.swift          # Large widget (6 rows)
│   ├── WidgetTimelineProvider.swift
│   └── Views/
│       ├── VestaboardDisplayView.swift
│       ├── PlaceholderView.swift
│       └── ErrorView.swift
│
└── Shared/                         # Shared between app and widgets
    ├── Models/
    │   ├── VestaboardContent.swift
    │   └── VestaWidgetEntry.swift
    ├── Services/
    │   └── AppGroupStorage.swift
    └── Extensions/
        └── Extensions.swift
```

## Xcode Project Setup

### Step 1: Create Xcode Project

1. Open Xcode
2. File → New → Project
3. Select "iOS" → "App" template
4. Configure:
   - Product Name: `VestaWidget`
   - Team: Your development team
   - Organization Identifier: `com.yourcompany` (change as needed)
   - Interface: SwiftUI
   - Language: Swift
   - Minimum Deployment: iOS 14.0

### Step 2: Add Widget Extension Target

1. File → New → Target
2. Select "Widget Extension"
3. Configure:
   - Product Name: `VestaWidgets`
   - Include Configuration Intent: No (optional feature)
4. Activate the scheme when prompted

### Step 3: Configure App Groups

App Groups enable data sharing between the app and widget extension.

**For VestaWidget target:**
1. Select VestaWidget target
2. Signing & Capabilities tab
3. Click "+ Capability"
4. Add "App Groups"
5. Click "+" under App Groups
6. Add: `group.com.vestawidget.shared` (or use your organization identifier)

**For VestaWidgets target:**
1. Select VestaWidgets target
2. Repeat steps 2-6 above with the SAME App Group identifier

### Step 4: Configure Keychain Sharing

Keychain Sharing allows the widget to access credentials stored by the app.

**For VestaWidget target:**
1. Select VestaWidget target
2. Signing & Capabilities tab
3. Click "+ Capability"
4. Add "Keychain Sharing"
5. Add keychain group: `com.vestawidget.shared`

**For VestaWidgets target:**
1. Repeat for VestaWidgets target

### Step 5: Update Constants

Edit `/home/user/vestawidget/VestaWidget/Utilities/Constants.swift`:

```swift
// Update these to match your App Group and Keychain identifiers
static let appGroupIdentifier = "group.com.yourcompany.vestawidget"
static let keychainIdentifier = "com.yourcompany.vestawidget"
static let keychainAccessGroup = "com.yourcompany.vestawidget.shared"
```

### Step 6: Add Files to Targets

In Xcode, ensure files are added to the correct targets:

**VestaWidget target only:**
- VestaWidget/App/*
- VestaWidget/Features/**/*
- VestaWidget/Services/VestaboardAPI.swift
- VestaWidget/Services/KeychainService.swift
- VestaWidget/Services/NetworkMonitor.swift
- VestaWidget/Models/*
- VestaWidget/Utilities/*

**VestaWidgets target only:**
- VestaWidgets/*.swift
- VestaWidgets/Views/*

**BOTH targets (Shared):**
- Shared/Models/*
- Shared/Services/*
- Shared/Extensions/*

To add file to multiple targets:
1. Select file in Project Navigator
2. File Inspector (right panel)
3. Check appropriate boxes under "Target Membership"

### Step 7: Configure Info.plist

**VestaWidget Info.plist:**

Add these keys:
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
</dict>
<key>UIApplicationSceneManifest</key>
<dict>
    <key>UIApplicationSupportsMultipleScenes</key>
    <true/>
</dict>
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>vestawidget</string>
        </array>
    </dict>
</array>
```

### Step 8: Build and Run

1. Select "VestaWidget" scheme
2. Choose a simulator or device (iOS 14.0+)
3. Product → Build (⌘B)
4. Fix any errors (usually related to missing imports or target membership)
5. Product → Run (⌘R)

### Step 9: Test Widget Extension

1. Run the app on simulator/device
2. Configure API credentials
3. Long-press on home screen
4. Tap "+" in top corner
5. Search for "VestaWidget"
6. Add a widget to home screen
7. Widget should display content after 15 minutes (or immediately if you rebuild)

## Common Issues and Solutions

### Issue: "No such module 'WidgetKit'"
**Solution:** Ensure WidgetKit is imported only in Widget extension files, not in main app files.

### Issue: "Cannot find type 'VestaboardContent' in scope"
**Solution:** Ensure Shared files are added to BOTH targets (VestaWidget AND VestaWidgets).

### Issue: Widget shows "Unable to Load"
**Solution:**
1. Check that App Group identifiers match in both targets
2. Verify Keychain Access Group is configured
3. Ensure credentials are saved in the app first
4. Check that widget has network permissions

### Issue: "App Group identifier not found"
**Solution:** Ensure App Group capability is properly configured in BOTH targets with identical identifier.

### Issue: Build fails with "Duplicate symbol" errors
**Solution:** A file is accidentally added to both targets when it should only be in one. Check Target Membership.

## Required Frameworks

The app automatically links these frameworks:

**Main App:**
- SwiftUI
- Foundation
- Security (Keychain)
- Network (NetworkMonitor)
- Combine

**Widget Extension:**
- SwiftUI
- WidgetKit
- Foundation
- Security

## Testing

### Test Configuration Flow
1. Launch app
2. Should show onboarding screen
3. Tap "Get Started"
4. Enter API credentials
5. Tap "Test Connection"
6. Should show success or error
7. Tap "Save Configuration"
8. Should navigate to main app

### Test Message Posting
1. Go to "Post Message" tab
2. Enter text
3. Check character counter updates
4. Check for unsupported characters
5. Tap "Send to Vestaboard"
6. Should show success message
7. Check message history

### Test Widgets
1. Add widget to home screen
2. Widget should show placeholder initially
3. After configuring app, widget should update
4. Wait 15 minutes or rebuild to see content
5. Tap widget - should open app

## Production Checklist

Before App Store submission:

- [ ] Update Bundle Identifier (com.yourcompany.vestawidget)
- [ ] Update App Group Identifier
- [ ] Update Keychain Identifiers
- [ ] Configure signing certificates
- [ ] Add app icon (all required sizes)
- [ ] Test on multiple device sizes
- [ ] Test on iOS 14, 15, 16, 17
- [ ] Add privacy policy
- [ ] Complete App Store metadata
- [ ] Create screenshots for all sizes
- [ ] Test widget refresh behavior
- [ ] Verify error handling
- [ ] Check accessibility with VoiceOver
- [ ] Test in dark mode
- [ ] Verify network error handling

## Architecture Decisions

### MVVM Pattern
- **Models:** Data structures (VestaboardMessage, Configuration)
- **Views:** SwiftUI views (all *View.swift files)
- **ViewModels:** Business logic (*ViewModel.swift files)
- **Services:** Reusable utilities (API, Storage, Keychain)

### Data Flow
1. User enters credentials → ConfigurationViewModel
2. ViewModel validates → VestaboardAPI tests connection
3. Success → KeychainService stores securely
4. Widget requests data → TimelineProvider
5. Provider fetches from API → Saves to AppGroupStorage
6. Other widgets read from AppGroupStorage
7. App refreshes → Triggers widget reload via WidgetCenter

### Security
- Credentials stored in Keychain (never in UserDefaults)
- App Group keychain for widget access
- No credentials logged
- Secure coding practices throughout

## Support and Documentation

- **Vestaboard API Docs:** https://docs.vestaboard.com
- **Character Codes:** https://docs.vestaboard.com/character-codes
- **WidgetKit Guide:** https://developer.apple.com/documentation/widgetkit
- **App Groups:** https://developer.apple.com/documentation/xcode/configuring-app-groups

## Next Steps

1. Customize app branding and colors
2. Add app icon and launch screen
3. Implement additional features from spec:
   - Message templates
   - Advanced character validation
   - Offline queue
   - Widget configuration intents
4. Add analytics (optional)
5. Add crash reporting (optional)
6. Beta test via TestFlight
7. Submit to App Store

## Contact

For issues or questions about this implementation, refer to:
- DEVELOPMENT_SPECIFICATION.md - Complete feature specifications
- Code comments - Detailed implementation notes

---

**Version:** 1.0
**Last Updated:** 2025-11-16
**Status:** Complete Implementation
