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

private class RewardedInterstitialAdSnippets: UIViewController, FullScreenContentDelegate {

  private var rewardedInterstitialAd: RewardedInterstitialAd?

  // Replace this ad unit ID with your own ad unit ID.
  private let adUnitID = "ca-app-pub-3940256099942544/6978759866"
  private let adManagerAdUnitID = "/21775744923/example/rewarded-interstitial"

  // [START load_ad]
  func loadRewardedInterstitialAd() async {
    do {
      rewardedInterstitialAd = try await RewardedInterstitialAd.load(
        // Replace this ad unit ID with your own ad unit ID.
        with: adUnitID, request: Request())
      // [START set_delegate]
      rewardedInterstitialAd?.fullScreenContentDelegate = self
      // [END set_delegate]
    } catch {
      print("Rewarded ad failed to load with error: \(error.localizedDescription)")
    }
  }
  // [END load_ad]

  // [START load_ad_gam]
  func loadAdManagerRewardedInterstitialAd() async {
    do {
      rewardedInterstitialAd = try await RewardedInterstitialAd.load(
        // Replace this ad unit ID with your own ad unit ID.
        with: adUnitID, request: AdManagerRequest())
      rewardedInterstitialAd?.fullScreenContentDelegate = self
    } catch {
      print("Rewarded ad failed to load with error: \(error.localizedDescription)")
    }
  }
  // [END load_ad_gam]

  // [START validate_server_side_verification]
  private func validateServerSideVerification() async {
    do {
      rewardedInterstitialAd = try await RewardedInterstitialAd.load(
        // Replace this ad unit ID with your own ad unit ID.
        with: adUnitID, request: Request())
      let options = ServerSideVerificationOptions()
      options.customRewardText = "SAMPLE_CUSTOM_DATA_STRING"
      rewardedInterstitialAd?.serverSideVerificationOptions = options
    } catch {
      print("Rewarded ad failed to load with error: \(error.localizedDescription)")
    }
  }
  // [END validate_server_side_verification]

  // [START validate_gam_server_side_verification]
  private func validateAdManagerServerSideVerification() async {
    do {
      rewardedInterstitialAd = try await RewardedInterstitialAd.load(
        // Replace this ad unit ID with your own ad unit ID.
        with: adUnitID, request: AdManagerRequest())
      let options = ServerSideVerificationOptions()
      options.customRewardText = "SAMPLE_CUSTOM_DATA_STRING"
      rewardedInterstitialAd?.serverSideVerificationOptions = options
    } catch {
      print("Rewarded ad failed to load with error: \(error.localizedDescription)")
    }
  }
  // [END validate_gam_server_side_verification]

  // [START ad_events]
  func adDidRecordImpression(_ ad: FullScreenPresentingAd) {
    print("\(#function) called.")
  }

  func adDidRecordClick(_ ad: FullScreenPresentingAd) {
    print("\(#function) called.")
  }

  func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
    print("\(#function) called.")
  }

  func adWillDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
    print("\(#function) called.")
  }

  func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
    print("\(#function) called.")
    // Clear the rewarded interstitial ad.
    rewardedInterstitialAd = nil
  }

  func ad(
    _ ad: FullScreenPresentingAd,
    didFailToPresentFullScreenContentWithError error: Error
  ) {
    print("\(#function) called with error: \(error.localizedDescription).")
  }
  // [END ad_events]

  // [START show_ad]
  func showRewardedInterstitialAd() {
    guard let rewardedInterstitialAd = rewardedInterstitialAd else {
      return print("Ad wasn't ready.")
    }

    // The UIViewController parameter is an optional.
    rewardedInterstitialAd.present(from: nil) {
      let reward = rewardedInterstitialAd.adReward
      print("Reward received with currency \(reward.amount), amount \(reward.amount.doubleValue)")
      // TODO: Reward the user.
    }
  }
  // [END show_ad]
}
