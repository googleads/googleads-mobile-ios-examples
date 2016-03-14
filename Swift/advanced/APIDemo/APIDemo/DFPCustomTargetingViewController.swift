//
//  Copyright (C) 2016 Google, Inc.
//
//  DFPCustomTargetingViewController.swift
//  APIDemo
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

/// DFP - Custom Targeting
/// Demonstrates adding custom targeting information to a DFPRequest.
class DFPCustomTargetingViewController: UIViewController, UIPickerViewDelegate,
    UIPickerViewDataSource {

  /// The constant for the customTargeting dictionary sport preference key.
  let sportPreferenceKey = "sportpref";

  /// The DFP banner view.
  @IBOutlet weak var bannerView: DFPBannerView!

  /// The favorite sports view picker.
  @IBOutlet weak var favoriteSportsPicker: UIPickerView!

  /// The favorite sports options.
  var favoriteSportsOptions: [String]!

  override func viewDidLoad() {
    super.viewDidLoad()
    self.bannerView.adUnitID = Constants.DFPCustomTargetingAdUnitID
    self.bannerView.rootViewController = self
    self.favoriteSportsPicker.delegate = self
    self.favoriteSportsPicker.dataSource = self
    self.favoriteSportsOptions = [
        "Baseball", "Basketball", "Bobsled", "Football", "Ice Hockey",
        "Running", "Skiing", "Snowboarding", "Softball"
    ]
    let favoriteSportsPickerMiddleRow = self.favoriteSportsOptions.count / 2
    self.favoriteSportsPicker.selectRow(favoriteSportsPickerMiddleRow, inComponent: 0,
        animated: false)
  }

  // MARK: - UIPickerViewDelegate

  func pickerView(pickerView: UIPickerView, titleForRow row: Int,
      forComponent component: Int) -> String? {
    return self.favoriteSportsOptions[row]
  }

  // MARK: - UIPickerViewDataSource

  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return 1
  }

  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return self.favoriteSportsOptions.count
  }

  // MARK: - Actions

  @IBAction func loadAd(sender: AnyObject) {
    let row = self.favoriteSportsPicker.selectedRowInComponent(0)
    let request = DFPRequest()
    request.customTargeting = [sportPreferenceKey: self.favoriteSportsOptions[row]]
    self.bannerView.loadRequest(request)
  }

}
