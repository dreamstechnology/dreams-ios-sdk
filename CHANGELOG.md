# Changelog

All notable changes to this library will be documented here.

## 2.0.0 — unreleased

### Breaking

* **Minimum deployment target raised from iOS 10.3 to iOS 15.0.** Apps still
  targeting iOS 14 or earlier cannot integrate this version.

### Features

* Added `PrivacyInfo.xcprivacy` privacy manifest, required for App Store
  submission. Declares no tracking, no collected data, no Required Reason API
  usage. Wired into Swift Package Manager, CocoaPods, and the framework target.
* Added explicit `platforms: [.iOS(.v15)]` to `Package.swift`, which previously
  had no platform floor.

### Changed

* Verified against Xcode 26 and iOS 26 — no deprecated WebKit API usage.
* Swift 6 compiler compatibility for `evaluateJavaScript` in `WebViewProtocol`.
* Extracted `handleNavigationHTTPResponse(_:)` from `WebService`'s
  navigation-response delegate so HTTP status handling is unit-testable on
  iOS 26. Delegate behaviour unchanged.
* Framework now reports its real version via `MARKETING_VERSION`; previously
  hardcoded to `1.0`, so crash reports and binary metadata showed the wrong
  SDK version.
* Fastlane test lane targets a current simulator instead of iPhone 8.
* Fixed the `DreamsTests` scheme, which had an empty `BuildAction`. Building it
  from the command line failed; only `xcodebuild test` worked.

### Removed

* Deleted `Tests/Mocks/FakeResponseMock.swift`. It subclassed
  `WKNavigationResponse` to fake HTTP responses in tests. On iOS 26 that
  subclassing terminates the test runner, so the affected tests were rewritten
  to call `handleNavigationHTTPResponse(_:)` directly and the mock was left
  unused. `WKNavigationResponse` has no public initializer and was never
  intended to be subclassed, so this is likely deliberate hardening by Apple
  rather than a regression — the approach should be considered unavailable
  going forward, not temporarily broken.

### Notes

* Cookie persistence audited and confirmed working with no SDK changes needed.
* CocoaPods Trunk becomes read-only on 2 December 2026. Swift Package Manager
  is the recommended integration method going forward — see the README.

## 1.3.0 and earlier

See the [release tags](https://github.com/doconomy/dreams-ios-sdk/tags).
