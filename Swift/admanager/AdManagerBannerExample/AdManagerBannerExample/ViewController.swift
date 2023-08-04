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

  /// The AdManager banner view.
  @IBOutlet weak var bannerView: GAMBannerView!
  @IBOutlet weak var privacySettingsButton: UIBarButtonItem!

  private var isMobileAdsStartCalled = false

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
    bannerView.adUnitID = "/6499/example/banner"
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

  private func startGoogleMobileAdsSDK() {
    DispatchQueue.main.async {
      guard !self.isMobileAdsStartCalled else { return }

      self.isMobileAdsStartCalled = true

      // Initialize the Google Mobile Ads SDK.
      GADMobileAds.sharedInstance().start()
      // Request an ad.
      self.bannerView.load(GAMRequest())
    }
  }

  func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
    print("bannerViewDidReceiveAd")
  }

  func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
    print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
  }

  func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
    print("bannerViewDidRecordImpression")
  }

  func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
    print("bannerViewWillPresentScreen")
  }

  func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
    print("bannerViewWillDIsmissScreen")
  }

  func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
    print("bannerViewDidDismissScreen")
  }
}
