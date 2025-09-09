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
import UIKit

class AdMobSCARSnippets: NSObject {

  // [START signal_request_native]
  func loadNative(adUnitID: String) async {
    // Create a signal request for an ad.
    let signalRequest = NativeSignalRequest(signalType: "SIGNAL_TYPE")
    signalRequest.adUnitID = adUnitID

    do {
      let signalResponse = try await MobileAds.generateSignal(signalRequest)
      print("Signal string: \(signalResponse.signal)")

      // Fetch the ad response using your generated signal.
      let response = await fetchAdResponseString(signalRequest: signalResponse)
    } catch {
      print("Error getting ad info: \(error.localizedDescription)")
    }
  }
  // [END signal_request_native]

  // [START signal_request_banner]
  func loadBanner(adUnitID: String) async {
    // Create a signal request for an ad.
    let signalRequest = BannerSignalRequest(signalType: "SIGNAL_TYPE")
    signalRequest.adUnitID = adUnitID
    // Refer to the AdSize class for available ad sizes.
    signalRequest.adSize = currentOrientationInlineAdaptiveBanner(width: 375)

    do {
      let signalResponse = try await MobileAds.generateSignal(signalRequest)
      print("Signal string: \(signalResponse.signal)")

      // Fetch the ad response using your generated signal.
      let response = await fetchAdResponseString(signalRequest: signalResponse)
    } catch {
      print("Error getting ad info: \(error.localizedDescription)")
    }
  }
  // [END signal_request_banner]

  // [START native_ad_options]
  func loadNativeWithOptions(adUnitID: String) async {
    // Create a signal request for an ad.
    let signalRequest = NativeSignalRequest(signalType: "SIGNAL_TYPE")
    signalRequest.adUnitID = adUnitID

    // Enable shared native ad options.
    signalRequest.isImageLoadingDisabled = false
    signalRequest.mediaAspectRatio = .any
    signalRequest.preferredAdChoicesPosition = .topRightCorner

    // Enable video options.
    let videoOptions = VideoOptions()
    videoOptions.shouldStartMuted = true
    signalRequest.videoOptions = videoOptions

    do {
      let signalResponse = try await MobileAds.generateSignal(signalRequest)
      print("Signal string: \(signalResponse.signal)")

      // Fetch the ad response using your generated signal.
      let response = await fetchAdResponseString(signalRequest: signalResponse)
    } catch {
      print("Error getting ad info: \(error.localizedDescription)")
    }
  }
  // [END native_ad_options]

  // [START fetch_response]
  // This function emulates a request to your ad server.
  func fetchAdResponseString(signalRequest: Signal) async -> String {
    return "adResponseString"
  }
  // [END fetch_response]

  // [START render_banner]
  func renderBanner(adUnitID: String, signalResponse: String) {
    let bannerView = BannerView(adSize: AdSizeBanner)
    bannerView.adUnitID = adUnitID
    bannerView.load(with: signalResponse)
  }
  // [END render_banner]

  // [START render_native]
  var adLoader: AdLoader!

  func renderNative(
    adUnitID: String, signalResponse: String, rootViewController: UIViewController
  ) {
    adLoader = AdLoader(
      adUnitID: adUnitID,
      rootViewController: rootViewController,
      adTypes: [.native],
      options: nil)
    adLoader.delegate = self
    adLoader.load(with: signalResponse)
  }
  // [END render_native]
}

extension AdMobSCARSnippets: NativeAdLoaderDelegate {
  func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
    // Native ad received.
  }

  func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: Error) {
    // Native ad failed to load.
  }
}
