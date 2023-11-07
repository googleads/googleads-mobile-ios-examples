//
//  Copyright 2023 Google LLC
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

class ViewController: UIViewController, GADBannerViewDelegate {
  @IBOutlet weak var bannerView: GAMBannerView!
  @IBOutlet weak var privacySettingsButton: UIBarButtonItem!

  private var isMobileAdsStartCalled = false

  // This is an ad unit ID for a test ad. Replace with your own banner ad unit ID.
  let adUnitID = "/30497360/adaptive_banner_test_iu/backfill"

  override func viewDidLoad() {
    super.viewDidLoad()

    bannerView.adUnitID = adUnitID
    bannerView.rootViewController = self
    bannerView.delegate = self

    GoogleMobileAdsConsentManager.shared.gatherConsent(from: self) { [weak self] (consentError) in
      guard let self else { return }

      if let consentError {
        // Consent gathering failed.
        print("Error: \(consentError.localizedDescription)")
      }

      if GoogleMobileAdsConsentManager.shared.canRequestAds {
        self.startGoogleMobileAdsSDK()
      }

      self.privacySettingsButton.isEnabled =
        GoogleMobileAdsConsentManager.shared.isPrivacyOptionsRequired
    }

    // This sample attempts to load ads using consent obtained in the previous session.
    if GoogleMobileAdsConsentManager.shared.canRequestAds {
      startGoogleMobileAdsSDK()
    }
  }

  override func viewWillTransition(
    to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator
  ) {
    coordinator.animate(alongsideTransition: { _ in
      self.loadBannerAd()
    })
  }

  private func startGoogleMobileAdsSDK() {
    DispatchQueue.main.async {
      guard !self.isMobileAdsStartCalled else { return }

      self.isMobileAdsStartCalled = true

      // Initialize the Google Mobile Ads SDK.
      GADMobileAds.sharedInstance().start()
      self.loadBannerAd()
    }
  }

  // Handle changes to user consent.
  @IBAction func privacySettingsTapped(_ sender: UIBarButtonItem) {
    GoogleMobileAdsConsentManager.shared.presentPrivacyOptionsForm(from: self) {
      [weak self] (formError) in
      guard let self, let formError else { return }

      let alertController = UIAlertController(
        title: formError.localizedDescription, message: "Please try again later.",
        preferredStyle: .alert)
      alertController.addAction(UIAlertAction(title: "OK", style: .cancel))
      self.present(alertController, animated: true)
    }
  }

  func loadBannerAd() {
    let viewWidth = view.frame.inset(by: view.safeAreaInsets).width

    // Here the current interface orientation is used. Use
    // GADLandscapeAnchoredAdaptiveBannerAdSizeWithWidth or
    // GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth if you prefer to load an ad of a
    // particular orientation,
    let adaptiveSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)

    // Note that Google may serve any reservation ads that that are smaller than
    // the adaptive size as outlined here - https://support.google.com/admanager/answer/9464128.
    // The returned ad will be centered in the ad view.
    bannerView.adSize = adaptiveSize
    bannerView.load(GAMRequest())
  }

  // MARK: - GADBannerViewDelegate methods

  func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
    print(#function)
  }

  func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
    print(#function + ": " + error.localizedDescription)
  }

  func bannerViewDidRecordClick(_ bannerView: GADBannerView) {
    print(#function)
  }

  func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
    print(#function)
  }

  func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
    print(#function)
  }

  func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
    print(#function)
  }

  func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
    print(#function)
  }

}
