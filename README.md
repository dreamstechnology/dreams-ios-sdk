# Dreams iOS SDK
![Dreams](https://raw.githubusercontent.com/dreamstechnology/dreams-ios-sdk/main/Dreams.jpg)

[![Build Status](https://app.bitrise.io/app/a85e7d5e048cafc5/status.svg?token=ZnRPb1JZjxkq8YEt07RJCQ&branch=main)](https://app.bitrise.io/app/a85e7d5e048cafc5)
[![Version](https://img.shields.io/cocoapods/v/Dreams.svg?style=flat)](https://cocoapods.org/pods/Dreams)
[![License](https://img.shields.io/cocoapods/l/Dreams.svg?style=flat)](https://cocoapods.org/pods/Dreams)
[![Platform](https://img.shields.io/cocoapods/p/Dreams.svg?style=flat)](https://cocoapods.org/pods/Dreams)
![Swift5](https://img.shields.io/badge/%20in-swift%205.0-orange.svg)

## Requirements
- iOS 15.0+
- Swift 5.0+

## Breaking changes in 2.0.0

- **Minimum deployment target raised from iOS 10.3 to iOS 15.0.** Apps still
  targeting iOS 14 or earlier cannot integrate this version.

## Installation

> ### ⚠️ CocoaPods is going read-only — migrate to Swift Package Manager
>
> The CocoaPods project has been in maintenance mode since August 2024, and the
> public Trunk specs repository becomes **permanently read-only on 2 December 2026**.
> A test run of read-only mode is scheduled for 1–7 November 2026.
>
> **What this means for you:**
> - Existing published versions stay installable indefinitely — your current builds will not break.
> - No *new* versions of any pod can be published to Trunk after that date.
> - Future releases of this SDK will be distributed via Swift Package Manager.
>
> **Swift Package Manager is the recommended integration method.** If you are
> currently integrating via CocoaPods, please plan your migration before
> December 2026. See the [CocoaPods Trunk read-only plan](https://blog.cocoapods.org/CocoaPods-Specs-Repo/)
> for background.

### Swift Package Manager (recommended)

In Xcode, choose **File → Add Package Dependencies…** and enter the repository URL:

```
https://github.com/dreamstechnology/dreams-ios-sdk.git
```

Select the `Dreams` library product and link it to all relevant targets.

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/dreamstechnology/dreams-ios-sdk.git", from: "2.0.0")
]
```

### CocoaPods

Add the pod to your `Podfile`:

```ruby
pod 'DreamsEnterpriseSDK', '~> 2.0'
```

Then run:

```bash
$ pod install
```

### Manually

If you prefer not to use Cocoapods, you can simply integrate Dreams into your project by dragging in the files from the `Sources` folder.


## Usage

1. Import `Dreams` in your `AppDelegate`:

```swift
import Dreams
```

2. Add the following to your `application:didFinishLaunchingWithOptions:` in your `AppDelegate`:


```swift
let configuration = DreamsConfiguration(clientId: "your_client_id", baseURL: URL(string: "your_base_url")!)
Dreams.configure(configuration)
```

3. Create an instance of a `DreamsViewController`. This is just one example you can use it however you like including from Storyboards and xib's:

```swift
 let viewController = DreamsViewController()
```

4. Set the delegate and implement the `DreamsDelegate` methods:

```swift
viewController.use(delegate: self)
```

5. Prepare user's credentials:

```swift
let userCredentials = DreamsCredentials(idToken: "idToken")
```

6. Present ViewController (as fullscreen modal) and then launch Dreams:

```swift
viewController.modalPresentationStyle = .fullScreen
present(viewController, animated: true) {
    viewController.launch(with: userCredentials, locale: Locale.current) { result in
        switch result {
        case .success:
            () // Dreams did launch successfully
        case .failure(let launchError):
            switch launchError {
            case .alreadyLaunched:
                () // You cannot launch Dreams when launching is in progess
            case .invalidCredentials:
                () // The provided credentials were invalid
            case .httpErrorStatus(let httpStatus):
                print(httpStatus) // The server returned a HTTP error status
            case .requestFailure(let error):
                print(error) // Other server errors (NSError instance)
            }
        }
    }
}

```

## Location

### Launching with specific location within Dreams

```swift
viewController.launch(with: userCredentials, locale: Locale.current, location: "/some/location") { result in }
```

### Navigating to location within Dreams after launch

```swift
viewController.navigateTo(location: "/some/location")
```

### Safe Area

Dreams interface is leveraging the Safe Area Layout Guides information to adjust the interface to different screens. Do not disable `Use Safe Area Layout Guides` in Interface Builder.

Do not modify `layoutMargins` or `directionalLayoutMargins` in parent view controller when `DreamsViewController` is presented as a child view controller.

### DreamsDelegate

This method is called when credentials passed whith `launch(with:locale:)` expired and new ones must be generated.

```swift
func handleDreamsCredentialsExpired(completion: @escaping (String) -> Void) {
    // Call `completion` when account provision is initiated.
    completion(DreamsCredentials(idToken: "newtoken"))
}
```

This method is called when a tracked event happened.

```swift
func handleDreamsTelemetryEvent(name: String, payload: [String : Any]) {
    print("Telemetry event received: \(name) with payload: \(payload)")
}
```

This method is called when the host app is expected to initiate account provision.

```swift
func handleDreamsAccountProvisionInitiated(completion: @escaping () -> Void) {
    // Call `completion` when account provision is initiated.
    // You can store the `completion` in a property to call it later.
    completion()
}
```

This method is called when the host app is expected to request an account.

```swift

func handleDreamsAccountRequested(requestId: String, dream: [String: Any], completion: @escaping (Result<AccountRequestedSuccess, AccountRequestedError>) -> Void) {
    // Call `completion` when account has been requested, the user cancels or an error occurs.
    // You can store the `completion` in a property to call it later.
    completion(failure(AccountRequestedError(requestId: requestId, reason: "error")))
    completion(failure(AccountRequestedError(requestId: requestId, reason: "cancelled")))

    completion(.success(AccountRequestedSuccess(requestId: requestId)))
}
```

This method is called when user finished interaction with Dreams and the interface should be dismissed.

```swift
func handleExitRequest() {
    // For example:
    presentedViewController?.dismiss(animated: true, completion: nil)
}
```

## Unit Tests

You can run tests using [fastlane](./fastlane/README.md).

```bash
fastlane ios unit_test
```

To run unit tests manually use this command:

```bash
xcodebuild test -workspace "./Dreams.xcworkspace" -scheme "DreamsTests" -destination "platform=iOS Simulator,name=iPhone 17"
```

## Changelog

See [CHANGELOG.md](./CHANGELOG.md).
