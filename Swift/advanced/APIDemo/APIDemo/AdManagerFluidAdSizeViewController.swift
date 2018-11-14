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

/// AdManager - Fluid Ad Size
/// Demonstrates using the Fluid ad size - an ad size that spans the full width of its container,
/// with a height dynamically determined by the ad.
class AdManagerFluidAdSizeViewController: UIViewController {

  /// The DFP banner view.
  @IBOutlet weak var bannerView: DFPBannerView!

  /// The banner view's width constraint.
  @IBOutlet weak var bannerViewWidthConstraint: NSLayoutConstraint!

  /// Current banner width.
  @IBOutlet weak var bannerWidthLabel: UILabel!

  /// An array of banner widths.
  let bannerWidths: [CGFloat] = [200, 250, 320]

  /// Current array index.
  var currentIndex = 0

  override func viewDidLoad() {
    super.viewDidLoad()
    bannerView.adUnitID = Constants.AdManagerFluidAdSizeAdUnitID
    bannerView.rootViewController = self
    bannerView.adSize = kGADAdSizeFluid
    bannerView.load(DFPRequest())
  }

  /// Handles the user tapping on the "Change Banner Width" button.
  @IBAction func changeBannerWidth(_ sender: Any) {
    let newWidth = bannerWidths[currentIndex % bannerWidths.count]
    currentIndex += 1
    bannerViewWidthConstraint.constant = newWidth
    bannerWidthLabel.text = "\(String(format: "%.0f", newWidth)) points"
  }

}
