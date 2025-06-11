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

class ViewController: UIViewController, BannerViewDelegate {
  @IBOutlet weak var bannerView: AdManagerBannerView!
  @IBOutlet weak var privacySettingsButton: UIBarButtonItem!
  @IBOutlet weak var adInspectorButton: UIBarButtonItem!

  private var isMobileAdsStartCalled = false

  // This is an ad unit ID for a test ad. Replace with your own banner ad unit ID.
  let adUnitID = "/21775744923/example/adaptive-banner"

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
      if GoogleMobileAdsConsentManager.shared.canRequestAds {
        self.loadBannerAd()
      }
    })
  }

  private func startGoogleMobileAdsSDK() {
    DispatchQueue.main.async {
      guard !self.isMobileAdsStartCalled else { return }

      self.isMobileAdsStartCalled = true

      // [START initialize_sdk]
      // Initialize the Google Mobile Ads SDK.
      MobileAds.shared.start()
      // [END initialize_sdk]

      self.loadBannerAd()
    }
  }

  /// Handle changes to user consent.
  @IBAction func privacySettingsTapped(_ sender: UIBarButtonItem) {
    Task {
      do {
        try await GoogleMobileAdsConsentManager.shared.presentPrivacyOptionsForm(from: self)
      } catch {
        let alertController = UIAlertController(
          title: error.localizedDescription, message: "Please try again later.",
          preferredStyle: .alert)
        alertController.addAction(
          UIAlertAction(
            title: "OK", style: .cancel,
            handler: nil))
        present(alertController, animated: true)
      }
    }
  }

  /// Handle ad inspector launch.
  @IBAction func adInspectorTapped(_ sender: UIBarButtonItem) {
    Task {
      do {
        try await MobileAds.shared.presentAdInspector(from: self)
      } catch {
        let alertController = UIAlertController(
          title: error.localizedDescription, message: "Please try again later.",
          preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alertController, animated: true)
      }
    }
  }

  func loadBannerAd() {
    // Note that Google may serve any reservation ads that that are smaller than
    // the adaptive size as outlined here - https://support.google.com/admanager/answer/9464128.
    // The returned ad will be centered in the ad view.

    // Request an anchored adaptive banner with a width of 375.
    bannerView.adSize = currentOrientationAnchoredAdaptiveBanner(width: 375)
    bannerView.load(AdManagerRequest())
  }

  // MARK: - GADBannerViewDelegate methods

  func bannerViewDidReceiveAd(_ bannerView: BannerView) {
    print(#function)
  }

  func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
    print(#function + ": " + error.localizedDescription)
  }

  func bannerViewDidRecordClick(_ bannerView: BannerView) {
    print(#function)
  }

  func bannerViewDidRecordImpression(_ bannerView: BannerView) {
    print(#function)
  }

  func bannerViewWillPresentScreen(_ bannerView: BannerView) {
    print(#function)
  }

  func bannerViewWillDismissScreen(_ bannerView: BannerView) {
    print(#function)
  }

  func bannerViewDidDismissScreen(_ bannerView: BannerView) {
    print(#function)
  }

}
