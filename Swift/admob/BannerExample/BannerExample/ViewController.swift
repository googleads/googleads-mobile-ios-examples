//
//  Copyright (C) 2015 Google LLC
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

  // The banner view.
  @IBOutlet weak var bannerView: GADBannerView!
  @IBOutlet weak var privacySettingsButton: UIBarButtonItem!

  // Handle changes to user consent.
  @IBAction func privacySettingsTapped(_ sender: UIBarButtonItem) {
    GoogleMobileAdsConsentManager.shared.presentPrivacyOptionsForm(from: self) {
      [weak self] formError in
      guard let self, let formError else { return }

      let alertController = UIAlertController(
        title: formError.localizedDescription, message: "Please try again later.",
        preferredStyle: .alert)
      alertController.addAction(UIAlertAction(title: "OK", style: .cancel))
      self.present(alertController, animated: true)
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
    bannerView.rootViewController = self
    bannerView.delegate = self

    GoogleMobileAdsConsentManager.shared.gatherConsent(from: self) { [weak self] consentError in
      guard let self else { return }

      if let consentError {
        // Consent gathering failed.
        print("Error: \(consentError.localizedDescription)")
      }

      if GoogleMobileAdsConsentManager.shared.canRequestAds {
        _ = self.startGoogleMobileAdsSDK
      }

      self.privacySettingsButton.isEnabled =
        GoogleMobileAdsConsentManager.shared.isPrivacyOptionsRequired
    }

    // This sample attempts to load ads using consent obtained in the previous session.
    if GoogleMobileAdsConsentManager.shared.canRequestAds {
      _ = startGoogleMobileAdsSDK
    }
  }

  // The lazy property is used instead of unavailable `dispatch_once` to
  // initialize the Google Mobile Ads SDK only once."
  private lazy var startGoogleMobileAdsSDK: Void = {
    // Initialize the Google Mobile Ads SDK.
    GADMobileAds.sharedInstance().start()

    // Request an ad.
    self.bannerView.load(GADRequest())
  }()
}

// MARK: - GADBannerViewDelegate methods
extension ViewController {
  func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
    print("Ad loaded.")
  }

  func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
    print("Failed to load ad with error: \(error)")
  }
}
