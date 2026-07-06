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

class AdMobAdPreloadingViewController: UIViewController, PreloadDelegate,
  FullScreenContentDelegate
{

  /// Status messages for preload views.
  enum StatusMessages {
    static let preloadAvailable = "Is available."
    static let preloadExhausted = "Is exhausted."
  }

  /// AdMob ad unit IDs for testing.
  enum AdUnitIDs {
    static let appOpenAdUnitID = "ca-app-pub-3940256099942544/5575463023"
    static let interstitialAdUnitID = "ca-app-pub-3940256099942544/4411468910"
    static let rewardedAdUnitID = "ca-app-pub-3940256099942544/1712485313"
    static let rewardedInterstitialAdUnitID = "ca-app-pub-3940256099942544/6978759866"
  }

  @IBOutlet private weak var preloadContainer: UIStackView!

  private var isMobileAdsStartCalled = false
  private var interstitialView: PreloadView!
  private var rewardedView: PreloadView!
  private var rewardedInterstitialView: PreloadView!
  private var appOpenView: PreloadView!

  override func viewDidLoad() {
    super.viewDidLoad()
    startGoogleMobileAdsSDK()
    configurePreloadViews()
  }

  private func startGoogleMobileAdsSDK() {
    DispatchQueue.main.async {
      guard !self.isMobileAdsStartCalled else { return }

      self.isMobileAdsStartCalled = true

      // Initialize the Google Mobile Ads SDK.
      MobileAds.shared.start { [weak self] status in
        guard let self else { return }
        // Start ad preloading.
        self.startGoogleMobileAdsPreload()
      }
    }
  }

  private func startGoogleMobileAdsPreload() {
    let request = Request()
    let interstitialConfig = PreloadConfigurationV2(
      adUnitID: AdUnitIDs.interstitialAdUnitID, request: request)
    InterstitialAdPreloader.shared.preload(
      for: AdUnitIDs.interstitialAdUnitID, configuration: interstitialConfig, delegate: self)

    let rewardedConfig = PreloadConfigurationV2(
      adUnitID: AdUnitIDs.rewardedAdUnitID, request: request)
    RewardedAdPreloader.shared.preload(
      for: AdUnitIDs.rewardedAdUnitID, configuration: rewardedConfig, delegate: self)

    let appOpenConfig = PreloadConfigurationV2(
      adUnitID: AdUnitIDs.appOpenAdUnitID, request: request)
    AppOpenAdPreloader.shared.preload(
      for: AdUnitIDs.appOpenAdUnitID, configuration: appOpenConfig, delegate: self)

    let rewardedInterstitialConfig = PreloadConfigurationV2(
      adUnitID: AdUnitIDs.rewardedInterstitialAdUnitID, request: request)
    RewardedInterstitialAdPreloader.shared.preload(
      for: AdUnitIDs.rewardedInterstitialAdUnitID, configuration: rewardedInterstitialConfig,
      delegate: self)
  }

  private func isInterstitialAvailable() -> Bool {
    return InterstitialAdPreloader.shared.isAdAvailable(with: AdUnitIDs.interstitialAdUnitID)
  }

  private func isRewardedAvailable() -> Bool {
    return RewardedAdPreloader.shared.isAdAvailable(with: AdUnitIDs.rewardedAdUnitID)
  }

  private func isAppOpenAvailable() -> Bool {
    return AppOpenAdPreloader.shared.isAdAvailable(with: AdUnitIDs.appOpenAdUnitID)
  }

  private func isRewardedInterstitialAvailable() -> Bool {
    return RewardedInterstitialAdPreloader.shared.isAdAvailable(
      with: AdUnitIDs.rewardedInterstitialAdUnitID)
  }

  private func showInterstitialAd() {
    // Polling returns the next available ad and loads another ad in the background.
    guard let ad = InterstitialAdPreloader.shared.ad(with: AdUnitIDs.interstitialAdUnitID) else {
      printAndShowAlert("Preload interstitial ad is exhausted.")
      return
    }

    // Interact with the ad object as needed.
    print("Interstitial ad response info: \(ad.responseInfo)")
    ad.paidEventHandler = { (value: AdValue) in
      print("Interstitial ad paid event: \(value.value), \(value.currencyCode)")
    }

    ad.fullScreenContentDelegate = self
    ad.present(from: self)
  }

  private func showRewardedAd() {
    // Polling returns the next available ad and loads another ad in the background.
    guard let ad = RewardedAdPreloader.shared.ad(with: AdUnitIDs.rewardedAdUnitID) else {
      printAndShowAlert("Preloaded rewarded ad is exhausted.")
      return
    }

    // Interact with the ad object as needed.
    print("Rewarded ad response info: \(ad.responseInfo)")
    ad.paidEventHandler = { (value: AdValue) in
      print("Rewarded ad paid event: \(value.value), \(value.currencyCode)")
    }

    ad.fullScreenContentDelegate = self
    ad.present(from: self) {
      let reward = ad.adReward
      print("User was rewarded \(reward.amount) \(reward.type)")
    }
  }

  private func showAppOpenAd() {
    // Polling returns the next available ad and loads another ad in the background.
    guard let ad = AppOpenAdPreloader.shared.ad(with: AdUnitIDs.appOpenAdUnitID) else {
      printAndShowAlert("Preload app open ad is exhausted.")
      return
    }

    // Interact with the ad object as needed.
    print("App open ad response info: \(ad.responseInfo)")
    ad.paidEventHandler = { (value: AdValue) in
      print("App open ad paid event: \(value.value), \(value.currencyCode)")
    }

    ad.fullScreenContentDelegate = self
    ad.present(from: self)
  }

  private func showRewardedInterstitialAd() {
    // Polling returns the next available ad and loads another ad in the background.
    guard
      let ad = RewardedInterstitialAdPreloader.shared.ad(
        with: AdUnitIDs.rewardedInterstitialAdUnitID)
    else {
      printAndShowAlert("Preload rewarded interstitial ad is exhausted.")
      return
    }

    // Interact with the ad object as needed.
    print("Rewarded interstitial ad response info: \(ad.responseInfo)")
    ad.paidEventHandler = { (value: AdValue) in
      print("Rewarded interstitial ad paid event: \(value.value), \(value.currencyCode)")
    }

    ad.fullScreenContentDelegate = self
    ad.present(from: self) {
      let reward = ad.adReward
      print("User was rewarded \(reward.amount) \(reward.type)")
    }
  }

  private func configurePreloadViews() {
    interstitialView = PreloadView.load(
      title: "Interstitial",
      showDelegate: { [weak self] in
        self?.showInterstitialAd()
      })
    preloadContainer.addArrangedSubview(interstitialView)
    rewardedView = PreloadView.load(
      title: "Rewarded",
      showDelegate: { [weak self] in
        self?.showRewardedAd()
      })
    preloadContainer.addArrangedSubview(rewardedView)
    appOpenView = PreloadView.load(
      title: "App open",
      showDelegate: { [weak self] in
        self?.showAppOpenAd()
      })
    preloadContainer.addArrangedSubview(appOpenView)
    rewardedInterstitialView = PreloadView.load(
      title: "Rewarded Interstitial",
      showDelegate: { [weak self] in
        self?.showRewardedInterstitialAd()
      })
    preloadContainer.addArrangedSubview(rewardedInterstitialView)

    updatePreloadViews()
  }

  private func updatePreloadViews() {
    updatePreloadView(preloadView: interstitialView, isAvailable: isInterstitialAvailable())
    updatePreloadView(preloadView: rewardedView, isAvailable: isRewardedAvailable())
    updatePreloadView(preloadView: appOpenView, isAvailable: isAppOpenAvailable())
    updatePreloadView(
      preloadView: rewardedInterstitialView, isAvailable: isRewardedInterstitialAvailable())
  }

  private func updatePreloadView(preloadView: PreloadView, isAvailable: Bool) {
    preloadView.showButton.isEnabled = isAvailable
    preloadView.statusText.text =
      isAvailable ? StatusMessages.preloadAvailable : StatusMessages.preloadExhausted
    preloadView.statusText.textColor = isAvailable ? UIColor.blue : UIColor.red
    if let statusText = preloadView.statusText.text {
      UIAccessibility.post(notification: .announcement, argument: statusText)
    }
  }

  private func printAndShowAlert(_ message: String) {
    let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
    let dismissAction = UIAlertAction(title: "Dismiss", style: .default)
    alert.addAction(dismissAction)
    present(alert, animated: true, completion: nil)
  }

  // MARK: - PreloadDelegate
  func adAvailable(forPreloadID preloadID: String, responseInfo: ResponseInfo) {
    // This callback indicates that an ad is available for the specified configuration.
    // No action is required here, but updating the UI can be useful in some cases.
    print("Ad preloaded successfully for ad preload ID: \(preloadID)")
    updatePreloadViews()
  }

  func adsExhausted(forPreloadID preloadID: String) {
    // This callback indicates that all the ads for the specified configuration have been
    // consumed and no ads are available to show. No action is required here, but updating
    // the UI can be useful in some cases.
    // [Important] Don't call AdPreloader.shared.preload or AdPreloader.shared.ad
    // from adsExhausted.
    print("Ad exhausted for ad preload ID: \(preloadID)")
    updatePreloadViews()
  }

  func adFailedToPreload(forPreloadID preloadID: String, error: Error) {
    print(
      "Ad failed to load with ad preload ID: \(preloadID), Error: \(error.localizedDescription)"
    )
  }

  // MARK: - FullScreenContentDelegate

  func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
    print("Preloaded ad will be presented.")
  }

  func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
    print("Preloaded ad dismissed.")
  }
}
