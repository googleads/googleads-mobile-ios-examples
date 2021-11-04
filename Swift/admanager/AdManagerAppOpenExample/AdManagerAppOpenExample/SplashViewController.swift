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

class SplashViewController: UIViewController, AppOpenAdManagerDelegate {
  /// Number of seconds remaining to show the app open ad.
  /// This simulates the time needed to load the app.
  var secondsRemaining: Int = 5
  /// The countdown timer.
  var countdownTimer: Timer?
  /// Text that indicates the number of seconds left to show an app open ad.
  @IBOutlet weak var splashScreenLabel: UILabel!

  override func viewDidLoad() {
    super.viewDidLoad()
    AppOpenAdManager.shared.appOpenAdManagerDelegate = self
    startTimer()
  }

  @objc func decrementCounter() {
    secondsRemaining -= 1
    if secondsRemaining > 0 {
      splashScreenLabel.text = "App is done loading in: \(secondsRemaining)"
    } else {
      splashScreenLabel.text = "Done."
      countdownTimer?.invalidate()
      AppOpenAdManager.shared.showAdIfAvailable(viewController: self)
    }
  }

  func startTimer() {
    splashScreenLabel.text = "App is done loading in: \(secondsRemaining)"
    countdownTimer = Timer.scheduledTimer(
      timeInterval: 1.0,
      target: self,
      selector: #selector(SplashViewController.decrementCounter),
      userInfo: nil,
      repeats: true)
  }

  func startMainScreen() {
    let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
    let mainViewController = mainStoryBoard.instantiateViewController(
      withIdentifier: "MainStoryBoard")
    present(mainViewController, animated: true) {
      self.dismiss(animated: false) {
        // Find the keyWindow which is currently being displayed on the device,
        // and set its rootViewController to mainViewController.
        let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        keyWindow?.rootViewController = mainViewController
      }
    }
  }

  // MARK: AppOpenAdManagerDelegate
  func appOpenAdManagerAdDidComplete(_ appOpenAdManager: AppOpenAdManager) {
    startMainScreen()
  }
}
