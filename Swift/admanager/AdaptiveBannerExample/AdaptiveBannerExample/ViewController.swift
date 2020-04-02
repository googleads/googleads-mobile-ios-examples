//
//  Copyright (C) 2019 Google, Inc.
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
  @IBOutlet weak var bannerView: DFPBannerView!
  @IBOutlet weak var iuSwitch: UISwitch!
  @IBOutlet weak var iuLabel: UILabel!

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
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }

  override func viewWillTransition(
    to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator
  ) {
    coordinator.animate(alongsideTransition: { _ in
      self.loadBannerAd(nil)
    })
  }

  @IBAction func adUnitIDSwitchChanged(_ sender: Any) {
    updateLabel()
  }

  func updateLabel() {
    iuLabel.text = adUnitLabel
  }

  @IBAction func loadBannerAd(_ sender: Any?) {
    let frame = { () -> CGRect in
      if #available(iOS 11.0, *) {
        return view.frame.inset(by: view.safeAreaInsets)
      } else {
        return view.frame
      }
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
    bannerView.load(DFPRequest())
  }

}
