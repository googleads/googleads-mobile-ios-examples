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

import UIKit

class MasterViewController: UITableViewController {

  /// API Demo names.
  var APIDemoNames: [String]!

  /// Segue identifiers.
  var identifiers: [String]!

  override func viewDidLoad() {
    super.viewDidLoad()
    APIDemoNames = ["AdMob - Ad Delegate", "AdMob - Ad Targeting", "AdMob - Banner Sizes",
                    "DFP - PPID", "DFP - Custom Targeting", "DFP - Category Exclusions",
                    "DFP - Multiple Ad Sizes", "DFP - App Events", "DFP - Fluid Ad Size",
                    "DFP - Competitive Exclusions"]
    identifiers = ["adDelegateSegue", "adTargetingSegue", "bannerSizesSegue", "PPIDSegue",
                   "customTargetingSegue", "categoryExclusionsSegue", "multipleAdSizesSegue",
                   "appEventsSegue", "fluidAdSizeSegue", "competitiveExclusionsSegue"]
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    if let indexPathSelected = tableView.indexPathForSelectedRow {
      tableView.deselectRowAtIndexPath(indexPathSelected, animated: animated)
    }
  }

  // MARK: - Table View

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return APIDemoNames.count
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) ->
      UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("DemoCell")!
    cell.textLabel!.text = APIDemoNames[indexPath.row]

    return cell
  }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let row = indexPath.row
    if row < identifiers.count {
      performSegueWithIdentifier(identifiers[row], sender: self)
    }
  }

}
