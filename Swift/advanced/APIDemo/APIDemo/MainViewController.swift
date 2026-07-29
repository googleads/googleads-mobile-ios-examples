//
//  Copyright 2016-2023 Google LLC
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

class MainViewController: UITableViewController {

  /// API Demo names.
  var apiDemoNames: [String]!

  /// Segue identifiers.
  var identifiers: [String]!

  override func viewDidLoad() {
    super.viewDidLoad()
    apiDemoNames = [
      "AdMob - Ad Delegate", "AdMob - Ad Targeting", "AdMob - Banner Sizes",
      "AdMob - Native Custom Mute This Ad", "AdMob - Ad Preloading",
      "AdManager - PPID", "AdManager - Custom Targeting", "AdManager - Category Exclusions",
      "AdManager - Multiple Ad Sizes", "AdManager - App Events", "AdManager - Fluid Ad Size",
      "AdManager - Custom Video Controls", "Collapsible Banner Ad",
    ]
    identifiers = [
      "adDelegateSegue", "adTargetingSegue", "bannerSizesSegue", "customMuteSegue",
      "adPreloadingSegue", "PPIDSegue", "customTargetingSegue", "categoryExclusionsSegue",
      "multipleAdSizesSegue", "appEventsSegue", "fluidAdSizeSegue",
      "customControlsSegue", "collapsibleSegue",
    ]
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if let indexPathSelected = tableView.indexPathForSelectedRow {
      tableView.deselectRow(at: indexPathSelected, animated: animated)
    }
  }

  // MARK: - Table View

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return apiDemoNames.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
    -> UITableViewCell
  {
    let cell = tableView.dequeueReusableCell(withIdentifier: "DemoCell")!
    cell.textLabel!.text = apiDemoNames[indexPath.row]

    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let row = indexPath.row
    if row < identifiers.count {
      performSegue(withIdentifier: identifiers[row], sender: self)
    }
  }

}
