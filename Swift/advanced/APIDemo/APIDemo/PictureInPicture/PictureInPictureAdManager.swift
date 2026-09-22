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

/// Singleton class that loads, manages lifecycle, and handles events for Picture-in-Picture (PiP)
/// ads.
@MainActor
class PictureInPictureAdManager: NSObject, PictureInPictureAdDelegate {

  static let shared = PictureInPictureAdManager()

  private(set) var pipAd: PictureInPictureAd?

  var onAdShownListener: (@MainActor () -> Void)?
  var onAdHiddenListener: (@MainActor () -> Void)?

  private override init() {
    super.init()
  }

  /// Loads a Picture-in-Picture ad.
  @discardableResult
  func loadAd() async throws -> PictureInPictureAd {
    let ad = try await PictureInPictureAd.load(
      with: Constants.pictureInPictureAdUnitID,
      request: Request()
    )
    print("Picture-in-Picture ad loaded.")
    pipAd?.hide()
    pipAd = ad
    setAdEventCallback(ad)
    return ad
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
  }

  /// Checks if an ad exists and is available to show.
  func isAdAvailable() -> Bool {
    return pipAd != nil
  }

  private func setAdEventCallback(_ ad: PictureInPictureAd) {
    ad.delegate = self
    ad.paidEventHandler = { value in
      print("Picture-in-Picture ad paid: \(value.value) \(value.currencyCode)")
    }
  }

  // MARK: - PictureInPictureAdDelegate

  func pictureInPictureAdDidShow(_ pictureInPictureAd: PictureInPictureAd) {
    print("Picture-in-Picture ad shown.")
    onAdShownListener?()
  }

  func pictureInPictureAdDidHide(_ pictureInPictureAd: PictureInPictureAd) {
    print("Picture-in-Picture ad hidden.")
    onAdHiddenListener?()
  }

  func pictureInPictureAdDidFailToShow(
    _ pictureInPictureAd: PictureInPictureAd, error: Error
  ) {
    print("Picture-in-Picture ad failed to show: \(error.localizedDescription)")
  }

  func pictureInPictureAdDidRecordImpression(_ pictureInPictureAd: PictureInPictureAd) {
    print("Picture-in-Picture ad recorded an impression.")
  }

  func pictureInPictureAdDidRecordClick(_ pictureInPictureAd: PictureInPictureAd) {
    print("Picture-in-Picture ad recorded a click.")
  }

  func pictureInPictureAdWillPresentScreen(_ pictureInPictureAd: PictureInPictureAd) {
    print("Picture-in-Picture ad will present screen.")
  }

  func pictureInPictureAdWillDismissScreen(_ pictureInPictureAd: PictureInPictureAd) {
    print("Picture-in-Picture ad will dismiss screen.")
  }

  func pictureInPictureAdDidDismissScreen(_ pictureInPictureAd: PictureInPictureAd) {
    print("Picture-in-Picture ad dismissed screen.")
  }
}
