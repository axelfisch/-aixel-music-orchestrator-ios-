# StringsOrchestrator iOS App

This is an iOS app that wraps the StringsOrchestrator web application (https://stellar-travesseiro-4619b2.netlify.app/) in a native iOS interface.

## Features

- **WebView Integration**: Full access to the StringsOrchestrator web app
- **Offline Support**: Detects network connectivity and shows offline screen when disconnected
- **Navigation Controls**: Back, forward, and refresh buttons
- **Progress Indicator**: Shows loading progress bar
- **Dark Mode Support**: Optimized for dark mode viewing
- **Gesture Navigation**: Swipe to go back/forward
- **JavaScript Enabled**: Full functionality of the web app

## Requirements

- iOS 16.0+
- Xcode 15.0+
- Swift 5.0+

## Setup Instructions

1. **Clone or download the repository**
   ```bash
   cd StringsOrchestrator
   ```

2. **Open the project in Xcode**
   ```bash
   open StringsOrchestrator.xcodeproj
   ```

3. **Configure signing**
   - Select the project in Xcode
   - Go to "Signing & Capabilities"
   - Select your development team
   - Update the bundle identifier if needed

4. **Build and run**
   - Select your target device or simulator
   - Press Cmd+R to build and run

## App Structure

```
StringsOrchestrator/
├── StringsOrchestrator/
│   ├── StringsOrchestratorApp.swift    # Main app entry point
│   ├── ContentView.swift               # Main view with WebView
│   ├── NetworkMonitor.swift            # Network connectivity monitoring
│   ├── OfflineView.swift              # Offline state view
│   ├── Assets.xcassets/               # App icons and colors
│   ├── Info.plist                     # App configuration
│   └── Preview Content/               # SwiftUI previews
└── StringsOrchestrator.xcodeproj/      # Xcode project file
```

## Customization

### Change the Website URL
Edit the `webURL` constant in `ContentView.swift`:
```swift
let webURL = "https://your-website-url.com/"
```

### Modify App Appearance
- Update accent colors in `Assets.xcassets/AccentColor.colorset`
- Change launch screen background in `Assets.xcassets/LaunchScreenBackground.colorset`
- Add app icons in `Assets.xcassets/AppIcon.appiconset`

### Add Native Features
The app is built with SwiftUI and can be extended with native iOS features:
- Push notifications
- Local storage
- Camera access
- Audio playback
- Share functionality

## Testing

The app includes:
- Network connectivity monitoring
- Error handling for failed page loads
- Navigation state management
- Progress tracking

## Deployment

1. **App Store Submission**
   - Ensure all app icons are provided
   - Update version and build numbers
   - Create App Store screenshots
   - Submit through App Store Connect

2. **TestFlight**
   - Archive the app (Product > Archive)
   - Upload to App Store Connect
   - Distribute to testers

## License

This iOS app wrapper is provided as-is for the StringsOrchestrator web application.

## Support

For issues related to the web app functionality, please refer to the original StringsOrchestrator project.
For iOS-specific issues, please check the Swift/WebKit documentation.