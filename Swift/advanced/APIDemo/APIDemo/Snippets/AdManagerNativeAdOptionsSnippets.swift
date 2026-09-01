//
//  Copyright (C) 2026 Google, Inc.
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

private class AdManagerNativeAdOptionsSnippets: UIViewController, NativeAdDelegate {

  // Replace this ad unit ID with your own ad unit ID.
  private let nativeAdUnitID = "/21775744923/example/native"
  private var adLoader: AdLoader?

  private func setCustomSwipeGesture() {
    // [START set_custom_swipe_gesture]
    var options: [GADAdLoaderOptions]? = nil
    adLoader = AdLoader(
      adUnitID: nativeAdUnitID,
      rootViewController: self,
      adTypes: [.native],
      options: options)
    // [END set_custom_swipe_gesture]
  }

  // [START custom_swipe_gesture_delegate]
  /// Notifies the delegate that a swipe gesture click was recorded, as configured in
  /// NativeAdCustomClickGestureOptions.
  func nativeAdDidRecordSwipeGestureClick(_ nativeAd: NativeAd) {
    print("A swipe gesture click has occurred.")
  }

  /// Notifies the delegate that a swipe gesture click or a tap click was recorded.
  func nativeAdDidRecordClick(_ nativeAd: NativeAd) {
    print("A swipe gesture click or tap click has occurred.")
  }
  // [END custom_swipe_gesture_delegate]
}
