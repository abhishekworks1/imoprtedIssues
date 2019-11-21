# SocialCAM-iOS app

[![Swift 5.0](https://img.shields.io/badge/Swift-5.0-orange.svg?style=flat)](https://swift.org)

[![Build Status](https://build.appcenter.ms/v0.1/apps/a48cf303-7fce-456c-a2b7-8940c0c574bf/branches/develop/badge)](https://build.appcenter.ms/v0.1/apps/a48cf303-7fce-456c-a2b7-8940c0c574bf/branches/develop/badge)

SocialCAM

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites
- iOS 11.0+
- Xcode 10.1
- [CocoaPods](http://cocoapods.org/)

### Dependencies

Third party frameworks and libraries are managed using [Cocoapods](http://cocoapods.org/).

#### Pods used 

- [AlamofireObjectMapper](https://github.com/tristanhimmelman/AlamofireObjectMapper): An Alamofire extension which converts JSON response data into swift objects using ObjectMapper
- [R.swift](https://github.com/mac-cain13/R.swift): Get strong typed, autocompleted resources like images, fonts and segues in Swift projects

### Swift Style Guide
Code follows [Raywenderlich](https://github.com/raywenderlich/swift-style-guide) style guide.

### How to setup project?

1. Clone this repository into a location of your choosing, like your projects folder

2. Open terminal - > Navigate to directory containing ``Podfile``

3. Then install pods into your project by typing in terminal: ```pod install```

4. Once completed, there will be a message that says
`"Pod installation complete! There are X dependencies from the Podfile and X total pods installed."`

5. Voila! You are all set now. Open the .xcworkspace file from now on and hit Xcode's 'run' button.  🚀

### How to use?

There are 2 schemes available to run the project in staging or in live environment

1. Staging - Set the active scheme as `"SocialCAM Staging"` to run the project in Staging environment
2. Production - Set the active scheme as `"SocialCAM"` to run the project in Production environment

### Architecture

The project uses the default Apple architecture (MVC) along with [Protocol-Oriented approach in Swift](https://developer.apple.com/videos/play/wwdc2015/408/).

“Event” Patterns such as Delegation, Callback blocks, Notification Center, Key-Value Observing (KVO) and Signals have been used extensively for components to notify others about things.

### Beta Testing

We are using [TestFlight](https://developer.apple.com/testflight/) to download the app for beta testing.

To test beta versions of apps using TestFlight, you’ll need to receive an invitation email from the developer or get access to a public invitation link, and have a device that you can use to test.

**Internal testers** Members of the developer’s team in App Store Connect can participate as internal testers and will have access to all builds of the app.

**External testers** Anyone can participate as an external tester and will have access to builds that the developer makes available to them. A developer can invite you to test with an invitation email or a public invitation link. An Apple ID is not required. If you are part of the developer’s team in App Store Connect, you can be added as an external tester if you aren’t already an internal tester.

### Copyright

Copyright © 2014-2019 SocialCAM, Inc. All worldwide rights reserved.
