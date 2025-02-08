//
//  Copyright 2024 Google LLC
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

class AdmobPreloadViewController: UIViewController, GADPreloadEventDelegate,
  GADFullScreenContentDelegate
{

  // Status messages for preload views.
  private final var preloadAvailable = "Is available."
  private final var preloadExhausted = "Is exhausted."

  @IBOutlet weak var preloadContainer: UIStackView!

  private var isMobileAdsStartCalled = false
  private var interstitialView: AdmobPreloadView!
  private var rewardedView: AdmobPreloadView!
  private var appOpenView: AdmobPreloadView!

  override func viewDidLoad() {
    super.viewDidLoad()
    startGoogleMobileAdsPreload()
    configurePreloadViews()
  }

  // [START start_preload]
  private func startGoogleMobileAdsPreload() {
    // Define a list of PreloadConfigurations of ad units and formats you want to preload.
    let interstitialConfig = GADPreloadConfiguration.init(
      adUnitID: Constants.admobPreloadInterstitialAdUnitID,
      adFormat: GADAdFormat.interstitial
    )

    let rewardedConfig = GADPreloadConfiguration.init(
      adUnitID: Constants.admobPreloadRewardedAdUnitID,
      adFormat: GADAdFormat.rewarded
    )

    let appOpenConfig = GADPreloadConfiguration.init(
      adUnitID: Constants.admobPreloadAppOpenAdUnitID,
      adFormat: GADAdFormat.appOpen
    )

    // Optionally set a custom GADRequest for each configuration.
    //interstitialConfig.request = GADRequest()
    //rewardedConfig.request = GADRequest()
    //appOpenConfig.request = GADRequest()

    // Optionally set the quantity of ads that can be cached for each ad units.
    interstitialConfig.bufferSize = 2
    rewardedConfig.bufferSize = 2
    appOpenConfig.bufferSize = 2

    // Start the preloading initialization process.
    GADMobileAds.sharedInstance().preload(
      with: [interstitialConfig, rewardedConfig, appOpenConfig],
      delegate: self
    )
  }

  // [END start_preload]

  // [START isAdAvailable]
  private func isInterstitialAvailable() -> Bool {
    return GADInterstitialAd.isPreloadedAdAvailable(Constants.admobPreloadInterstitialAdUnitID)
  }

  // [END isAdAvailable]

  private func isRewardedAvailable() -> Bool {
    // Verify that an ad is available before polling.
    return GADRewardedAd.isPreloadedAdAvailable(Constants.admobPreloadRewardedAdUnitID)
  }

  private func isAppOpenAvailable() -> Bool {
    // Verify that an ad is available before polling.
    return GADAppOpenAd.isPreloadedAdAvailable(Constants.admobPreloadAppOpenAdUnitID)
  }

  // [START pollAndShowAd]
  private func showInterstitialAd() {
    // Verify that the preloaded ad is available before polling.
    guard isInterstitialAvailable() else {
      printAndShowAlert("Preload interstitial ad is exhausted.")
      return
    }

    // Polling returns the next available ad and load another ad in the background.
    let ad = GADInterstitialAd.preloadedAd(withAdUnitID: Constants.admobPreloadInterstitialAdUnitID)
    ad?.fullScreenContentDelegate = self
    ad?.present(fromRootViewController: self)
  }

  // [END pollAndShowAd]

  private func showRewardedAd() {
    // Verify that the preloaded ad is available before polling.
    guard isRewardedAvailable() else {
      printAndShowAlert("Preloaded rewarded ad is exhausted.")
      return
    }

    // Polling returns the next available ad and load another ad in the background.
    let ad = GADRewardedAd.preloadedAd(withAdUnitID: Constants.admobPreloadRewardedAdUnitID)
    ad?.fullScreenContentDelegate = self
    ad?.present(fromRootViewController: self) {
      if let reward = ad?.adReward {
        print("User was rewarded \(reward.amount) \(reward.type)")
      }
    }
  }

  private func showAppOpenAd() {
    // Verify that the preloaded ad is available before polling.
    guard isAppOpenAvailable() else {
      printAndShowAlert("Preload app open ad is exhausted.")
      return
    }

    // Polling returns the next available ad and load another ad in the background.
    let ad = GADAppOpenAd.preloadedAd(withAdUnitID: Constants.admobPreloadAppOpenAdUnitID)
    ad?.fullScreenContentDelegate = self
    ad?.present(fromRootViewController: self)
  }

  private func configurePreloadViews() {
    interstitialView = AdmobPreloadView.load(
      title: "Interstitial", showDelegate: showInterstitialAd)
    preloadContainer.addArrangedSubview(interstitialView)
    rewardedView = AdmobPreloadView.load(title: "Rewarded", showDelegate: showRewardedAd)
    preloadContainer.addArrangedSubview(rewardedView)
    appOpenView = AdmobPreloadView.load(title: "App open", showDelegate: showAppOpenAd)
    preloadContainer.addArrangedSubview(appOpenView)

    updatePreloadViews()
  }

  private func updatePreloadViews() {
    updatePreloadView(preloadView: interstitialView, isAvailable: isInterstitialAvailable())
    updatePreloadView(preloadView: rewardedView, isAvailable: isRewardedAvailable())
    updatePreloadView(preloadView: appOpenView, isAvailable: isAppOpenAvailable())
  }

  private func updatePreloadView(preloadView: AdmobPreloadView, isAvailable: Bool) {
    preloadView.showButton.isEnabled = isAvailable
    preloadView.statusText.text = isAvailable ? preloadAvailable : preloadExhausted
    preloadView.statusText.textColor = isAvailable ? UIColor.blue : UIColor.red
  }

  private func printAndShowAlert(_ message: String) {
    let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
    let dismissAction = UIAlertAction(title: "Dismiss", style: .default)
    alert.addAction(dismissAction)
    present(alert, animated: true, completion: nil)
  }

  // MARK: GADPreloadEventDelegate

  func adAvailable(for configuration: GADPreloadConfiguration) {
    print("Ad preloaded successfully for ad unit ID: \(configuration.adUnitID)")
    updatePreloadViews()
  }

  func adsExhausted(for configuration: GADPreloadConfiguration) {
    print("Ad exhausted for ad unit ID: \(configuration.adUnitID)")
    updatePreloadViews()
  }

  // MARK: GADFullScreenContentDelegate

  func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
    print("Preloaded ad will be presented.")
  }

  func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
    print("Preloaded ad dismissed.")
  }
}
