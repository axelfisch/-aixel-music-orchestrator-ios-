# StellarWebApp (iOS)

A minimal SwiftUI iOS app that wraps your website in a WKWebView with a progress bar and basic navigation controls.

## Website URL

Currently points to:

- https://stellar-travesseiro-4619b2.netlify.app/

Update the `startURL` in `Sources/ContentView.swift` to change.

## Requirements

- Xcode 15+
- iOS 15+ target
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) installed (optional but recommended)

## Generate and open the project

```bash
brew install xcodegen # if missing
cd ios
xcodegen generate
open StellarWebApp.xcodeproj
```

If you prefer, you can create an Xcode project manually and add the `Sources`, `Resources`, and `Support` folders.

## Configure signing

- In Xcode, select the `StellarWebApp` target
- Set your `Team` and replace the bundle id `com.example.StellarWebApp`

## App Transport Security (ATS)

The app only loads HTTPS by default. If your site uses non-HTTPS or loads mixed content, add the appropriate ATS exceptions in `Support/Info.plist`.

## Customization tips

- Change app name in scheme/target settings and `CFBundleName`
- Replace icons in `Resources/Assets.xcassets/AppIcon.appiconset`
- Adjust navigation bar title in `ContentView`

## Store submission checklist

- Ensure website is mobile-friendly and avoids external payment flows that violate App Store Review Guidelines
- Provide app privacy info; WKWebView does not collect data by itself
- Supply app screenshots and an App Icon (1024x1024)
