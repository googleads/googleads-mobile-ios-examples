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

private class ImpressionLevelAdRevenueSnippets {

  private let adUnitID = "ca-app-pub-3940256099942544/6978759866"

  var rewardedAd: RewardedAd?

  func requestRewardedAd() async {
    do {
      rewardedAd = try await RewardedAd.load(with: adUnitID, request: Request())
      // [START get_impression_level_ad_revenue]
      rewardedAd?.paidEventHandler = { adValue in
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

      // Get the ad unit ID.
      _ = self.rewardedAd?.adUnitID

      // Get the response info.
      let responseInfo = self.rewardedAd?.responseInfo
      let loadedAdNetworkResponseInfo = responseInfo?.loadedAdNetworkResponseInfo
      _ = loadedAdNetworkResponseInfo?.adSourceID
      _ = loadedAdNetworkResponseInfo?.adSourceInstanceID
      _ = loadedAdNetworkResponseInfo?.adSourceInstanceName
      _ = loadedAdNetworkResponseInfo?.adSourceName

      // Get the extras info.
      _ = responseInfo?.extras["mediation_group_name"]
      _ = responseInfo?.extras["mediation_ab_test_name"]
      _ = responseInfo?.extras["mediation_ab_test_variant"]

    } catch {
      print("Failed to load rewarded ad with error: \(error.localizedDescription)")
    }
  }
}
