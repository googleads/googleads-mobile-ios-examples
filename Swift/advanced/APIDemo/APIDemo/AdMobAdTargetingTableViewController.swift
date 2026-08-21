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

/// The constants for AdMobAdTargeting table cell identifiers.
struct AdMobAdTargetingTableCellIdentifiers {
  static let ageRestrictedCell = "ageRestrictedCell"
  static let ageRestrictedPickerCell = "ageRestrictedPickerCell"
}

/// AdMob - Ad Targeting
/// Demonstrates AdMob ad targeting.
class AdMobAdTargetingTableViewController: UITableViewController, UIPickerViewDataSource,
  UIPickerViewDelegate
{

  /// The age-restricted treatment label.
  @IBOutlet weak var ageRestrictedLabel: UILabel!

  /// The age-restricted treatment picker.
  @IBOutlet weak var ageRestrictedPicker: UIPickerView!

  /// The banner view.
  @IBOutlet weak var bannerView: BannerView!

  /// The age-restricted treatment options.
  var ageRestrictedOptions: [String]!

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.tableFooterView = UIView(frame: CGRect.zero)

    // GADBannerView setup.
    bannerView.adUnitID = Constants.adMobAdUnitID
    bannerView.rootViewController = self
    bannerView.delegate = self

    // Age-restricted setup.
    ageRestrictedOptions = ["Child", "Teen", "Unspecified"]
    ageRestrictedPicker.delegate = self
    ageRestrictedPicker.dataSource = self
    ageRestrictedPicker.selectRow(
      0, inComponent: 0,
      animated: false)
    ageRestrictedLabel.text = ageRestrictedOptions[0]
  }

  // MARK: - UITableViewDelegate

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let cell = tableView.cellForRow(at: indexPath)
    var currentPicker: UIView?
    if let cellIdentifier = cell?.reuseIdentifier {
      switch cellIdentifier {
      case AdMobAdTargetingTableCellIdentifiers.ageRestrictedCell:
        currentPicker = ageRestrictedPicker
      default:
        break
      }
    }
    if let isPickerHidden = currentPicker?.isHidden {
      hideAllPickers()
      currentPicker?.isHidden = !isPickerHidden
      tableView.reloadData()
      tableView.deselectRow(at: indexPath, animated: true)
    }
  }

  override func tableView(
    _ tableView: UITableView, willDisplayHeaderView view: UIView,
    forSection section: Int
  ) {
    view.tintColor = UIColor.clear
  }

  // MARK: - UITableViewDataSource

  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath)
    -> CGFloat
  {
    let cell = self.tableView(tableView, cellForRowAt: indexPath)
    if let cellIdentifier = cell.reuseIdentifier {
      if cellIdentifier == AdMobAdTargetingTableCellIdentifiers.ageRestrictedPickerCell
        && ageRestrictedPicker.isHidden
      {
        return 0
      }
    }
    return super.tableView(tableView, heightForRowAt: indexPath)
  }

  // MARK: - UIPickerViewDelegate

  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int)
    -> String?
  {
    var rowTitle = ""
    switch pickerView {
    case ageRestrictedPicker:
      rowTitle = ageRestrictedOptions[row]
    default:
      rowTitle = ""
    }
    return rowTitle
  }

  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    switch pickerView {
    case ageRestrictedPicker:
      ageRestrictedLabel.text = ageRestrictedOptions[row]
    default:
      break
    }
  }

  // MARK: - UIPickerViewDataSource

  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }

  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    var numOfRows = 0
    switch pickerView {
    case ageRestrictedPicker:
      numOfRows = ageRestrictedOptions.count
    default:
      numOfRows = 0
    }
    return numOfRows
  }

  // MARK: - Actions

  /// Loads an ad based on age-restricted treatment.
  @IBAction func loadTargetedAd(_ sender: AnyObject) {
    let request = Request()
    switch ageRestrictedLabel.text {
    case "Child":
      MobileAds.shared.requestConfiguration.ageRestrictedTreatment = .child
    case "Teen":
      MobileAds.shared.requestConfiguration.ageRestrictedTreatment = .teen
    default:
      MobileAds.shared.requestConfiguration.ageRestrictedTreatment = .unspecified
    }
    bannerView.load(request)
  }

  fileprivate func hideAllPickers() {
    ageRestrictedPicker.isHidden = true
  }

}

extension AdMobAdTargetingTableViewController: BannerViewDelegate {

  func bannerViewDidReceiveAd(_ bannerView: BannerView) {
    print("\(#function)")
  }

  func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
    print("\(#function): \(error.localizedDescription)")
  }
}
