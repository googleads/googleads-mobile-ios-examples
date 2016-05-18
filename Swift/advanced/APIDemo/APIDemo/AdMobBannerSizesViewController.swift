//
//  Copyright (C) 2016 Google, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License")
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

/// AdMob - Banner Sizes
/// Demonstrates setting a desired banner size prior to loading an ad.
class AdMobBannerSizesViewController: UIViewController, UIPickerViewDataSource,
    UIPickerViewDelegate {

  /// The banner sizes picker.
  @IBOutlet weak var bannerSizesPicker: UIPickerView!

  /// The banner sizes.
  var bannerSizes: [String]!

  /// The banner sizes mapped to GADAdSize constants.
  var ads: [String: GADAdSize]!

  /// The banner view.
  var bannerView: GADBannerView!

  override func viewDidLoad() {
    super.viewDidLoad()

    bannerSizesPicker.delegate = self
    bannerSizesPicker.dataSource = self

    switch UIDevice.currentDevice().userInterfaceIdiom {
    case .Phone, .Unspecified:
      bannerSizes = ["Large Banner", "Banner", "Smart Banner"]
      bannerSizesPicker.selectRow(1, inComponent: 0, animated: false)
    case .Pad:
      bannerSizes = [
        "Smart Banner",
        "Large Banner",
        "Banner",
        "Full Banner",
        "Medium Rectangle",
        "Leaderboard"
      ]
      bannerSizesPicker.selectRow(2, inComponent: 0, animated: false)
    default:
      break
    }

    ads = [
      "Banner": kGADAdSizeBanner,
      "Large Banner": kGADAdSizeLargeBanner,
      "Smart Banner Portrait": kGADAdSizeSmartBannerPortrait,
      "Smart Banner Landscape": kGADAdSizeSmartBannerLandscape,
      "Full Banner": kGADAdSizeFullBanner,
      "Medium Rectangle": kGADAdSizeMediumRectangle,
      "Leaderboard": kGADAdSizeLeaderboard
    ]
  }

  // MARK: - UIPickerViewDataSource

  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return 1
  }

  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return bannerSizes.count
  }

  // MARK: - UIPickerViewDelegate

  func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int)
      -> String? {
    return bannerSizes[row]
  }

  // MARK: - Actions

  @IBAction func loadAd(sender: AnyObject) {
    if bannerView == nil {
      bannerView = GADBannerView()
      bannerView.adUnitID = Constants.AdMobAdUnitID
      bannerView.rootViewController = self

      view.addSubview(bannerView)
      bannerView.translatesAutoresizingMaskIntoConstraints = false

      // Layout constraints that align the banner view to the bottom center of the screen.
      view.addConstraint(NSLayoutConstraint(item: bannerView, attribute: .Bottom,
          relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0))
      view.addConstraint(NSLayoutConstraint(item: bannerView, attribute: .CenterX,
          relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0))
    }

    var bannerSizeString = bannerSizes[bannerSizesPicker.selectedRowInComponent(0)]

    if bannerSizeString == "Smart Banner" {
      if UIDevice.currentDevice().orientation == .Portrait {
        bannerSizeString = "Smart Banner Portrait"
      } else {
        bannerSizeString = "Smart Banner Landscape"
      }
    }

    bannerView.adSize = ads[bannerSizeString]!
    bannerView.loadRequest(GADRequest())
  }

}
