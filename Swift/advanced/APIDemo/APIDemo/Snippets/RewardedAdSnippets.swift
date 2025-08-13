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

private class RewardedAdSnippets {

  private var rewardedAd: RewardedAd?

  // [START validate_server_side_verification]
  private func validateServerSideVerification() async {
    do {
      rewardedAd = try await RewardedAd.load(
        // Replace this ad unit ID with your own ad unit ID.
        with: "ca-app-pub-3940256099942544/1712485313", request: Request())
      let options = ServerSideVerificationOptions()
      options.customRewardText = "SAMPLE_CUSTOM_DATA_STRING"
      rewardedAd?.serverSideVerificationOptions = options
    } catch {
      print("Rewarded ad failed to load with error: \(error.localizedDescription)")
    }
  }
  // [END validate_server_side_verification]

  // MARK: Ad Manager snippets

  // [START validate_server_side_verification_ad_manager]
  private func validateAdManagerServerSideVerification() async {
    do {
      rewardedAd = try await RewardedAd.load(
        // Replace this ad unit ID with your own ad unit ID.
        with: "/21775744923/example/rewarded", request: AdManagerRequest())
      let options = ServerSideVerificationOptions()
      options.customRewardText = "SAMPLE_CUSTOM_DATA_STRING"
      rewardedAd?.serverSideVerificationOptions = options
    } catch {
      print("Rewarded ad failed to load with error: \(error.localizedDescription)")
    }
  }
  // [END validate_server_side_verification_ad_manager]
}
