//
//  Copyright 2026 Google LLC
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import GoogleMobileAds
import GoogleMobileAds_Private
import UIKit

/// Swift code snippets for swipeable interstitial ad lifecycle events.
private class AdManagerSwipeableInterstitialSnippets: NSObject, SwipeableInterstitialAdDelegate {

  private let adUnitID = "/21775744923/example/swipeable-interstitial"

  // [START swipeable_interstitial_reference]
  // The swipeable interstitial ad object must be maintained as a strong reference
  // while the ad is on screen. If released early, impression tracking and click
  // handling will be lost.
  private var swipeableInterstitialAd: SwipeableInterstitialAd?
  // [END swipeable_interstitial_reference]

  func registerAdEventCallbacks() {
    // [START set_the_delegate]
    swipeableInterstitialAd?.delegate = self
    // [END set_the_delegate]
  }

  // [START register_ad_event_callbacks]
  func swipeableInterstitialAdDidRecordImpression(_ ad: SwipeableInterstitialAd) {
    print("Ad recorded an impression.")
  }

  func swipeableInterstitialAdDidRecordClick(_ ad: SwipeableInterstitialAd) {
    print("Ad recorded a click.")
  }

  func swipeableInterstitialAdWillPresentScreen(_ ad: SwipeableInterstitialAd) {
    print("Ad will present full screen view.")
  }

  func swipeableInterstitialAdWillDismissScreen(_ ad: SwipeableInterstitialAd) {
    print("Ad will dismiss full screen view.")
  }

  func swipeableInterstitialAdDidDismissScreen(_ ad: SwipeableInterstitialAd) {
    print("Ad dismissed full screen view.")
  }
  // [END register_ad_event_callbacks]

  // [START swipeable_interstitial_load]
  func loadSwipeableInterstitialAd() async {
    do {
      swipeableInterstitialAd = try await SwipeableInterstitialAd.load(
        with: adUnitID, request: AdManagerRequest(),
        options: nil)
    } catch {
      print("Failed to load swipeable interstitial ad: \(error).")
    }
  }
  // [END swipeable_interstitial_load]

  // [START swipeable_interstitial_options_screen_hold]
  func swipeableInterstitialAdOptions(
    maxScreenHoldDuration: TimeInterval
  ) -> SwipeableInterstitialAdOptions {
    let options = SwipeableInterstitialAdOptions()
    options.maxScreenHoldDuration = maxScreenHoldDuration
    return options
  }
  // [END swipeable_interstitial_options_screen_hold]

  // [START show_swipeable_interstitial]
  func showSwipeableInterstitialAd(
    _ ad: SwipeableInterstitialAd, from viewController: UIViewController
  ) {
    // Add the swipeable interstitial ad view to your swipeable container.
    ad.rootViewController = viewController
    viewController.view.addSubview(ad.adView)
  }
  // [END show_swipeable_interstitial]

  // [START check_min_screen_hold_duration]
  func holdScreen() {
    guard let ad = swipeableInterstitialAd, ad.minScreenHoldDuration > 0 else { return }

    // Disable scrolling during screen hold.
    disableScrolling()

    // Post a delayed action to unlock the interface once elapsed.
    DispatchQueue.main.asyncAfter(deadline: .now() + ad.minScreenHoldDuration) { [weak self] in
      self?.enableScrolling()
    }
  }

  func disableScrolling() {
    // TODO: Disable scrolling.
  }

  func enableScrolling() {
    // TODO: Enable scrolling.
  }
  // [END check_min_screen_hold_duration]

  // [START register_screen_hold_callback]
  func swipeableInterstitialAdDidStartScreenHoldTimer(_ ad: SwipeableInterstitialAd) {
    print("GMA SDK detected a swipeable interstitial ad screen hold.")
  }
  // [END register_screen_hold_callback]

  func setCustomClickGesture() {
    // [START set_custom_click_gesture]
    // Optional: Custom click gestures require a separate allowlisting with your
    // account manager. This feature is intended for apps that use swipe
    // gestures to click on content.
    let options = SwipeableInterstitialAdOptions()
    options.enableCustomClickSwipeGesture(direction: .right, tapsAllowed: true)
    // [END set_custom_click_gesture]
  }

  // [START swipeable_interstitial_options_ad_size]
  func swipeableInterstitialAdOptions(adSize: CGSize)
    -> SwipeableInterstitialAdOptions
  {
    let options = SwipeableInterstitialAdOptions()
    // Optional: Overrides the default fullscreen size with a custom size.
    // Custom ad sizes must fill at least 60% of the screen size.
    options.adSize = adSize
    return options
  }
  // [END swipeable_interstitial_options_ad_size]

  func discardAd() {
    // [START discard_swipeable_interstitial]
    swipeableInterstitialAd = nil
    // [END discard_swipeable_interstitial]
  }
}

extension AdManagerSwipeableInterstitialSnippets: VideoControllerDelegate {
  func registerVideoControllerDelegate() {
    // [START set_video_controller_delegate]
    swipeableInterstitialAd?.videoControllerDelegate = self
    // [END set_video_controller_delegate]
  }

  // [START video_controller_delegate]
  func videoControllerDidPlayVideo(_ videoController: VideoController) {
    // Optional: Pause any app video content when the ad video plays.
    print("Video started playing.")
  }

  func videoControllerDidEndVideoPlayback(_ videoController: VideoController) {
    // Optional: Resume app video content or handle video completion.
    print("Video ended.")
  }
  // [END video_controller_delegate]
}
