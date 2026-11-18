//
//  Copyright 2026 Google LLC
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
import XCTest

final class AdMobAdTargetingTableViewControllerTests: XCTestCase {

  private var previousTreatment: AgeRestrictedTreatment = .unspecified
  private var sut: AdMobAdTargetingTableViewController!
  private var ageRestrictedLabel: UILabel!
  private var ageRestrictedPicker: UIPickerView!
  private var bannerView: BannerView!

  override func setUp() {
    super.setUp()
    previousTreatment = MobileAds.shared.requestConfiguration.ageRestrictedTreatment

    sut = AdMobAdTargetingTableViewController(style: .grouped)
    ageRestrictedLabel = UILabel()
    ageRestrictedPicker = UIPickerView()
    bannerView = BannerView()

    sut.ageRestrictedLabel = ageRestrictedLabel
    sut.ageRestrictedPicker = ageRestrictedPicker
    sut.bannerView = bannerView
  }

  override func tearDown() {
    MobileAds.shared.requestConfiguration.ageRestrictedTreatment = previousTreatment
    sut = nil
    ageRestrictedLabel = nil
    ageRestrictedPicker = nil
    bannerView = nil
    super.tearDown()
  }

  // MARK: - AgeRestrictedOption

  func testAgeRestrictedOption_allCases_matchExpectedOrderAndTitles() {
    XCTAssertEqual(
      AgeRestrictedOption.allCases.map(\.rawValue),
      ["Child", "Teen", "Unspecified"]
    )
  }

  func testAgeRestrictedOption_treatment_mapsAllCases() {
    XCTAssertEqual(AgeRestrictedOption.child.treatment, .child)
    XCTAssertEqual(AgeRestrictedOption.teen.treatment, .teen)
    XCTAssertEqual(AgeRestrictedOption.unspecified.treatment, .unspecified)
  }

  func testAgeRestrictedOption_initWithDisplayTitle_parsesValidAndDefaultsInvalid() {
    XCTAssertEqual(AgeRestrictedOption(displayTitle: "Child"), .child)
    XCTAssertEqual(AgeRestrictedOption(displayTitle: "Teen"), .teen)
    XCTAssertEqual(AgeRestrictedOption(displayTitle: "Unspecified"), .unspecified)
    XCTAssertEqual(AgeRestrictedOption(displayTitle: nil), .unspecified)
    XCTAssertEqual(AgeRestrictedOption(displayTitle: ""), .unspecified)
    XCTAssertEqual(AgeRestrictedOption(displayTitle: "Adult"), .unspecified)
  }

  // MARK: - Lifecycle

  func testViewDidLoad_configuresBannerViewAndInitialPickerState() {
    sut.loadViewIfNeeded()

    XCTAssertEqual(bannerView.adUnitID, Constants.adMobAdUnitID)
    XCTAssertTrue(bannerView.rootViewController === sut)
    XCTAssertTrue(bannerView.delegate === sut)
    XCTAssertTrue(ageRestrictedPicker.delegate === sut)
    XCTAssertTrue(ageRestrictedPicker.dataSource === sut)
    XCTAssertEqual(ageRestrictedLabel.text, "Child")
  }

  // MARK: - UIPickerViewDataSource & UIPickerViewDelegate

  func testNumberOfComponents_returnsOne() {
    XCTAssertEqual(sut.numberOfComponents(in: ageRestrictedPicker), 1)
  }

  func testNumberOfRowsInComponent_returnsOptionCountForAgeRestrictedPicker() {
    XCTAssertEqual(
      sut.pickerView(ageRestrictedPicker, numberOfRowsInComponent: 0),
      AgeRestrictedOption.allCases.count
    )
  }

  func testNumberOfRowsInComponent_returnsZeroForUnrecognizedPicker() {
    let otherPicker = UIPickerView()
    XCTAssertEqual(sut.pickerView(otherPicker, numberOfRowsInComponent: 0), 0)
  }

  func testPickerTitleForRow_returnsExpectedTitlesAndEmptyForOutOfBoundsOrOtherPicker() {
    XCTAssertEqual(
      sut.pickerView(ageRestrictedPicker, titleForRow: 0, forComponent: 0),
      "Child"
    )
    XCTAssertEqual(
      sut.pickerView(ageRestrictedPicker, titleForRow: 1, forComponent: 0),
      "Teen"
    )
    XCTAssertEqual(
      sut.pickerView(ageRestrictedPicker, titleForRow: 2, forComponent: 0),
      "Unspecified"
    )
    XCTAssertEqual(
      sut.pickerView(ageRestrictedPicker, titleForRow: -1, forComponent: 0),
      ""
    )
    XCTAssertEqual(
      sut.pickerView(ageRestrictedPicker, titleForRow: 99, forComponent: 0),
      ""
    )

    let otherPicker = UIPickerView()
    XCTAssertEqual(sut.pickerView(otherPicker, titleForRow: 0, forComponent: 0), "")
  }

