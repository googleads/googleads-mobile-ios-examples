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

private class AdPreloaderSnippets: UIViewController, PreloadDelegate,
  FullScreenContentDelegate
{

  // [START start_preload]
  private func startPreloading(adUnitID: String) {
    // Start the preloading initialization process.
    let request = Request()
    let interstitialConfig = PreloadConfigurationV2(
      adUnitID: adUnitID, request: request)
    InterstitialAdPreloader.shared.preload(
      for: adUnitID, configuration: interstitialConfig, delegate: self)
  }
  // [END start_preload]

  // [START pollAndShowAd]
  private func showInterstitialAd(adUnitID: String) {
    // Verify that the preloaded ad is available before polling.
    guard isInterstitialAvailable(adUnitID: adUnitID) else {
      print("Preloaded interstitial ad is not available.")
      return
    }

    // Polling returns the next available ad and loads another ad in the background.
    let ad = InterstitialAdPreloader.shared.ad(with: adUnitID)

    // Interact with the ad object as needed.
    print("Interstitial ad response info: \(String(describing: ad?.responseInfo))")
    ad?.paidEventHandler = { (value: AdValue) in
      print("Interstitial ad paid event: \(value.value), \(value.currencyCode)")
    }

    ad?.fullScreenContentDelegate = self
    ad?.present(from: self)
  }
  // [END pollAndShowAd]

  // [START peek_ad]
  private func getInterstitialAdResponseInfo(preloadID: String) {
    // Get the response info for the preloaded ad.
    if let responseInfo = InterstitialAdPreloader.shared.responseInfo(
      with: preloadID)
    {
      print("Ad response ID: \(responseInfo.responseIdentifier ?? "")")
    }
  }
  // [END peek_ad]

  // [START isAdAvailable]
  private func isInterstitialAvailable(adUnitID: String) -> Bool {
    // Verify that an ad is available before polling.
    return InterstitialAdPreloader.shared.isAdAvailable(with: adUnitID)
  }
  // [END isAdAvailable]

  // MARK: - PreloadDelegate
  // [START set_callback]
  func adAvailable(forPreloadID preloadID: String, responseInfo: ResponseInfo) {
    // This callback indicates that an ad is available for the specified configuration.
    // No action is required here, but updating the UI can be useful in some cases.
    print("Ad preloaded successfully for ad preload ID: \(preloadID)")
  }

  func adsExhausted(forPreloadID preloadID: String) {
    // This callback indicates that all the ads for the specified configuration have been
    // consumed and no ads are available to show. No action is required here, but updating
    // the UI can be useful in some cases.
    // Don't call InterstitialAdPreloader.shared.preload or
    // InterstitialAdPreloader.shared.ad from adsExhausted.
    print("Ad exhausted for ad preload ID: \(preloadID)")
  }

  func adFailedToPreload(forPreloadID preloadID: String, error: Error) {
    print(
      "Ad failed to load with ad preload ID: \(preloadID), Error: \(error.localizedDescription)"
    )
  }
  // [END set_callback]
}
