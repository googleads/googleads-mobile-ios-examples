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

/// Reuse identifiers for cells in `AdMobAdTargetingTableViewController`.
enum AdMobAdTargetingTableCellIdentifier: String {
  case ageRestrictedCell
  case ageRestrictedPickerCell
}

/// Age-restricted treatment options displayed in the targeting picker.
enum AgeRestrictedOption: String, CaseIterable, Equatable {
  case child = "Child"
  case teen = "Teen"
  case unspecified = "Unspecified"

  /// The Mobile Ads SDK treatment value corresponding to this option.
  var treatment: AgeRestrictedTreatment {
    switch self {
    case .child:
      return .child
    case .teen:
      return .teen
    case .unspecified:
      return .unspecified
    }
  }

  /// Creates an option from a displayed label string, falling back to `.unspecified`.
  init(displayTitle: String?) {
    if let displayTitle, let option = Self(rawValue: displayTitle) {
      self = option
    } else {
      self = .unspecified
    }
  }
}

/// AdMob - Ad Targeting
/// Demonstrates AdMob ad targeting.
final class AdMobAdTargetingTableViewController: UITableViewController {

  /// The age-restricted treatment label.
  @IBOutlet weak var ageRestrictedLabel: UILabel!

  /// The age-restricted treatment picker.
  @IBOutlet weak var ageRestrictedPicker: UIPickerView!

  /// The banner view.
  @IBOutlet weak var bannerView: BannerView!

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.tableFooterView = UIView(frame: .zero)

    configureBannerView()
    configureAgeRestrictedPicker()
  }

  // MARK: - UITableViewDelegate

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard
      let cellIdentifier = tableView.cellForRow(at: indexPath)?.reuseIdentifier,
      let picker = picker(forCellIdentifier: cellIdentifier)
    else {
      return
    }
    let isPickerHidden = picker.isHidden
    hideAllPickers()
    picker.isHidden = !isPickerHidden
    tableView.reloadData()
    tableView.deselectRow(at: indexPath, animated: true)
  }

  override func tableView(
    _ tableView: UITableView, willDisplayHeaderView view: UIView,
    forSection section: Int
  ) {
    view.tintColor = .clear
  }

  // MARK: - UITableViewDataSource

  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath)
    -> CGFloat
  {
    let cell = self.tableView(tableView, cellForRowAt: indexPath)
    return heightForRow(
      withCellIdentifier: cell.reuseIdentifier,
      defaultHeight: super.tableView(tableView, heightForRowAt: indexPath)
    )
  }

  /// Returns `0` when the picker cell's picker is hidden, or `defaultHeight` otherwise.
  func heightForRow(
    withCellIdentifier identifier: String?,
    defaultHeight: @autoclosure () -> CGFloat
  ) -> CGFloat {
    if identifier == AdMobAdTargetingTableCellIdentifier.ageRestrictedPickerCell.rawValue,
      ageRestrictedPicker?.isHidden == true
    {
      return 0
    }
    return defaultHeight()
  }

  // MARK: - Actions

  /// Loads an ad based on age-restricted treatment.
  @IBAction func loadTargetedAd(_ sender: AnyObject) {
    let option = AgeRestrictedOption(displayTitle: ageRestrictedLabel?.text)
    MobileAds.shared.requestConfiguration.ageRestrictedTreatment = option.treatment
    bannerView?.load(Request())
  }

  // MARK: - Private Helpers

  private func configureBannerView() {
    bannerView?.adUnitID = Constants.adMobAdUnitID
    bannerView?.rootViewController = self
    bannerView?.delegate = self
  }

  private func configureAgeRestrictedPicker() {
    ageRestrictedPicker?.delegate = self
    ageRestrictedPicker?.dataSource = self
    ageRestrictedPicker?.selectRow(0, inComponent: 0, animated: false)
    ageRestrictedLabel?.text = AgeRestrictedOption.allCases.first?.rawValue
  }

  private func picker(forCellIdentifier identifier: String) -> UIView? {
    switch AdMobAdTargetingTableCellIdentifier(rawValue: identifier) {
    case .ageRestrictedCell:
      return ageRestrictedPicker
    case .ageRestrictedPickerCell, nil:
      return nil
    }
  }

  private func ageRestrictedOption(at row: Int) -> AgeRestrictedOption? {
    let options = AgeRestrictedOption.allCases
    guard row >= 0, let option = options.dropFirst(row).first else {
      return nil
    }
    return option
  }

  private func hideAllPickers() {
    ageRestrictedPicker?.isHidden = true
  }
}

// MARK: - UIPickerViewDataSource

extension AdMobAdTargetingTableViewController: UIPickerViewDataSource {

  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }

  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    guard pickerView == ageRestrictedPicker else { return 0 }
    return AgeRestrictedOption.allCases.count
  }
}

// MARK: - UIPickerViewDelegate

extension AdMobAdTargetingTableViewController: UIPickerViewDelegate {

  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int)
    -> String?
  {
    guard pickerView == ageRestrictedPicker else { return "" }
    return ageRestrictedOption(at: row)?.rawValue ?? ""
  }

  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    guard
      pickerView == ageRestrictedPicker,
      let option = ageRestrictedOption(at: row)
    else {
      return
    }
    ageRestrictedLabel?.text = option.rawValue
  }
}

// MARK: - BannerViewDelegate

extension AdMobAdTargetingTableViewController: BannerViewDelegate {

  func bannerViewDidReceiveAd(_ bannerView: BannerView) {
    print("\(#function)")
  }

  func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
    print("\(#function): \(error.localizedDescription)")
  }
}
