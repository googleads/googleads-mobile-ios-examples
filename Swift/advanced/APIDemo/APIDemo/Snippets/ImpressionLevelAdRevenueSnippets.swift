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

/// Swift code snippets for impression-level ad revenue in the GMA SDK developer guide.
private class ImpressionLevelAdRevenueSnippets: NSObject, FullScreenContentDelegate {

  private let adUnitID = "ca-app-pub-3940256099942544/6978759866"

  var rewardedAd: RewardedAd?

  func requestRewardedAd() async {
    do {
      rewardedAd = try await RewardedAd.load(with: adUnitID, request: Request())
      rewardedAd?.fullScreenContentDelegate = self

      // Get the ad unit ID.
      let adUnitID = self.rewardedAd?.adUnitID
      print("Ad unit ID: \(String(describing: adUnitID))")

      // Get the response info.
      let responseInfo = self.rewardedAd?.responseInfo
      let loadedAdNetworkResponseInfo = responseInfo?.loadedAdNetworkResponseInfo

      // Accessing network info properties
      let adSourceID = loadedAdNetworkResponseInfo?.adSourceID
      let adSourceInstanceID = loadedAdNetworkResponseInfo?.adSourceInstanceID
      let adSourceInstanceName = loadedAdNetworkResponseInfo?.adSourceInstanceName
      let adSourceName = loadedAdNetworkResponseInfo?.adSourceName

      print("Ad source ID: \(String(describing: adSourceID))")
      print("Ad source instance ID: \(String(describing: adSourceInstanceID))")
      print("Ad source instance name: \(String(describing: adSourceInstanceName))")
      print("Ad source name: \(String(describing: adSourceName))")

      // Get the extras info.
      let extras = responseInfo?.extras
      let mediationGroupName = extras?["mediation_group_name"]
      let mediationABTestName = extras?["mediation_ab_test_name"]
      let mediationABTestVariant = extras?["mediation_ab_test_variant"]

      print("Mediation group name: \(String(describing: mediationGroupName))")
      print("Mediation AB test name: \(String(describing: mediationABTestName))")
      print("Mediation AB test variant: \(String(describing: mediationABTestVariant))")

    } catch {
      print("Failed to load rewarded ad with error: \(error.localizedDescription)")
    }
  }

  // MARK: - FullScreenContentDelegate

  // [START get_impression_level_ad_revenue]
  func ad(_ ad: FullScreenPresentingAd, didRecordPaidEventWith adValue: AdValue) {
    // TODO: Send the impression-level ad revenue information to your preferred
    // analytics server directly within this callback.

    // Extract the impression-level ad revenue data.
    let value = adValue.value
    let currencyCode = adValue.currencyCode
    let precision = adValue.precision

    print(
      "Ad paid event. Value: \(value) \(currencyCode), with precision: \(precision)."
    )
  }
  // [END get_impression_level_ad_revenue]
}
