//
//  Copyright (C) 2016 Google, Inc.
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

/// DFP - Multiple Ad Sizes
/// Demonstrates setting valid ad sizes for a DFPRequest.
class DFPMultipleAdSizesViewController: UIViewController, GADAdSizeDelegate {

  /// The custom banner size (120x20) switch.
  @IBOutlet weak var GADAdSizeCustomBannerSwitch: UISwitch!

  /// The banner size (320x50) switch.
  @IBOutlet weak var GADAdSizeBannerSwitch: UISwitch!

  /// The medium rectangle size (300x250) switch.
  @IBOutlet weak var GADAdSizeMediumRectangleSwitch: UISwitch!

  /// The DFP banner view.
  var bannerView: DFPBannerView!

  override func viewDidLoad() {
    super.viewDidLoad()
    bannerView = DFPBannerView(adSize: kGADAdSizeBanner)
    bannerView.adUnitID = Constants.DFPAdSizesAdUnitID
    bannerView.rootViewController = self
    bannerView.adSizeDelegate = self

    view.addSubview(bannerView)
    bannerView.translatesAutoresizingMaskIntoConstraints = false

    // Layout constraints that align the banner view to the bottom center of the screen.
    view.addConstraint(NSLayoutConstraint(item: bannerView, attribute: .Bottom, relatedBy: .Equal,
        toItem: view, attribute: .Bottom, multiplier: 1, constant: 0))
    view.addConstraint(NSLayoutConstraint(item: bannerView, attribute: .CenterX, relatedBy: .Equal,
        toItem: view, attribute: .CenterX, multiplier: 1, constant: 0))
  }

  // MARK: - Actions

  /// Loads an ad.
  @IBAction func loadAd(sender: AnyObject) {
    guard GADAdSizeCustomBannerSwitch.on || GADAdSizeBannerSwitch.on ||
        GADAdSizeMediumRectangleSwitch.on else {
      let alert = UIAlertView(title: "Load Ad Error",
          message: "Failed to load ad. Please select at least one ad size.",
          delegate: self,
          cancelButtonTitle: "OK")
      alert.alertViewStyle = .Default
      alert.show()
      return
    }

    var adSizes = [NSValue]()
    if GADAdSizeCustomBannerSwitch.on {
      let customGADAdSize = GADAdSizeFromCGSize(CGSizeMake(120, 20))
      adSizes.append(NSValueFromGADAdSize(customGADAdSize))
    }
    if GADAdSizeBannerSwitch.on {
      adSizes.append(NSValueFromGADAdSize(kGADAdSizeBanner))
    }
    if GADAdSizeMediumRectangleSwitch.on {
      adSizes.append(NSValueFromGADAdSize(kGADAdSizeMediumRectangle))
    }

    bannerView.validAdSizes = adSizes
    bannerView.loadRequest(DFPRequest())
  }

  // MARK: - GADAdSizeDelegate

  /// Called before the ad view changes to the new size.
  func adView(bannerView: GADBannerView!, willChangeAdSizeTo size: GADAdSize) {
    // The bannerView calls this method on its adSizeDelegate object before the banner updates its
    // size, allowing the application to adjust any views that may be affected by the new ad size.
    print("Make your app layout changes here, if necessary. New banner ad size will be \(size).")
  }

}
