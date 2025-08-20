//
//  Copyright (C) 2025 Google, Inc.
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

private class NativeAdOptionsSnippets: UIViewController, NativeAdDelegate {

  // Replace this ad unit ID with your own ad unit ID.
  private let nativeAdUnitID = "ca-app-pub-3940256099942544/3986624511"
  // The ad loader.
  private var adLoader: AdLoader!

  private func setMediaAspectRatio() {
    // [START set_media_aspect_ratio]
    let nativeOptions = NativeAdMediaAdLoaderOptions()
    nativeOptions.mediaAspectRatio = .any

    adLoader = AdLoader(
      adUnitID: nativeAdUnitID,
      rootViewController: self,
      adTypes: [.native],
      options: [nativeOptions])
    // [END set_media_aspect_ratio]
  }

  private func setDisableImageLoading() {
    // [START set_disable_image_loading]
    let nativeOptions = NativeAdImageAdLoaderOptions()
    nativeOptions.isImageLoadingDisabled = true

    adLoader = AdLoader(
      adUnitID: nativeAdUnitID,
      rootViewController: self,
      adTypes: [.native],
      options: [nativeOptions])
    // [END set_disable_image_loading]
  }

  private func setRequestMultipleImages() {
    // [START set_request_multiple_images]
    let nativeOptions = NativeAdImageAdLoaderOptions()
    nativeOptions.shouldRequestMultipleImages = true

    adLoader = AdLoader(
      adUnitID: nativeAdUnitID,
      rootViewController: self,
      adTypes: [.native],
      options: [nativeOptions])
    // [END set_request_multiple_images]
  }

  private func setAdChoicesPosition() {
    // [START set_ad_choices_position]
    let nativeOptions = NativeAdViewAdOptions()
    nativeOptions.preferredAdChoicesPosition = .topRightCorner

    adLoader = AdLoader(
      adUnitID: nativeAdUnitID,
      rootViewController: self,
      adTypes: [.native],
      options: [nativeOptions])
    // [END set_ad_choices_position]
  }

  // [START create_ad_choices_view]
  private func createAdChoicesView(nativeAdView: NativeAdView) {
    // Define a custom position for the AdChoices icon.
    let customRect = CGRect(x: 100, y: 100, width: 15, height: 15)
    let customAdChoicesView = AdChoicesView(frame: customRect)
    nativeAdView.addSubview(customAdChoicesView)
    nativeAdView.adChoicesView = customAdChoicesView
  }
  // [END create_ad_choices_view]

  private func setMuted() {
    // [START set_muted]
    let videoOptions = VideoOptions()
    videoOptions.shouldStartMuted = false

    adLoader = AdLoader(
      adUnitID: nativeAdUnitID,
      rootViewController: self,
      adTypes: [.native],
      options: [videoOptions])
    // [END set_muted]
  }

  private func setRequestCustomPlaybackControls() {
    // [START set_request_custom_playback_controls]
    let videoOptions = VideoOptions()
    videoOptions.areCustomControlsRequested = true

    adLoader = AdLoader(
      adUnitID: nativeAdUnitID,
      rootViewController: self,
      adTypes: [.native],
      options: [videoOptions])
    // [END set_request_custom_playback_controls]
  }

  // [START check_custom_controls_enabled]
  private func checkCustomControlsEnabled(nativeAd: NativeAd) -> Bool {
    let videoController = nativeAd.mediaContent.videoController
    return videoController.areCustomControlsEnabled
  }
  // [END check_custom_controls_enabled]

  private func setCustomSwipeGesture() {
    // [START set_custom_swipe_gesture]
    let swipeGestureOptions = NativeAdCustomClickGestureOptions(
      swipeGestureDirection: .right,
      tapsAllowed: true)

    adLoader = AdLoader(
      adUnitID: nativeAdUnitID,
      rootViewController: self,
      adTypes: [.native],
      options: [swipeGestureOptions])
    // [END set_custom_swipe_gesture]
  }

  // [START custom_swipe_gesture_delegate]
  // Called when a swipe gesture click is recorded, as configured in
  // NativeAdCustomClickGestureOptions.
  func nativeAdDidRecordSwipeGestureClick(_ nativeAd: NativeAd) {
    print("A swipe gesture click has occurred.")
  }

  // Called when a swipe gesture click or a tap click is recorded.
  func nativeAdDidRecordClick(_ nativeAd: NativeAd) {
    print("A swipe gesture click or tap click has occurred.")
  }
  // [END custom_swipe_gesture_delegate]
}
