//
//  Copyright (C) 2022 Google, Inc.
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

class GameViewController: UIViewController, GADFullScreenContentDelegate {

  private enum GameState: Int {
    case notStarted
    case playing
    case paused
    case ended
  }

  /// The game length.
  private static let gameLength = 5

  /// The time length before an ad shows.
  private static let adIntroLength = 3.0

  /// The rewarded interstitial ad.
  private var rewardedInterstitialAd: GADRewardedInterstitialAd?

  /// The countdown timer.
  private var timer: Timer?

  /// The amount of time left in the game.
  private var timeLeft = gameLength

  /// Number of coins the user has earned.
  private var coinCount = 0

  /// The state of the game.
  private var gameState = GameState.notStarted

  /// The countdown timer label.
  @IBOutlet weak var gameText: UILabel!

  /// The play again button.
  @IBOutlet weak var playAgainButton: UIButton!

  /// Text that indicates current coin count.
  @IBOutlet weak var coinCountLabel: UILabel!

  override func viewDidLoad() {
    super.viewDidLoad()

    // Pause game when application enters background.
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(GameViewController.pauseGame),
      name: UIApplication.didEnterBackgroundNotification, object: nil)

    // Resume game when application becomes active.
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(GameViewController.resumeGame),
      name: UIApplication.didBecomeActiveNotification, object: nil)

    startNewGame()
  }

  // MARK: - Game Logic

  private func startNewGame() {
    if rewardedInterstitialAd == nil {
      loadRewardedInterstitialAd()
    }

    gameState = .playing
    timeLeft = GameViewController.gameLength
    playAgainButton.isHidden = true
    updateTimeLeft()
    timer = Timer.scheduledTimer(
      timeInterval: 1.0,
      target: self,
      selector: #selector(GameViewController.decrementTimeLeft(_:)),
      userInfo: nil,
      repeats: true)
  }

  private func loadRewardedInterstitialAd() {
    let request = GADRequest()
    GADRewardedInterstitialAd.load(
      withAdUnitID: "ca-app-pub-3940256099942544/6978759866", request: request
    ) { (ad, error) in
      if let error = error {
        print("Failed to load rewarded interstitial ad with error: \(error.localizedDescription)")
        self.playAgainButton.isHidden = false
        return
      }
      self.rewardedInterstitialAd = ad
      self.rewardedInterstitialAd?.fullScreenContentDelegate = self
    }
  }

  private func updateTimeLeft() {
    gameText.text = "\(timeLeft) seconds left!"
  }

  @objc private func decrementTimeLeft(_ timer: Timer) {
    timeLeft -= 1
    updateTimeLeft()
    if timeLeft == 0 {
      endGame()
    }
  }

  private func earnCoins(_ coins: NSInteger) {
    coinCount += coins
    coinCountLabel.text = "Coins: \(self.coinCount)"
  }

  @objc private func pauseGame() {
    guard gameState == .playing else {
      return
    }
    gameState = .paused

    // Prevent the timer from firing while app is in background.
    timer?.invalidate()
    timer = nil
  }

  @objc private func resumeGame() {
    guard gameState == .paused else {
      return
    }
    gameState = .playing

    updateTimeLeft()
    // Set the timer to start firing again.
    timer = Timer.scheduledTimer(
      timeInterval: 1.0,
      target: self,
      selector: #selector(GameViewController.decrementTimeLeft(_:)),
      userInfo: nil,
      repeats: true)
  }

  private func endGame() {
    gameState = .ended
    self.earnCoins(1)
    timer?.invalidate()
    timer = nil

    var adCanceled = false

    let alert = UIAlertController(
      title: "Game Over!",
      message:
        "Watch an ad for 10 more coins. Video starting in \(Int(GameViewController.adIntroLength)) seconds",
      preferredStyle: .alert)
    let alertAction = UIAlertAction(
      title: "No, thanks",
      style: .cancel
    ) { action in
      adCanceled = true
      self.playAgainButton.isHidden = false
    }
    alert.addAction(alertAction)
    self.present(alert, animated: true) {
      DispatchQueue.main.asyncAfter(deadline: .now() + GameViewController.adIntroLength) {
        self.dismiss(animated: true) {
          if !adCanceled {
            self.showRewardedInterstitialAd()
          }
        }
      }
    }
  }

  private func showRewardedInterstitialAd() {
    guard let ad = self.rewardedInterstitialAd else {
      print("Ad wasn't ready")
      return
    }
    ad.present(fromRootViewController: self) {
      let reward = ad.adReward
      print(
        "Reward received with currency \(reward.amount), amount \(reward.amount.doubleValue)"
      )
      self.earnCoins(reward.amount.intValue)
    }
  }

  // MARK: - Interstitial Button Actions

  @IBAction func playAgain(_ sender: AnyObject) {
    startNewGame()
  }

  // MARK: - GADFullScreenContentDelegate

  func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
    print("Ad did present full screen content.")
  }

  func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error)
  {
    print("Ad failed to present full screen content with error \(error.localizedDescription).")
    self.rewardedInterstitialAd = nil
    self.playAgainButton.isHidden = false
  }

  func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
    print("Ad did dismiss full screen content.")
    self.rewardedInterstitialAd = nil
    self.playAgainButton.isHidden = false
  }

  // MARK: - deinit

  deinit {
    NotificationCenter.default.removeObserver(
      self,
      name: UIApplication.didEnterBackgroundNotification, object: nil)
    NotificationCenter.default.removeObserver(
      self,
      name: UIApplication.didBecomeActiveNotification, object: nil)
  }

}
