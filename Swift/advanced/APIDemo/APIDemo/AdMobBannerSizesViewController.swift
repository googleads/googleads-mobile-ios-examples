//
//  Copyright (C) 2016 Google, Inc.
//
//  AdMobBannerSizesViewController.swift
//  APIDemo
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
class AdMobBannerSizesViewController: UIViewController, UIPickerViewDelegate,
    UIPickerViewDataSource {

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

    self.bannerSizesPicker.delegate = self
    self.bannerSizesPicker.dataSource = self

    switch UIDevice.currentDevice().userInterfaceIdiom {
    case .Phone, .Unspecified:
      self.bannerSizes = ["Large Banner", "Banner", "Smart Banner"]
      self.bannerSizesPicker.selectRow(1, inComponent: 0, animated: false)
    case .Pad:
      self.bannerSizes = [
        "Smart Banner",
        "Large Banner",
        "Banner",
        "Full Banner",
        "Medium Rectangle",
        "Leaderboard"
      ]
      self.bannerSizesPicker.selectRow(2, inComponent: 0, animated: false)
    default:
      break
    }

    self.ads = [
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
    return self.bannerSizes.count
  }

  // MARK: - UIPickerViewDelegate

  func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int)
      -> String? {
    return self.bannerSizes[row]
  }

  // MARK: - Actions

  @IBAction func loadAd(sender: AnyObject) {
    if self.bannerView == nil {
      self.bannerView = GADBannerView()
      self.bannerView.adUnitID = Constants.AdMobAdUnitID
      self.bannerView.rootViewController = self

      self.view.addSubview(self.bannerView)
      self.bannerView.translatesAutoresizingMaskIntoConstraints = false

      // Layout constraints that align the banner view to the bottom center of the screen.
      self.view.addConstraint(NSLayoutConstraint(item: self.bannerView, attribute: .Bottom,
          relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1, constant: 0))
      self.view.addConstraint(NSLayoutConstraint(item: self.bannerView, attribute: .CenterX,
          relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0))
    }

    var bannerSizeString = self.bannerSizes[self.bannerSizesPicker.selectedRowInComponent(0)]

    if bannerSizeString == "Smart Banner" {
      if UIDevice.currentDevice().orientation == .Portrait {
        bannerSizeString = "Smart Banner Portrait"
      } else {
        bannerSizeString = "Smart Banner Landscape"
      }
    }

    self.bannerView.adSize = self.ads[bannerSizeString]!
    self.bannerView.loadRequest(GADRequest())
  }

}
