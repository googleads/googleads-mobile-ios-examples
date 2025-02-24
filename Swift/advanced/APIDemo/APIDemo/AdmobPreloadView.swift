//
//  Copyright 2024 Google LLC
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

import Foundation
import UIKit

class AdmobPreloadView: UIView {

  var showDelegate: (() -> Void)!

  @IBOutlet weak var titleText: UILabel!
  @IBOutlet weak var statusText: UILabel!
  @IBOutlet weak var showButton: UIButton!

  @IBAction func show(_ sender: Any) {
    showDelegate()
  }

  static func load(title: String, showDelegate: @escaping () -> Void)
    -> AdmobPreloadView!
  {
    guard
      let preloadView = Bundle.main.loadNibNamed("AdmobPreloadView", owner: self, options: nil)?
        .first
        as? AdmobPreloadView
    else {
      print("Error loading AdmobPreloadView nib file.")
      return nil
    }
    preloadView.titleText.text = title
    preloadView.showDelegate = showDelegate
    return preloadView
  }
}
