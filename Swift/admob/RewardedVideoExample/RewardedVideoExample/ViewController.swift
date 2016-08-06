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
    case NotStarted
    case Playing
    case Paused
    case Ended
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
  var timer: NSTimer?

  /// The game counter.
  var counter = 10

  /// The state of the game.
  var gameState = GameState.NotStarted

  /// The date that the timer was paused.
  var pauseDate: NSDate?

  /// The last fire date before a pause.
  var previousFireDate: NSDate?

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
    NSNotificationCenter.defaultCenter().addObserver(self,
        selector: #selector(ViewController.pauseGame),
        name: UIApplicationDidEnterBackgroundNotification, object: nil)

    // Resume game when application is returned to foreground.
    NSNotificationCenter.defaultCenter().addObserver(self,
        selector: #selector(ViewController.resumeGame),
        name: UIApplicationDidBecomeActiveNotification, object: nil)

    startNewGame()
  }

  // MARK: Game logic

  private func startNewGame() {
    gameState = .Playing
    counter = gameLength
    playAgainButton.hidden = true

    if !adRequestInProgress && rewardBasedVideo?.ready == false {
      rewardBasedVideo?.loadRequest(GADRequest(),
          withAdUnitID: "INSERT_AD_UNIT_HERE")
      adRequestInProgress = true
    }

    gameText.text = String(counter)
    timer = NSTimer.scheduledTimerWithTimeInterval(1.0,
      target: self,
      selector:#selector(ViewController.decrementCounter(_:)),
      userInfo: nil,
      repeats: true)
  }

  func pauseGame() {
    if gameState != .Playing {
      return
    }
    gameState = .Paused

    // Record the relevant pause times.
    pauseDate = NSDate()
    previousFireDate = timer?.fireDate

    // Prevent the timer from firing while app is in background.
    timer?.fireDate = NSDate.distantFuture()
  }

  func resumeGame() {
    if gameState != .Paused {
      return
    }
    gameState = .Playing

    // Calculate amount of time the app was paused.
    let pauseTime = (pauseDate?.timeIntervalSinceNow)! * -1

    // Set the timer to start firing again.
    timer?.fireDate = (previousFireDate?.dateByAddingTimeInterval(pauseTime))!
  }

  func decrementCounter(timer: NSTimer) {
    counter -= 1
    if counter > 0 {
      gameText.text = String(counter)
    } else {
      endGame()
    }
  }

  private func earnCoins(coins: NSInteger) {
    coinCount += coins
    coinCountLabel.text = "Coins: \(self.coinCount)"
  }

  private func endGame() {
    gameState = .Ended
    gameText.text = "Game over!"
    playAgainButton.hidden = false
    timer?.invalidate()
    timer = nil
    earnCoins(gameOverReward)
  }

  // MARK: Button actions

  @IBAction func playAgain(sender: AnyObject) {
    if rewardBasedVideo?.ready == true {
      rewardBasedVideo?.presentFromRootViewController(self)
    } else {
      UIAlertView(title: "Reward based video not ready",
        message: "The reward based video didn't finish loading or failed to load",
        delegate: self,
        cancelButtonTitle: "Drat").show()
    }
  }

  // MARK: UIAlertViewDelegate implementation

  func alertView(alertView: UIAlertView, willDismissWithButtonIndex buttonIndex: Int) {
    startNewGame()
  }

  // MARK: GADRewardBasedVideoAdDelegate implementation

  func rewardBasedVideoAd(rewardBasedVideoAd: GADRewardBasedVideoAd!,
      didFailToLoadWithError error: NSError!) {
    adRequestInProgress = false
    print("Reward based video ad failed to load: \(error.localizedDescription)")
  }

  func rewardBasedVideoAdDidReceiveAd(rewardBasedVideoAd: GADRewardBasedVideoAd!) {
    adRequestInProgress = false
    print("Reward based video ad is received.")
  }

  func rewardBasedVideoAdDidOpen(rewardBasedVideoAd: GADRewardBasedVideoAd!) {
    print("Opened reward based video ad.")
  }

  func rewardBasedVideoAdDidStartPlaying(rewardBasedVideoAd: GADRewardBasedVideoAd!) {
    print("Reward based video ad started playing.")
  }

  func rewardBasedVideoAdDidClose(rewardBasedVideoAd: GADRewardBasedVideoAd!) {
    print("Reward based video ad is closed.")
  }

  func rewardBasedVideoAdWillLeaveApplication(rewardBasedVideoAd: GADRewardBasedVideoAd!) {
    print("Reward based video ad will leave application.")
  }

  func rewardBasedVideoAd(rewardBasedVideoAd: GADRewardBasedVideoAd!,
      didRewardUserWithReward reward: GADAdReward!) {
    print("Reward received with currency: \(reward.type), amount \(reward.amount).")
    earnCoins(NSInteger(reward.amount))
  }

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self,
        name: UIApplicationDidEnterBackgroundNotification, object: nil)
    NSNotificationCenter.defaultCenter().removeObserver(self,
        name: UIApplicationDidBecomeActiveNotification, object: nil)
  }
}
