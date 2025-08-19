# Google Mobile Ads SDK for iOS

[![Build Status](https://github.com/googleads/googleads-mobile-ios-examples/actions/workflows/build.yml/badge.svg)](https://github.com/googleads/googleads-mobile-ios-examples/actions/workflows/build.yml)

The Google Mobile Ads SDK is the latest generation in Google mobile advertising,
featuring refined ad formats and streamlined APIs for access to mobile ad
networks and advertising solutions. The SDK enables mobile app developers to
maximize their monetization in native mobile apps.

This repository contains open source examples and developer resources for both
the Google AdMob and Google AdManager components of the Google Mobile Ads
SDK.

# Google Mobile Ads SDK Developers forum

To report SDK feature requests, bugs, and crashes or to browse SDK-related
discusssions, please use our [Google Mobile Ads SDK Developers forum](https://groups.google.com/forum/#!forum/google-admob-ads-sdk).
The forum provides the latest SDK announcements and updates as well as
technical SDK support for our [iOS developers](https://groups.google.com/forum/#!categories/google-admob-ads-sdk/ios).

# Documentation

Check out our [developers site](https://developers.google.com/mobile-ads-sdk/)
for documentation on using the Mobile Ads SDK.

# Examples

Each iOS example app includes a Podfile and a Podfile.lock. The Podfile.lock
tracks the version of each Pod specified in the Podfile that was used to build
the release of the iOS example apps.

1. Run `pod install` in the same directory as the Podfile.
1. [Optional] Run `pod update` to get the latest version of the SDK.
1. Open the .xcworkspace file with Xcode and run the app.

See the [CocoaPods Guides](https://guides.cocoapods.org/)
for more information on installing and updating pods.

## Swift

### AdMob

*   [App Open Example](https://github.com/googleads/googleads-mobile-ios-examples/tree/main/Swift/admob/AppOpenExample)
*   [Banner Example](https://github.com/googleads/googleads-mobile-ios-examples/tree/main/Swift/admob/BannerExample)
*   [Interstitial Example](https://github.com/googleads/googleads-mobile-ios-examples/tree/main/Swift/admob/InterstitialExample)
*   [Native Advanced Example](https://github.com/googleads/googleads-mobile-ios-examples/tree/main/Swift/admob/NativeAdvancedExample)
*   [Rewarded Interstitial Example](https://github.com/googleads/googleads-mobile-ios-examples/tree/main/Swift/admob/RewardedInterstitialExample)
*   [Rewarded Video Example](https://github.com/googleads/googleads-mobile-ios-examples/tree/main/Swift/admob/RewardedVideoExample)

### Advanced

*   [API Demo](https://github.com/googleads/googleads-mobile-ios-examples/tree/main/Swift/advanced/APIDemo) -
    Provides additional examples for both AdMob and Ad Manager to help improve
    your mobile app integration of the Google Mobile Ads SDK.
*   [Inline Adaptive Banner Example](https://github.com/googleads/googleads-mobile-ios-examples/tree/main/Swift/advanced/InlineAdaptiveBannerExample) -
    Provides an example for displaying ads from AdMob Banners in a UITableView.
*   [SwiftUI Demo](https://github.com/googleads/googleads-mobile-ios-examples/tree/main/Swift/advanced/SwiftUIDemo) -
    Provides an examples for displaying ads from AdMob in a SwiftUI project.

### AdManager

*   [AdManager App Open Example](https://github.com/googleads/googleads-mobile-ios-examples/tree/main/Swift/admanager/AdManagerAppOpenExample)
*   [AdManager Banner Example](https://github.com/googleads/googleads-mobile-ios-examples/tree/main/Swift/admanager/AdManagerBannerExample)
*   [AdManager Interstitial Example](https://github.com/googleads/googleads-mobile-ios-examples/tree/main/Swift/admanager/AdManagerInterstitialExample)
*   [AdManager Rewarded Video Example](https://github.com/googleads/googleads-mobile-ios-examples/tree/main/Swift/admanager/AdManagerRewardedVideoExample)
*   [AdManager Custom Rendering Example](https://github.com/googleads/googleads-mobile-ios-examples/tree/main/Swift/admanager/AdManagerCustomRenderingExample)

## Objective-C

### AdMob

*   [App Open Example](https://github.com/googleads/googleads-mobile-ios-examples/tree/main/Objective-C/admob/AppOpenExample)
*   [Banner Example](https://github.com/googleads/googleads-mobile-ios-examples/tree/main/Objective-C/admob/BannerExample)
*   [Full Screen Native Example](https://github.com/googleads/googleads-mobile-ios-examples/tree/main/Objective-C/admob/FullScreenNativeExample)
*   [Interstitial Example](https://github.com/googleads/googleads-mobile-ios-examples/tree/main/Objective-C/admob/InterstitialExample)
*   [Native Advanced Example](https://github.com/googleads/googleads-mobile-ios-examples/tree/main/Objective-C/admob/NativeAdvancedExample)
*   [Rewarded Interstitial Example](https://github.com/googleads/googleads-mobile-ios-examples/tree/main/Objective-C/admob/RewardedInterstitialExample)
*   [Rewarded Video Example](https://github.com/googleads/googleads-mobile-ios-examples/tree/main/Objective-C/admob/RewardedVideoExample)

### Advanced

*   [API Demo](https://github.com/googleads/googleads-mobile-ios-examples/tree/main/Objective-C/advanced/APIDemo)
    -   Provides additional examples for both AdMob and Ad Manager to help
        improve your mobile app integration of the Google Mobile Ads SDK.
*   [Inline Adaptive Banner Example](https://github.com/googleads/googleads-mobile-ios-examples/tree/main/Objective-C/advanced/InlineAdaptiveBannerExample)
    -   Provides an example for displaying ads from AdMob Banners in a
        UITableView.

### AdManager

*   [AdManager App Open Example](https://github.com/googleads/googleads-mobile-ios-examples/tree/main/Objective-C/admanager/AdManagerAppOpenExample)
*   [AdManager Banner Example](https://github.com/googleads/googleads-mobile-ios-examples/tree/main/Objective-C/admanager/AdManagerBannerExample)
*   [AdManager Interstitial Example](https://github.com/googleads/googleads-mobile-ios-examples/tree/main/Objective-C/admanager/AdManagerInterstitialExample)
*   [AdManager Rewarded Video Example](https://github.com/googleads/googleads-mobile-ios-examples/tree/main/Objective-C/admanager/AdManagerRewardedVideoExample)
*   [AdManager Custom Rendering Example](https://github.com/googleads/googleads-mobile-ios-examples/tree/main/Objective-C/admanager/AdManagerCustomRenderingExample)

## Documentation Snippets

This repository also contains code snippets used in developer documentation for
[AdMob](https://developers.google.com/admob/ios) and
[Ad Manager](https://developers.google.com/ad-manager/mobile-ads-sdk/ios).
These snippets live in the API Demo projects for Swift and Objective-C in a
`Snippets` folder.

The idea is that by including the code snippets from documentation in a sample
project, developers will gain more context on how to implement a specific API.

In addition, by having CI running on this repo, we can ensure that the code
snippets the documentation are in a working condition.

# Downloads

Please check out our [releases](https://github.com/googleads/googleads-mobile-ios-examples/releases)
for the latest downloads of our example apps.

# GitHub issue tracker

To file bugs, make feature requests, or suggest improvements for the
**iOS example apps**, please use [GitHub's issue tracker](https://github.com/googleads/googleads-mobile-ios-examples/issues).

For SDK support issues, please use the [Google Mobile Ads SDK Developers forum](https://groups.google.com/forum/#!forum/google-admob-ads-sdk).

# License

[Apache 2.0 License](http://www.apache.org/licenses/LICENSE-2.0.html)
