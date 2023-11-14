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

class AdManagerCategoryExclusionsTableViewController: UITableViewController {

  /// The no exclusions banner view.
  @IBOutlet weak var noExclusionsBannerView: GAMBannerView!

  /// The exclude dogs banner view.
  @IBOutlet weak var excludeDogsBannerView: GAMBannerView!

  /// The exclude cats banner view.
  @IBOutlet weak var excludeCatsBannerView: GAMBannerView!

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.tableFooterView = UIView(frame: CGRect.zero)

    noExclusionsBannerView.adUnitID = Constants.adManagerCategoryExclusionsAdUnitID
    noExclusionsBannerView.rootViewController = self
    let noExclusionsRequest = GAMRequest()
    noExclusionsBannerView.load(noExclusionsRequest)

    excludeDogsBannerView.adUnitID = Constants.adManagerCategoryExclusionsAdUnitID
    excludeDogsBannerView.rootViewController = self
    let excludeDogsRequest = GAMRequest()
    excludeDogsRequest.categoryExclusions = [Constants.categoryExclusionDogs]
    excludeDogsBannerView.load(excludeDogsRequest)

    excludeCatsBannerView.adUnitID = Constants.adManagerCategoryExclusionsAdUnitID
    excludeCatsBannerView.rootViewController = self
    let excludeCatsRequest = GAMRequest()
    excludeCatsRequest.categoryExclusions = [Constants.categoryExclusionCats]
    excludeCatsBannerView.load(excludeCatsRequest)
  }

  // MARK: - Table View

  override func tableView(
    _ tableView: UITableView, willDisplayHeaderView view: UIView,
    forSection section: Int
  ) {
    view.tintColor = UIColor.clear
  }

}
