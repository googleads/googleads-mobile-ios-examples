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

/// Singleton class that loads, manages lifecycle, and handles events for squeezeback ads.
@MainActor
class SqueezebackAdManager: NSObject, SqueezebackAdDelegate {

  static let shared = SqueezebackAdManager()

  private(set) var squeezebackAd: SqueezebackAd?

  var onAdShownListener: (@MainActor () -> Void)?
  var onAdHiddenListener: (@MainActor () -> Void)?

  private override init() {
    super.init()
  }

  /// Loads a squeezeback ad.
  @discardableResult
  func loadAd() async throws -> SqueezebackAd {
    let ad = try await SqueezebackAd.load(
      with: Constants.squeezebackAdUnitID,
      request: Request()
    )
    print("Squeezeback ad loaded.")
    squeezebackAd?.hide()
    squeezebackAd = ad
    setAdEventCallback(ad)
    return ad
  }

  /// Shows the squeezeback ad with the provided options.
  func showAd(options: SqueezebackAdOptions = SqueezebackAdOptions()) {
    guard let ad = squeezebackAd else {
      print("No squeezeback ad available to show.")
      return
    }
    ad.show(with: options)
  }

  /// Hides the currently showing squeezeback ad.
  func hideAd() {
    squeezebackAd?.hide()
  }

  /// Destroys the squeezeback ad and cleans up resources.
  func destroyAd() {
    squeezebackAd?.hide()
    squeezebackAd = nil
  }

  /// Checks if an ad exists and is available to show.
  func isAdAvailable() -> Bool {
    return squeezebackAd != nil
  }

  private func setAdEventCallback(_ ad: SqueezebackAd) {
    ad.delegate = self
    ad.paidEventHandler = { value in
      print("Squeezeback ad paid: \(value.value) \(value.currencyCode)")
    }
  }

  // MARK: - SqueezebackAdDelegate

  func squeezebackAdDidShow(_ squeezebackAd: SqueezebackAd) {
    print("Squeezeback ad shown.")
    onAdShownListener?()
  }

  func squeezebackAdDidHide(_ squeezebackAd: SqueezebackAd) {
    print("Squeezeback ad hidden.")
    onAdHiddenListener?()
  }

  func squeezebackAdDidFailToShow(_ squeezebackAd: SqueezebackAd, error: Error) {
    print("Squeezeback ad failed to show: \(error.localizedDescription)")
  }

  func squeezebackAdDidRecordImpression(_ squeezebackAd: SqueezebackAd) {
    print("Squeezeback ad recorded an impression.")
  }

  func squeezebackAdDidRecordClick(_ squeezebackAd: SqueezebackAd) {
    print("Squeezeback ad recorded a click.")
  }

  func squeezebackAdWillPresentScreen(_ squeezebackAd: SqueezebackAd) {
    print("Squeezeback ad will present screen.")
  }

  func squeezebackAdWillDismissScreen(_ squeezebackAd: SqueezebackAd) {
    print("Squeezeback ad will dismiss screen.")
  }

  func squeezebackAdDidDismissScreen(_ squeezebackAd: SqueezebackAd) {
    print("Squeezeback ad dismissed screen.")
  }
}
