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

class DFPCategoryExclusionsTableViewController: UITableViewController {

  /// The no exclusions banner view.
  @IBOutlet weak var noExclusionsBannerView: DFPBannerView!

  /// The exclude dogs banner view.
  @IBOutlet weak var excludeDogsBannerView: DFPBannerView!

  /// The exclude cats banner view.
  @IBOutlet weak var excludeCatsBannerView: DFPBannerView!


  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.tableFooterView = UIView(frame: CGRectZero)

    noExclusionsBannerView.adUnitID = Constants.DFPCategoryExclusionsAdUnitID
    noExclusionsBannerView.rootViewController = self
    let noExclusionsRequest = DFPRequest()
    noExclusionsBannerView.loadRequest(noExclusionsRequest)

    excludeDogsBannerView.adUnitID = Constants.DFPCategoryExclusionsAdUnitID
    excludeDogsBannerView.rootViewController = self
    let excludeDogsRequest = DFPRequest()
    excludeDogsRequest.categoryExclusions = [Constants.CategoryExclusionDogs]
    excludeDogsBannerView.loadRequest(excludeDogsRequest)

    excludeCatsBannerView.adUnitID = Constants.DFPCategoryExclusionsAdUnitID
    excludeCatsBannerView.rootViewController = self
    let excludeCatsRequest = DFPRequest()
    excludeCatsRequest.categoryExclusions = [Constants.CategoryExclusionCats]
    excludeCatsBannerView.loadRequest(excludeCatsRequest)
  }

  // MARK: - Table View

  override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView,
      forSection section: Int) {
    view.tintColor = UIColor.clearColor()
  }

}
