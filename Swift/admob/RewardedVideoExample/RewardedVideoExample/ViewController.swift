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

class ViewController: UIViewController, GADRewardBasedVideoAdDelegate, UIAlertViewDelegate {

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

  /// Is an ad being loaded.
  var adRequestInProgress = false

  /// The reward-based video ad.
  var rewardBasedVideo: GADRewardBasedVideoAd?

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
    rewardBasedVideo = GADRewardBasedVideoAd.sharedInstance()
    rewardBasedVideo?.delegate = self
    coinCountLabel.text = "Coins: \(self.coinCount)"

    // Pause game when application is backgrounded.
    NotificationCenter.default.addObserver(self,
        selector: #selector(ViewController.applicationDidEnterBackground(_:)),
        name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)

    // Resume game when application is returned to foreground.
    NotificationCenter.default.addObserver(self,
        selector: #selector(ViewController.applicationDidBecomeActive(_:)),
        name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)

    startNewGame()
  }

  // MARK: Game logic

  fileprivate func startNewGame() {
    gameState = .playing
    counter = gameLength
    playAgainButton.isHidden = true

    if !adRequestInProgress && rewardBasedVideo?.isReady == false {
      rewardBasedVideo?.load(GADRequest(),
          withAdUnitID: "ca-app-pub-3940256099942544/1712485313")
      adRequestInProgress = true
    }

    gameText.text = String(counter)
    timer = Timer.scheduledTimer(timeInterval: 1.0,
      target: self,
      selector:#selector(ViewController.timerFireMethod(_:)),
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
    if rewardBasedVideo?.isReady == true {
      rewardBasedVideo?.present(fromRootViewController: self)
    } else {
      UIAlertView(title: "Reward based video not ready",
        message: "The reward based video didn't finish loading or failed to load",
        delegate: self,
        cancelButtonTitle: "Drat").show()
    }
  }

  // MARK: UIAlertViewDelegate implementation

  func alertView(_ alertView: UIAlertView, willDismissWithButtonIndex buttonIndex: Int) {
    startNewGame()
  }

  // MARK: GADRewardBasedVideoAdDelegate implementation

  func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
      didFailToLoadWithError error: Error) {
    adRequestInProgress = false
    print("Reward based video ad failed to load: \(error.localizedDescription)")
  }

  func rewardBasedVideoAdDidReceive(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
    adRequestInProgress = false
    print("Reward based video ad is received.")
  }

  func rewardBasedVideoAdDidOpen(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
    print("Opened reward based video ad.")
  }

  func rewardBasedVideoAdDidStartPlaying(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
    print("Reward based video ad started playing.")
  }

  func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
    print("Reward based video ad is closed.")
  }

  func rewardBasedVideoAdWillLeaveApplication(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
    print("Reward based video ad will leave application.")
  }

  func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
      didRewardUserWith reward: GADAdReward) {
    print("Reward received with currency: \(reward.type), amount \(reward.amount).")
    earnCoins(NSInteger(reward.amount))
  }

  deinit {
    NotificationCenter.default.removeObserver(self,
        name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    NotificationCenter.default.removeObserver(self,
        name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
  }
}
