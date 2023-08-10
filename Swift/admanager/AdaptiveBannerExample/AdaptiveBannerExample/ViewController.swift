//
//  Copyright (C) 2019 Google LLC
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

let reservationAdUnitID = "/30497360/adaptive_banner_test_iu/reservation"
let backfillAdUnitID = "/30497360/adaptive_banner_test_iu/backfill"

class ViewController: UIViewController {
  @IBOutlet weak var bannerView: GAMBannerView!
  @IBOutlet weak var privacySettingsButton: UIBarButtonItem!
  @IBOutlet weak var loadAdButton: UIButton!
  @IBOutlet weak var iuSwitch: UISwitch!
  @IBOutlet weak var iuLabel: UILabel!

  private var isMobileAdsStartCalled = false

  var adUnitID: String {
    return iuSwitch.isOn ? reservationAdUnitID : backfillAdUnitID
  }

  var adUnitLabel: String {
    return adUnitID == reservationAdUnitID ? "Reservation Ad Unit" : "Backfill Ad Unit"
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    bannerView.rootViewController = self
    bannerView.backgroundColor = UIColor.gray
    updateLabel()

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
      self.loadBannerAd(nil)
    })
  }

  private func startGoogleMobileAdsSDK() {
    DispatchQueue.main.async {
      guard !self.isMobileAdsStartCalled else { return }

      self.isMobileAdsStartCalled = true

      // Initialize the Google Mobile Ads SDK.
      GADMobileAds.sharedInstance().start()
      self.loadAdButton.isEnabled = true
    }
  }

  func updateLabel() {
    iuLabel.text = adUnitLabel
  }

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

  @IBAction func adUnitIDSwitchChanged(_ sender: Any) {
    updateLabel()
  }

  @IBAction func loadBannerAd(_ sender: Any?) {
    let frame = { () -> CGRect in
      return view.frame.inset(by: view.safeAreaInsets)
    }()
    let viewWidth = frame.size.width

    // Replace this ad unit ID with your own ad unit ID.
    bannerView.adUnitID = adUnitID

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

}
