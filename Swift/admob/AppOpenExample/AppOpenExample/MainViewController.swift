//
//  Copyright 2021 Google LLC
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit

class MainViewController: UIViewController {

  @IBOutlet weak var privacySettingsButton: UIBarButtonItem!

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    privacySettingsButton.isEnabled =
      GoogleMobileAdsConsentManager.shared.isPrivacyOptionsRequired
  }

  @IBAction func privacySettingsTapped(_ sender: UIBarButtonItem) {
    GoogleMobileAdsConsentManager.shared.presentPrivacyOptionsForm(from: self) {
      [weak self] (formError) in
      guard let self, let formError else { return }

      let alertController = UIAlertController(
        title: formError.localizedDescription, message: "Please try again later.",
        preferredStyle: .alert)
      alertController.addAction(UIAlertAction(title: "OK", style: .cancel))
      self.present(alertController, animated: true)
    }
  }
}
