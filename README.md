# Google Ads Mobile iOS Examples

This repository contains example projects demonstrating how to integrate Google Ads into iOS applications using Objective-C. Each example showcases a specific ad format or integration technique.

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Examples](#examples)
4. [How to Run](#how-to-run)
5. [Additional Resources](#additional-resources)
6. [License](#license)

## Overview

The examples provided in this repository demonstrate various Google Ad Manager ad implementations for iOS applications, including:
- App Open Ads
- Banner Ads
- Interstitial Ads

These projects aim to simplify the process of integrating Google Ads into your iOS applications and provide a starting point for further customization.

## Prerequisites

- **CocoaPods installed**: All examples use CocoaPods to manage dependencies. [Get started with CocoaPods](https://guides.cocoapods.org/using/getting-started.html#toc_3).
- **Google Mobile Ads SDK**: Examples are compatible with the latest version of the iOS Google Mobile Ads SDK, which will be installed automatically via CocoaPods.
- **Ad Unit IDs**: Replace the sample Ad Unit IDs in the examples with your own. Create Ad Unit IDs in your [Google Ad Manager account](https://admanager.google.com).

## Examples

### 1. App Open Ads
Path: `Objective-C/admanager/AdManagerAppOpenExample`

This example demonstrates how to integrate an App Open Ad in an iOS application. [View README](https://github.com/Dimvy-Clothing-brand/googleads-mobile-ios-examples/blob/main/Objective-C/admanager/AdManagerAppOpenExample/README.md)

### 2. Banner Ads
Path: `Objective-C/admanager/AdManagerBannerExample`

This example demonstrates how to integrate a Banner Ad in an iOS application. [View README](https://github.com/Dimvy-Clothing-brand/googleads-mobile-ios-examples/blob/main/Objective-C/admanager/AdManagerBannerExample/README.md)

### 3. Interstitial Ads
Path: `Objective-C/admanager/AdManagerInterstitialExample`

This example demonstrates how to integrate an Interstitial Ad in an iOS application. [View README](https://github.com/Dimvy-Clothing-brand/googleads-mobile-ios-examples/blob/main/Objective-C/admanager/AdManagerInterstitialExample/README.md)

## How to Run

1. Clone the repository:
   ```bash
   git clone https://github.com/Dimvy-Clothing-brand/googleads-mobile-ios-examples.git
   cd googleads-mobile-ios-examples
   ```

2. Navigate to the desired example directory.

3. Install dependencies via CocoaPods:
   ```bash
   pod update
   ```

4. Open the generated `.xcworkspace` file in Xcode.

5. Run the project on a simulator or physical device.

## Additional Resources

- [Google Ad Manager Developer Documentation](https://developers.google.com/ad-manager/mobile-ads-sdk)
- [Google AdMob Ads SDK Forum](https://groups.google.com/group/google-admob-ads-sdk)

## License

This project is licensed under the terms of the [Apache License 2.0](LICENSE).
