//
//  Copyright (C) 2015 Google, Inc.
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

class ViewController: UIViewController, GADInterstitialDelegate, UIAlertViewDelegate {

  enum GameState: NSInteger {
    case notStarted
    case playing
    case paused
    case ended
  }

  /// The game length.
  static let gameLength = 5

  /// The interstitial ad.
  var interstitial: DFPInterstitial!

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

  /// The countdown timer label.
  @IBOutlet weak var gameText: UILabel!

  /// The play again button.
  @IBOutlet weak var playAgainButton: UIButton!

  override func viewDidLoad() {
    super.viewDidLoad()

    // Pause game when application enters background.
    NotificationCenter.default.addObserver(self,
        selector: #selector(ViewController.pauseGame),
        name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)

    // Resume game when application becomes active.
    NotificationCenter.default.addObserver(self,
        selector: #selector(ViewController.resumeGame),
        name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)

    startNewGame()
  }

  // MARK: - Game Logic

  fileprivate func startNewGame() {
    createAndLoadInterstitial()

    gameState = .playing
    timeLeft = ViewController.gameLength
    playAgainButton.isHidden = true
    updateTimeLeft()
    timer = Timer.scheduledTimer(timeInterval: 1.0,
        target: self,
        selector:#selector(ViewController.decrementTimeLeft(_:)),
        userInfo: nil,
        repeats: true)
  }

  fileprivate func createAndLoadInterstitial() {
    interstitial = DFPInterstitial(adUnitID: "/6499/example/interstitial")
    interstitial.load(DFPRequest())
  }

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

    UIAlertView(title: "Game Over",
                message: "You lasted \(ViewController.gameLength) seconds",
                delegate: self,
                cancelButtonTitle: "Ok").show()
  }

  // MARK: - Interstitial Button Actions

  @IBAction func playAgain(_ sender: AnyObject) {
    startNewGame()
  }

  // MARK: - UIAlertViewDelegate

  func alertView(_ alertView: UIAlertView, willDismissWithButtonIndex buttonIndex: Int) {
    if interstitial.isReady {
      interstitial.present(fromRootViewController: self)
    } else {
      print("Ad wasn't ready")
    }
    playAgainButton.isHidden = false
  }

  // MARK: - deinit

  deinit {
    NotificationCenter.default.removeObserver(self,
        name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    NotificationCenter.default.removeObserver(self,
        name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
  }

}
