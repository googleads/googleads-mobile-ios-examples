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

/// Receives squeezeback ad presentation state updates.
@MainActor
protocol SqueezebackAdManagerDelegate: AnyObject {
  /// Tells the delegate that the squeezeback ad was shown on screen.
  func squeezebackAdManagerDidShowAd(_ manager: SqueezebackAdManager)

  /// Tells the delegate that the squeezeback ad was hidden or dismissed.
  func squeezebackAdManagerDidHideAd(_ manager: SqueezebackAdManager)

  /// Tells the delegate that the squeezeback ad failed to show on screen.
  func squeezebackAdManager(_ manager: SqueezebackAdManager, didFailToShowAdWith error: Error)
}

/// Loads, manages the lifecycle of, and handles events for squeezeback ads across screens.
@MainActor
class SqueezebackAdManager: NSObject, SqueezebackAdDelegate {

  static let shared = SqueezebackAdManager()

  private(set) var squeezebackAd: SqueezebackAd?
  private(set) var isAdShowing = false
  weak var delegate: SqueezebackAdManagerDelegate?

  private override init() {
    super.init()
  }

  /// Loads a squeezeback ad.
  @discardableResult
  func loadAd() async throws -> SqueezebackAd {
    guard !isAdShowing else {
      let message = "Cannot load a new squeezeback ad while one is currently showing."
      print(message)
      throw NSError(
        domain: "com.google.APIDemo.SqueezebackAdManager",
        code: 1,
        userInfo: [NSLocalizedDescriptionKey: message]
      )
    }

    let ad = try await SqueezebackAd.load(
      with: Constants.squeezebackAdUnitID,
      request: Request()
    )
    try Task.checkCancellation()
    guard !isAdShowing else {
      throw NSError(
        domain: "com.google.APIDemo.SqueezebackAdManager",
        code: 1,
        userInfo: [
          NSLocalizedDescriptionKey:
            "Cannot load a new squeezeback ad while one is currently showing."
        ]
      )
    }
    print("Squeezeback ad loaded.")
    squeezebackAd?.hide()
    squeezebackAd = ad
    ad.delegate = self
    return ad
  }

  /// Shows the squeezeback ad with the provided options.
  func showAd(options: SqueezebackAdOptions = SqueezebackAdOptions()) {
    guard let ad = squeezebackAd, !isAdShowing else {
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
    isAdShowing = false
    let ad = squeezebackAd
    squeezebackAd = nil
    ad?.hide()
  }

  /// Checks if an ad is loaded and available to show.
  func isAdAvailable() -> Bool {
    return squeezebackAd != nil && !isAdShowing
  }

  // MARK: - SqueezebackAdDelegate

  func squeezebackAdDidShow(_ squeezebackAd: SqueezebackAd) {
    guard self.squeezebackAd === squeezebackAd else { return }
    print("Squeezeback ad shown.")
    isAdShowing = true
    delegate?.squeezebackAdManagerDidShowAd(self)
  }

  func squeezebackAdDidHide(_ squeezebackAd: SqueezebackAd) {
    print("Squeezeback ad hidden.")
    guard self.squeezebackAd === squeezebackAd else { return }
    isAdShowing = false
    self.squeezebackAd = nil
    delegate?.squeezebackAdManagerDidHideAd(self)
  }

  func squeezebackAdDidFailToShow(_ squeezebackAd: SqueezebackAd, error: Error) {
    print("Squeezeback ad failed to show: \(error.localizedDescription)")
    guard self.squeezebackAd === squeezebackAd else { return }
    isAdShowing = false
    delegate?.squeezebackAdManager(self, didFailToShowAdWith: error)
  }

  func squeezebackAdDidRecordImpression(_ squeezebackAd: SqueezebackAd) {
    print("Squeezeback ad recorded an impression.")
  }

  func squeezebackAdDidRecordClick(_ squeezebackAd: SqueezebackAd) {
    print("Squeezeback ad recorded a click.")
  }

  func squeezebackAd(_ squeezebackAd: SqueezebackAd, didRecordPaidEventWith value: AdValue) {
    print("Squeezeback ad paid: \(value.value) \(value.currencyCode)")
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
