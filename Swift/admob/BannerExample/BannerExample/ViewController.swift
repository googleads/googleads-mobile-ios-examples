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

  @IBOutlet weak var bannerView: BannerView!
  @IBOutlet weak var privacySettingsButton: UIBarButtonItem!
  @IBOutlet weak var adInspectorButton: UIBarButtonItem!

  private var isMobileAdsStartCalled = false

  override func viewDidLoad() {
    super.viewDidLoad()

    // Replace this ad unit ID with your own ad unit ID.
    bannerView.adUnitID = "ca-app-pub-3940256099942544/2435281174"
    bannerView.rootViewController = self
    bannerView.delegate = self

    GoogleMobileAdsConsentManager.shared.gatherConsent(from: self) { [weak self] consentError in
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

  /// Handle changes to user consent.
  @IBAction func privacySettingsTapped(_ sender: UIBarButtonItem) {
    Task {
      do {
        try await GoogleMobileAdsConsentManager.shared.presentPrivacyOptionsForm()
      } catch {
        let alertController = UIAlertController(
          title: error.localizedDescription, message: "Please try again later.",
          preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel))
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
        // There was an issue and the inspector was not displayed.
        let alertController = UIAlertController(
          title: error.localizedDescription, message: "Please try again later.",
          preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alertController, animated: true)
      }
    }
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

  func loadBannerAd() {
    // Request a large anchored adaptive banner with a width of 375.
    bannerView.adSize = largeAnchoredAdaptiveBanner(width: 375)

    bannerView.load(Request())
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
