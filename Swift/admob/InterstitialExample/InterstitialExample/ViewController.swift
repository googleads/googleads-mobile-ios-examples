//
//  Copyright (C) 2015 Google LLC
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

  /// The game length.
  static let gameLength = 5

  /// The interstitial ad.
  var interstitial: InterstitialAd?

  /// The countdown timer.
  var timer: Timer?

  /// The amount of time left in the game.
  var timeLeft = gameLength

  /// The state of the game.
  var gameState = GameState.notStarted

  /// The date that the timer was paused.
  var pauseDate: Date?

  /// The last fire date before a pause.
  var previousFireDate: Date?

  /// Indicates whether the Google Mobile Ads SDK has started.
  private var isMobileAdsStartCalled = false

  /// The container for the game.
  @IBOutlet weak var gameView: UIView!

  /// A spinner indicating whether the app is loading content.
  @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!

  /// The privacy settings button.
  @IBOutlet weak var privacySettingsButton: UIBarButtonItem!

  /// The countdown timer label.
  @IBOutlet weak var gameText: UILabel!

  /// The play again button.
  @IBOutlet weak var playAgainButton: UIButton!

  /// The ad inspector button.
  @IBOutlet weak var adInspectorButton: UIBarButtonItem!

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

  override func viewDidLoad() {
    super.viewDidLoad()

    // Sets up a loading spinner while consent is being gathered.
    let loadingSpinnerWorkItem = DispatchWorkItem {
      self.loadingSpinner.startAnimating()
    }
    // Show spinner if loading takes longer than 1 second.
    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: loadingSpinnerWorkItem)

    // Pause game when application enters background.
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(ViewController.pauseGame),
      name: UIApplication.didEnterBackgroundNotification, object: nil)

    // Resume game when application becomes active.
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(ViewController.resumeGame),
      name: UIApplication.didBecomeActiveNotification, object: nil)

    GoogleMobileAdsConsentManager.shared.gatherConsent(from: self) { [weak self] consentError in
      guard let self else { return }

      loadingSpinnerWorkItem.cancel()
      self.loadingSpinner.stopAnimating()

      // Animate the visibility of the game UI.
      UIView.animate(withDuration: 0.25) {
        self.gameView.alpha = 1
      }

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
        await self.loadInterstitial()
      }
    }
  }

  // MARK: - Game Logic

  fileprivate func startNewGame() {
    gameState = .playing
    timeLeft = ViewController.gameLength
    playAgainButton.isHidden = true
    updateTimeLeft()
    timer = Timer.scheduledTimer(
      timeInterval: 1.0,
      target: self,
      selector: #selector(ViewController.decrementTimeLeft(_:)),
      userInfo: nil,
      repeats: true)
  }

  // [START load_interstitial]
  fileprivate func loadInterstitial() async {
    do {
      interstitial = try await InterstitialAd.load(
        with: "ca-app-pub-3940256099942544/4411468910", request: Request())
      // [START set_the_delegate]
      interstitial?.fullScreenContentDelegate = self
      // [END set_the_delegate]
    } catch {
      print("Failed to load interstitial ad with error: \(error.localizedDescription)")
    }
  }
  // [END load_interstitial]

  fileprivate func updateTimeLeft() {
    gameText.text = "\(timeLeft) seconds left!"
  }

  @objc func decrementTimeLeft(_ timer: Timer) {
    timeLeft -= 1
    updateTimeLeft()
    if timeLeft == 0 {
      endGame()
    }
  }

  @objc func pauseGame() {
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
    if gameState != .paused {
      return
    }
    gameState = .playing

    // Calculate amount of time the app was paused.
    let pauseTime = (pauseDate?.timeIntervalSinceNow)! * -1

    // Set the timer to start firing again.
    timer?.fireDate = (previousFireDate?.addingTimeInterval(pauseTime))!
  }

  fileprivate func endGame() {
    gameState = .ended
    timer?.invalidate()
    timer = nil

    let alert = UIAlertController(
      title: "Game Over",
      message: "You lasted \(ViewController.gameLength) seconds",
      preferredStyle: .alert)
    let alertAction = UIAlertAction(
      title: "OK",
      style: .cancel,
      handler: { [weak self] action in
        if let ad = self?.interstitial {
          // [START present_interstitial]
          ad.present(from: self!)
          // [END present_interstitial]
        } else {
          print("Ad wasn't ready")
        }
        self?.playAgainButton.isHidden = false
      })
    alert.addAction(alertAction)
    self.present(alert, animated: true, completion: nil)
  }

  // MARK: - Interstitial Button Actions

  @IBAction func playAgain(_ sender: AnyObject) {
    startNewGame()

    if GoogleMobileAdsConsentManager.shared.canRequestAds {
      Task {
        await loadInterstitial()
      }
    }
  }

  // MARK: - GADFullScreenContentDelegate

  // [START ad_events]
  func adDidRecordImpression(_ ad: FullScreenPresentingAd) {
    print("\(#function) called")
  }

  func adDidRecordClick(_ ad: FullScreenPresentingAd) {
    print("\(#function) called")
  }

  func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
    print("\(#function) called with error: \(error.localizedDescription)")
    // Clear the interstitial ad.
    interstitial = nil
  }

  func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
    print("\(#function) called")
  }

  func adWillDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
    print("\(#function) called")
  }

  func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
    print("\(#function) called")
    // Clear the interstitial ad.
    interstitial = nil
  }
  // [END ad_events]

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
