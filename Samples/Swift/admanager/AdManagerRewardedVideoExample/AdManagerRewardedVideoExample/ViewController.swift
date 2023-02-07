//
//  Copyright (C) 2017 Google, Inc.
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

class ViewController: UIViewController, GADFullScreenContentDelegate {

  enum GameState: NSInteger {
    case notStarted
    case playing
    case paused
    case ended
  }

  /// Constant for coin rewards.
  let gameOverReward = 1

  /// Starting time for game counter.
  let gameLength = 10

  /// Number of coins the user has earned.
  var coinCount = 0

  /// The reward-based video ad.
  var rewardedAd: GADRewardedAd?

  /// The countdown timer.
  var timer: Timer?

  /// The game counter.
  var counter = 10

  /// The state of the game.
  var gameState = GameState.notStarted

  /// The date that the timer was paused.
  var pauseDate: Date?

  /// The last fire date before a pause.
  var previousFireDate: Date?

  /// In-game text that indicates current counter value or game over state.
  @IBOutlet weak var gameText: UILabel!

  /// Button to restart game.
  @IBOutlet weak var playAgainButton: UIButton!

  /// Text that indicates current coin count.
  @IBOutlet weak var coinCountLabel: UILabel!

  override func viewDidLoad() {
    super.viewDidLoad()
    coinCountLabel.text = "Coins: \(self.coinCount)"

    // Pause game when application is backgrounded.
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(ViewController.applicationDidEnterBackground(_:)),
      name: UIApplication.didEnterBackgroundNotification, object: nil)

    // Resume game when application is returned to foreground.
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(ViewController.applicationDidBecomeActive(_:)),
      name: UIApplication.didBecomeActiveNotification, object: nil)

    startNewGame()
  }

  // MARK: Game logic

  fileprivate func startNewGame() {
    gameState = .playing
    counter = gameLength
    playAgainButton.isHidden = true

    GADRewardedAd.load(
      withAdUnitID: "/6499/example/rewarded-video", request: GAMRequest()
    ) { (ad, error) in
      if let error = error {
        print("Rewarded ad failed to load with error: \(error.localizedDescription)")
        return
      }
      print("Loading Succeeded")
      self.rewardedAd = ad
      self.rewardedAd?.fullScreenContentDelegate = self
    }

    gameText.text = String(counter)
    timer = Timer.scheduledTimer(
      timeInterval: 1.0,
      target: self,
      selector: #selector(ViewController.timerFireMethod(_:)),
      userInfo: nil,
      repeats: true)
  }

  @objc func applicationDidEnterBackground(_ notification: Notification) {
    // Pause the game if it is currently playing.
    if gameState != .playing {
      return
    }
    gameState = .paused

    // Record the relevant pause times.
    pauseDate = Date()
    previousFireDate = timer?.fireDate

    // Prevent the timer from firing while app is in background.
    timer?.fireDate = Date.distantFuture
  }

  @objc func applicationDidBecomeActive(_ notification: Notification) {
    // Resume the game if it is currently paused.
    if gameState != .paused {
      return
    }
    gameState = .playing

    // Calculate amount of time the app was paused.
    let pauseTime = (pauseDate?.timeIntervalSinceNow)! * -1

    // Set the timer to start firing again.
    timer?.fireDate = (previousFireDate?.addingTimeInterval(pauseTime))!
  }

  @objc func timerFireMethod(_ timer: Timer) {
    counter -= 1
    if counter > 0 {
      gameText.text = String(counter)
    } else {
      endGame()
    }
  }

  fileprivate func earnCoins(_ coins: NSInteger) {
    coinCount += coins
    coinCountLabel.text = "Coins: \(self.coinCount)"
  }

  fileprivate func endGame() {
    gameState = .ended
    gameText.text = "Game over!"
    playAgainButton.isHidden = false
    timer?.invalidate()
    timer = nil
    earnCoins(gameOverReward)
  }

  // MARK: Button actions

  @IBAction func playAgain(_ sender: AnyObject) {
    if let ad = rewardedAd {
      ad.present(fromRootViewController: self) {
        let reward = ad.adReward
        print("Reward received with currency \(reward.amount), amount \(reward.amount.doubleValue)")
        self.earnCoins(NSInteger(truncating: reward.amount))
        // TODO: Reward the user.
      }
    } else {
      let alert = UIAlertController(
        title: "Rewarded video not ready",
        message: "The rewarded video didn't finish loading or failed to load",
        preferredStyle: .alert)
      let alertAction = UIAlertAction(
        title: "OK",
        style: .cancel,
        handler: { [weak self] action in
          self?.startNewGame()
        })
      alert.addAction(alertAction)
      self.present(alert, animated: true, completion: nil)
    }
  }

  // MARK: GADFullScreenContentDelegate

  func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
    print("Rewarded ad will be presented.")
  }

  func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
    print("Rewarded ad dismissed.")
  }

  func ad(
    _ ad: GADFullScreenPresentingAd,
    didFailToPresentFullScreenContentWithError error: Error
  ) {
    print("Rewarded ad failed to present with error: \(error.localizedDescription).")
    let alert = UIAlertController(
      title: "Rewarded ad failed to present",
      message: "The reward ad could not be presented.",
      preferredStyle: .alert)
    let alertAction = UIAlertAction(
      title: "Drat",
      style: .cancel,
      handler: { [weak self] action in
        self?.startNewGame()
      })
    alert.addAction(alertAction)
    self.present(alert, animated: true, completion: nil)
  }

  deinit {
    NotificationCenter.default.removeObserver(
      self,
      name: UIApplication.didEnterBackgroundNotification, object: nil)
    NotificationCenter.default.removeObserver(
      self,
      name: UIApplication.didBecomeActiveNotification, object: nil)
  }
}