  func testPickerDidSelectRow_updatesAgeRestrictedLabel() {
    sut.pickerView(ageRestrictedPicker, didSelectRow: 1, inComponent: 0)
    XCTAssertEqual(ageRestrictedLabel.text, "Teen")

    sut.pickerView(ageRestrictedPicker, didSelectRow: 2, inComponent: 0)
    XCTAssertEqual(ageRestrictedLabel.text, "Unspecified")
  }

  func testPickerDidSelectRow_ignoresOutOfBoundsAndUnrecognizedPicker() {
    ageRestrictedLabel.text = "Child"

    sut.pickerView(ageRestrictedPicker, didSelectRow: -1, inComponent: 0)
    XCTAssertEqual(ageRestrictedLabel.text, "Child")

    sut.pickerView(ageRestrictedPicker, didSelectRow: 10, inComponent: 0)
    XCTAssertEqual(ageRestrictedLabel.text, "Child")

    let otherPicker = UIPickerView()
    sut.pickerView(otherPicker, didSelectRow: 1, inComponent: 0)
    XCTAssertEqual(ageRestrictedLabel.text, "Child")
  }

  // MARK: - Actions

  func testLoadTargetedAd_withChildLabel_setsChildTreatment() {
    ageRestrictedLabel.text = "Child"

    sut.loadTargetedAd(self)

    XCTAssertEqual(MobileAds.shared.requestConfiguration.ageRestrictedTreatment, .child)
  }

  func testLoadTargetedAd_withTeenLabel_setsTeenTreatment() {
    ageRestrictedLabel.text = "Teen"

    sut.loadTargetedAd(self)

    XCTAssertEqual(MobileAds.shared.requestConfiguration.ageRestrictedTreatment, .teen)
  }

  func testLoadTargetedAd_withUnspecifiedOrNilLabel_setsUnspecifiedTreatment() {
    ageRestrictedLabel.text = "Unspecified"
    sut.loadTargetedAd(self)
    XCTAssertEqual(MobileAds.shared.requestConfiguration.ageRestrictedTreatment, .unspecified)

    ageRestrictedLabel.text = nil
    sut.loadTargetedAd(self)
    XCTAssertEqual(MobileAds.shared.requestConfiguration.ageRestrictedTreatment, .unspecified)
  }

  // MARK: - UITableViewDelegate & UITableViewDataSource

  func testDidSelectRow_togglesAgeRestrictedPickerVisibility() {
    let tableView = StubTableView(
      cellsByIndexPath: [
        IndexPath(row: 0, section: 0): UITableViewCell(
          style: .default,
          reuseIdentifier: AdMobAdTargetingTableCellIdentifier.ageRestrictedCell.rawValue
        )
      ]
    )
    ageRestrictedPicker.isHidden = true

    sut.tableView(tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
    XCTAssertFalse(ageRestrictedPicker.isHidden)

    sut.tableView(tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
    XCTAssertTrue(ageRestrictedPicker.isHidden)
  }

  func testDidSelectRow_ignoresUnrecognizedCell() {
    let tableView = StubTableView(
      cellsByIndexPath: [
        IndexPath(row: 0, section: 0): UITableViewCell(
          style: .default,
          reuseIdentifier: "otherCell"
        )
      ]
    )
    ageRestrictedPicker.isHidden = false

    sut.tableView(tableView, didSelectRowAt: IndexPath(row: 0, section: 0))

    XCTAssertFalse(ageRestrictedPicker.isHidden)
  }

  func testHeightForRow_returnsZeroWhenPickerCellAndPickerHidden() {
    ageRestrictedPicker.isHidden = true

    let height = sut.heightForRow(
      withCellIdentifier: AdMobAdTargetingTableCellIdentifier.ageRestrictedPickerCell.rawValue,
      defaultHeight: 216
    )

    XCTAssertEqual(height, 0)
  }

  func testHeightForRow_returnsDefaultHeightWhenPickerVisibleOrOtherCell() {
    ageRestrictedPicker.isHidden = false
    XCTAssertEqual(
      sut.heightForRow(
        withCellIdentifier: AdMobAdTargetingTableCellIdentifier.ageRestrictedPickerCell.rawValue,
        defaultHeight: 216
      ),
      216
    )

    ageRestrictedPicker.isHidden = true
    XCTAssertEqual(
      sut.heightForRow(
        withCellIdentifier: AdMobAdTargetingTableCellIdentifier.ageRestrictedCell.rawValue,
        defaultHeight: 44
      ),
      44
    )
  }
}

private final class StubTableView: UITableView {

  private let cellsByIndexPath: [IndexPath: UITableViewCell]

  init(cellsByIndexPath: [IndexPath: UITableViewCell]) {
    self.cellsByIndexPath = cellsByIndexPath
    super.init(frame: .zero, style: .plain)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func cellForRow(at indexPath: IndexPath) -> UITableViewCell? {
    return cellsByIndexPath[indexPath]
  }
}
