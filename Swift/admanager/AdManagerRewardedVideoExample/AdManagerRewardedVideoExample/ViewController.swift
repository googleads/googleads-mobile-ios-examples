//
//  Copyright 2017 Google LLC
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

@preconcurrency import GoogleMobileAds
import UIKit

class ViewController: UIViewController, FullScreenContentDelegate {

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
  var rewardedAd: RewardedAd?

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

  /// Indicates whether the Google Mobile Ads SDK has started.
  private var isMobileAdsStartCalled = false

  /// The privacy settings button.
  @IBOutlet weak var privacySettingsButton: UIBarButtonItem!

  /// The ad inspector button.
  @IBOutlet weak var adInspectorButton: UIBarButtonItem!

  /// In-game text that indicates current counter value or game over state.
  @IBOutlet weak var gameText: UILabel!

  /// Button to restart game.
  @IBOutlet weak var playAgainButton: UIButton!

  /// Button to watch a video.
  @IBOutlet weak var watchVideoButton: UIButton!

  /// Text that indicates current coin count.
  @IBOutlet weak var coinCountLabel: UILabel!

  override func viewDidLoad() {
    super.viewDidLoad()
    coinCountLabel.text = "Coins: \(self.coinCount)"

    // Pause game when application is backgrounded.
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(ViewController.pauseGame),
      name: UIApplication.didEnterBackgroundNotification, object: nil)

    // Resume game when application is returned to foreground.
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(ViewController.resumeGame),
      name: UIApplication.didBecomeActiveNotification, object: nil)

    GoogleMobileAdsConsentManager.shared.gatherConsent(from: self) { [weak self] consentError in
      guard let self else { return }

      self.startNewGame()

      if let consentError {
        // Consent gathering failed.
        print("Error: \(consentError.localizedDescription)")
      }

      if GoogleMobileAdsConsentManager.shared.canRequestAds {
        self.startGoogleMobileAdsSDK()
      }

      self.privacySettingsButton.isEnabled =
        GoogleMobileAdsConsentManager.shared.isPrivacyOptionsRequired
    }

    // This sample attempts to load ads using consent obtained in the previous session.
    if GoogleMobileAdsConsentManager.shared.canRequestAds {
      startGoogleMobileAdsSDK()
    }
  }

  private func startGoogleMobileAdsSDK() {
    DispatchQueue.main.async {
      guard !self.isMobileAdsStartCalled else { return }

      self.isMobileAdsStartCalled = true

      // Initialize the Google Mobile Ads SDK.
      MobileAds.shared.start()
      // Request an ad.
      Task {
        await self.loadRewardedAd()
      }

    }
  }

  // [START load_rewarded]
  func loadRewardedAd() async {
    do {
      rewardedAd = try await RewardedAd.load(
        // Replace this ad unit ID with your own ad unit ID.
        with: "/21775744923/example/rewarded", request: AdManagerRequest())
      // [START set_the_delegate]
      rewardedAd?.fullScreenContentDelegate = self
      // [END set_the_delegate]
    } catch {
      print("Rewarded ad failed to load with error: \(error.localizedDescription)")
    }
  }
  // [END load_rewarded]

  // MARK: Game logic

  fileprivate func startNewGame() {
    gameState = .playing
    counter = gameLength
    playAgainButton.isHidden = true
    watchVideoButton.isHidden = true

    gameText.text = String(counter)
    timer = Timer.scheduledTimer(
      timeInterval: 1.0,
      target: self,
      selector: #selector(ViewController.timerFireMethod(_:)),
      userInfo: nil,
      repeats: true)
  }

  @objc func pauseGame() {
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

  @objc func resumeGame() {
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
    watchVideoButton.isHidden = false
    timer?.invalidate()
    timer = nil
    earnCoins(gameOverReward)
  }

  // MARK: Button actions

  /// Handle changes to user consent.
  @IBAction func privacySettingsTapped(_ sender: UIBarButtonItem) {
    pauseGame()
    Task {
      do {
        try await GoogleMobileAdsConsentManager.shared.presentPrivacyOptionsForm(from: self)
        resumeGame()
      } catch {
        let alertController = UIAlertController(
          title: error.localizedDescription, message: "Please try again later.",
          preferredStyle: .alert)
        alertController.addAction(
          UIAlertAction(
            title: "OK", style: .cancel,
            handler: { _ in
              self.resumeGame()
            }))
        present(alertController, animated: true)
      }
    }
  }

  /// Handle ad inspector launch.
  @IBAction func adInspectorTapped(_ sender: UIBarButtonItem) {
    Task {
      do {
        try await MobileAds.shared.presentAdInspector(from: self)
      } catch {
        let alertController = UIAlertController(
          title: error.localizedDescription, message: "Please try again later.",
          preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alertController, animated: true)
      }
    }
  }

  @IBAction func watchVideo(_ sender: UIButton) {
    watchVideoButton.isHidden = true

    if let rewardedAd {
      // [START present_rewarded]
      rewardedAd.present(from: self) {
        let reward = rewardedAd.adReward
        print("Reward received with currency \(reward.amount), amount \(reward.amount.doubleValue)")
        // [START_EXCLUDE silent]
        self.earnCoins(NSInteger(truncating: reward.amount))
        // [END_EXCLUDE]

        // TODO: Reward the user.
      }
      // [END present_rewarded]
    } else {
      let alert = UIAlertController(
        title: "Rewarded video not ready",
        message: "The rewarded video didn't finish loading or failed to load",
        preferredStyle: .alert)
      let alertAction = UIAlertAction(
        title: "OK",
        style: .cancel)
      alert.addAction(alertAction)
      self.present(alert, animated: true, completion: nil)
    }
  }

  @IBAction func playAgain(_ sender: AnyObject) {
    startNewGame()
    if GoogleMobileAdsConsentManager.shared.canRequestAds {
      Task {
        await loadRewardedAd()
      }
    }
  }

  // MARK: GADFullScreenContentDelegate

  // [START ad_events]
  func adDidRecordImpression(_ ad: FullScreenPresentingAd) {
    print("\(#function) called.")
  }

  func adDidRecordClick(_ ad: FullScreenPresentingAd) {
    print("\(#function) called.")
  }

  func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
    print("\(#function) called.")
  }

  func adWillDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
    print("\(#function) called.")
  }

  func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
    print("\(#function) called.")
    // Clear the rewarded ad.
    rewardedAd = nil
  }

  func ad(
    _ ad: FullScreenPresentingAd,
    didFailToPresentFullScreenContentWithError error: Error
  ) {
    print("\(#function) called with error: \(error.localizedDescription).")
    // [START_EXCLUDE silent]
    let alert = UIAlertController(
      title: "Rewarded ad failed to present",
      message: "The reward ad could not be presented.",
      preferredStyle: .alert)
    let alertAction = UIAlertAction(
      title: "Drat",
      style: .cancel)
    alert.addAction(alertAction)
    self.present(alert, animated: true, completion: nil)
    // [END_EXCLUDE]
  }
  // [END ad_events]

  deinit {
    NotificationCenter.default.removeObserver(
      self,
      name: UIApplication.didEnterBackgroundNotification, object: nil)
    NotificationCenter.default.removeObserver(
      self,
      name: UIApplication.didBecomeActiveNotification, object: nil)
  }
}
