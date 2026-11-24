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

import Foundation
import GoogleMobileAds
import GoogleMobileAds_Private

/// Singleton that loads, manages lifecycle, and handles events for Picture-in-Picture (PiP) ads.
@MainActor
final class PictureInPictureAdManager: NSObject {
  static let shared = PictureInPictureAdManager()

  private(set) var pipAd: PictureInPictureAd?
  private(set) var isAdShowing = false
  private(set) var isPresentingScreen = false
  var onAdShownListener: (@MainActor () -> Void)?
  var onAdHiddenListener: (@MainActor () -> Void)?

  private let adUnitID = "ca-app-pub-3940256099942544/8810945611"

  /// A Boolean value indicating whether an ad is loaded and available to show.
  var isAdAvailable: Bool {
    pipAd != nil
  }

  private override init() {
    super.init()
  }

  /// Loads a Picture-in-Picture ad.
  func loadAd() async throws {
    let ad = try await PictureInPictureAd.load(
      with: adUnitID,
      request: Request()
    )
    print("Picture-in-Picture ad loaded.")

    pipAd?.hide()
    ad.delegate = self
    pipAd = ad
    isAdShowing = false
    isPresentingScreen = false
  }

  /// Shows the Picture-in-Picture ad with the provided options.
  func showAd(options: PictureInPictureAdOptions) {
    guard let ad = pipAd else {
      print("No Picture-in-Picture ad available to show.")
      return
    }
    ad.show(with: options)
  }

  /// Hides the currently showing Picture-in-Picture ad.
  func hideAd() {
    pipAd?.hide()
  }

  /// Destroys the Picture-in-Picture ad and cleans up resources.
  func destroyAd() {
    pipAd?.hide()
    pipAd = nil
    isAdShowing = false
    isPresentingScreen = false
  }
}

// MARK: - PictureInPictureAdDelegate

extension PictureInPictureAdManager: PictureInPictureAdDelegate {
  func pictureInPictureAdDidShow(_ pictureInPictureAd: PictureInPictureAd) {
    print("Picture-in-Picture ad shown.")
    guard pictureInPictureAd === pipAd else { return }
    isAdShowing = true
    onAdShownListener?()
  }

  func pictureInPictureAdDidHide(_ pictureInPictureAd: PictureInPictureAd) {
    print("Picture-in-Picture ad hidden.")
    guard pictureInPictureAd === pipAd else { return }
    isAdShowing = false
    onAdHiddenListener?()
  }

  func pictureInPictureAdDidFailToShow(
    _ pictureInPictureAd: PictureInPictureAd, error: Error
  ) {
    print("Picture-in-Picture ad failed to show: \(error.localizedDescription)")
    guard pictureInPictureAd === pipAd else { return }
    isAdShowing = false
  }

  func pictureInPictureAdDidRecordImpression(_ pictureInPictureAd: PictureInPictureAd) {
    print("Picture-in-Picture ad recorded an impression.")
  }

  func pictureInPictureAdDidRecordClick(_ pictureInPictureAd: PictureInPictureAd) {
    print("Picture-in-Picture ad recorded a click.")
  }

  func pictureInPictureAd(
    _ pictureInPictureAd: PictureInPictureAd, didRecordPaidEventWith value: AdValue
  ) {
    print("Picture-in-Picture ad paid: \(value.value) \(value.currencyCode)")
  }

  func pictureInPictureAdWillPresentScreen(_ pictureInPictureAd: PictureInPictureAd) {
    print("Picture-in-Picture ad will present screen.")
    guard pictureInPictureAd === pipAd else { return }
    isPresentingScreen = true
  }

  func pictureInPictureAdWillDismissScreen(_ pictureInPictureAd: PictureInPictureAd) {
    print("Picture-in-Picture ad will dismiss screen.")
  }

  func pictureInPictureAdDidDismissScreen(_ pictureInPictureAd: PictureInPictureAd) {
    print("Picture-in-Picture ad dismissed screen.")
    guard pictureInPictureAd === pipAd else { return }
    isPresentingScreen = false
  }
}
