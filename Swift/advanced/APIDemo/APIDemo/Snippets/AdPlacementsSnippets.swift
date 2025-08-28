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

private class AdPlacementsSnippets: UIViewController {

  // Replace with your own placement ID.
  private let adPlacementID: Int64 = 2500718471
  private let adUnitID = "ca-app-pub-3940256099942544/6978759866"

  // [START load_interstitial]
  private func loadInterstitial() async {
    do {
      let interstitial = try await InterstitialAd.load(
        with: adUnitID, request: Request())
      interstitial.placementID = adPlacementID
      print("Placement ID set to: \(interstitial.placementID)")
    } catch {
      print("Failed to load interstitial ad with error: \(error.localizedDescription)")
    }
  }
  // [END load_interstitial]

  // [START show_banner]
  private func showBanner(_ bannerView: BannerView) {
    bannerView.placementID = adPlacementID
    view.addSubview(bannerView)
  }
  // [END show_banner]

  // [START show_interstitial]
  private func showInterstitial(_ ad: InterstitialAd) {
    ad.placementID = adPlacementID
    ad.present(from: self)
  }
  // [END show_interstitial]

  // [START show_native]
  private func configureView(_ nativeAdView: NativeAdView, withAd nativeAd: NativeAd) {
    nativeAd.placementID = adPlacementID
    nativeAdView.nativeAd = nativeAd
  }
  // [END show_native]
}
