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

import CoreLocation
import GoogleMobileAds
import UIKit

/// The constants for AdMobAdTargeting table cell identifiers.
struct AdMobAdTargetingTableCellIdentifiers {
  static let BirthdateCell = "birthdateCell"
  static let BirthdatePickerCell = "birthdatePickerCell"
  static let GenderCell = "genderCell"
  static let GenderPickerCell = "genderPickerCell"
  static let ChildDirectedCell = "childDirectedCell"
  static let ChildDirectedPickerCell = "childDirectedPickerCell"
}

/// AdMob - Ad Targeting
/// Demonstrates AdMob ad targeting.
class AdMobAdTargetingTableViewController: UITableViewController, CLLocationManagerDelegate,
    UIPickerViewDataSource, UIPickerViewDelegate {

  /// The current location label.
  @IBOutlet weak var locationLabel: UILabel!

  /// The birthdate label.
  @IBOutlet weak var birthdateLabel: UILabel!

  /// The gender label.
  @IBOutlet weak var genderLabel: UILabel!

  /// The child-directed label.
  @IBOutlet weak var childDirectedLabel: UILabel!

  /// The birthdate picker.
  @IBOutlet weak var birthdatePicker: UIDatePicker!

  /// The gender picker.
  @IBOutlet weak var genderPicker: UIPickerView!

  /// The child-directed picker.
  @IBOutlet weak var childDirectedPicker: UIPickerView!

  /// The banner view.
  @IBOutlet weak var bannerView: GADBannerView!

  /// The location manager.
  let locationManager = CLLocationManager()

  /// The birthdate formatter, ex: Jan 31, 1980.
  let dateFormatter = NSDateFormatter()

  /// The gender options.
  var genderOptions: [String]!

  /// The child-directed options.
  var childDirectedOptions: [String]!

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.tableFooterView = UIView(frame: CGRectZero)
    dateFormatter.dateStyle = .MediumStyle

    // GADBannerView setup.
    bannerView.adUnitID = Constants.AdMobAdUnitID
    bannerView.rootViewController = self

    // Gender setup.
    genderOptions = ["Male", "Female", "Unknown"]
    genderPicker.delegate = self
    genderPicker.dataSource = self
    let genderPickerMiddleRow = genderOptions.count / 2
    genderPicker.selectRow(genderPickerMiddleRow, inComponent: 0, animated: false)

    // Child-directed setup.
    childDirectedOptions = ["Yes", "No", "Unspecified"]
    childDirectedPicker.delegate = self
    childDirectedPicker.dataSource = self
    let childDirectedPickerMiddleRow = childDirectedOptions.count / 2
    childDirectedPicker.selectRow(childDirectedPickerMiddleRow, inComponent: 0,
        animated: false)

    // CLLocationManager setup.
    locationManager.delegate = self
    locationManager.distanceFilter = kCLDistanceFilterNone
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    if #available(iOS 8.0, *) {
      locationManager.requestWhenInUseAuthorization()
    }
    locationManager.startUpdatingLocation()
  }

  // MARK: - UITableViewDelegate

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let cell = tableView.cellForRowAtIndexPath(indexPath)
    var currentPicker: UIView?
    if let cellIdentifier = cell?.reuseIdentifier {
      switch cellIdentifier {
      case AdMobAdTargetingTableCellIdentifiers.BirthdateCell:
        currentPicker = birthdatePicker
      case AdMobAdTargetingTableCellIdentifiers.GenderCell:
        currentPicker = genderPicker
      case AdMobAdTargetingTableCellIdentifiers.ChildDirectedCell:
        currentPicker = childDirectedPicker
      default:
        break
      }
    }
    if let isPickerHidden = currentPicker?.hidden {
      hideAllPickers()
      currentPicker?.hidden = !isPickerHidden
      tableView.reloadData()
      tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
  }

  override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView,
      forSection section: Int) {
    view.tintColor = UIColor.clearColor()
  }

  // MARK: - UITableViewDataSource

  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath)
      -> CGFloat {
    let cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath)
    if let cellIdentifier = cell.reuseIdentifier {
      if cellIdentifier == AdMobAdTargetingTableCellIdentifiers.BirthdatePickerCell &&
          birthdatePicker.hidden {
        return 0
      } else if cellIdentifier == AdMobAdTargetingTableCellIdentifiers.GenderPickerCell &&
          genderPicker.hidden {
        return 0
      } else if cellIdentifier == AdMobAdTargetingTableCellIdentifiers.ChildDirectedPickerCell &&
          childDirectedPicker.hidden {
        return 0
      }
    }
    return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
  }

  // MARK: - UIPickerViewDelegate

  func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int)
      -> String? {
    var rowTitle = ""
    switch pickerView {
    case genderPicker:
      rowTitle = genderOptions[row]
    case childDirectedPicker:
      rowTitle = childDirectedOptions[row]
    default:
      rowTitle = ""
    }
    return rowTitle
  }

  func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    switch pickerView {
    case genderPicker:
      genderLabel.text = genderOptions[row]
    case childDirectedPicker:
      childDirectedLabel.text = childDirectedOptions[row]
    default:
      break
    }
  }

  // MARK: - UIPickerViewDataSource

  // Returns the number of columns to display.
  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return 1
  }

  // Returns the number of rows in each component.
  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    var numOfRows = 0
    switch pickerView {
    case genderPicker:
      numOfRows = genderOptions.count
    case childDirectedPicker:
      numOfRows = childDirectedOptions.count
    default:
      numOfRows = 0
    }
    return numOfRows
  }

  // MARK: - CLLocationManagerDelegate

  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let currentLocation = locations.last {
      let latitude = CGFloat(round(1000 * currentLocation.coordinate.latitude) / 1000)
      let longitude = CGFloat(round(1000 * currentLocation.coordinate.longitude) / 1000)
      locationLabel.text = "\(latitude), \(longitude)"
    }
  }

  func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
    print("\(#function): \(error.localizedDescription)")
  }

  // MARK: - Actions

  // Loads an ad based on user's location, birthdate, gender and child-directed status.
  @IBAction func loadTargetedAd(sender: AnyObject) {
    let request = GADRequest()
    if let currentLocation = locationManager.location {
      let latitude = CGFloat(currentLocation.coordinate.latitude)
      let longitude = CGFloat(currentLocation.coordinate.longitude)
      request.setLocationWithLatitude(latitude, longitude: longitude,
          accuracy: CGFloat(kCLLocationAccuracyBest))
    }
    if birthdateLabel.text != "Birthdate" {
      request.birthday = birthdatePicker.date
    }
    if childDirectedLabel.text == "Yes" {
      request.tagForChildDirectedTreatment(true)
    } else if childDirectedLabel.text == "No" {
      request.tagForChildDirectedTreatment(false)
    }
    switch genderLabel.text! {
    case "Male":
      request.gender = .Male
    case "Female":
      request.gender = .Female
    default:
      request.gender = .Unknown
    }
    bannerView.loadRequest(request)
  }

  // Sets the birthdate label to birthdate selected in picker.
  @IBAction func chooseBirthdate(sender: AnyObject) {
    birthdateLabel.text = dateFormatter.stringFromDate(birthdatePicker.date)
  }

  private func hideAllPickers() {
    birthdatePicker.hidden = true
    genderPicker.hidden = true
    childDirectedPicker.hidden = true
  }

}
