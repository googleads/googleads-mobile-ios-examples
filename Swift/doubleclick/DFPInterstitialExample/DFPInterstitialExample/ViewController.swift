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
    case NotStarted
    case Playing
    case Paused
    case Ended
  }

  /// The game length.
  static let gameLength = 5

  /// The interstitial ad.
  var interstitial: DFPInterstitial!

  /// The countdown timer.
  var timer: NSTimer?

  /// The amount of time left in the game.
  var timeLeft = gameLength

  /// The state of the game.
  var gameState = GameState.NotStarted

  /// The date that the timer was paused.
  var pauseDate: NSDate?

  /// The last fire date before a pause.
  var previousFireDate: NSDate?

  /// The countdown timer label.
  @IBOutlet weak var gameText: UILabel!

  /// The play again button.
  @IBOutlet weak var playAgainButton: UIButton!

  override func viewDidLoad() {
    super.viewDidLoad()

    // Pause game when application enters background.
    NSNotificationCenter.defaultCenter().addObserver(self,
        selector: #selector(ViewController.pauseGame),
        name: UIApplicationDidEnterBackgroundNotification, object: nil)

    // Resume game when application becomes active.
    NSNotificationCenter.defaultCenter().addObserver(self,
        selector: #selector(ViewController.resumeGame),
        name: UIApplicationDidBecomeActiveNotification, object: nil)

    startNewGame()
  }

  // MARK: - Game Logic

  private func startNewGame() {
    createAndLoadInterstitial()

    gameState = .Playing
    timeLeft = ViewController.gameLength
    playAgainButton.hidden = true
    updateTimeLeft()
    timer = NSTimer.scheduledTimerWithTimeInterval(1.0,
        target: self,
        selector:#selector(ViewController.decrementTimeLeft(_:)),
        userInfo: nil,
        repeats: true)
  }

  private func createAndLoadInterstitial() {
    interstitial = DFPInterstitial(adUnitID: "/6499/example/interstitial")
    interstitial.loadRequest(DFPRequest())
  }

  private func updateTimeLeft() {
    gameText.text = "\(timeLeft) seconds left!"
  }

  func decrementTimeLeft(timer: NSTimer) {
    timeLeft -= 1
    updateTimeLeft()
    if timeLeft == 0 {
      endGame()
    }
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

  private func endGame() {
    gameState = .Ended
    timer?.invalidate()
    timer = nil

    UIAlertView(title: "Game Over",
                message: "You lasted \(ViewController.gameLength) seconds",
                delegate: self,
                cancelButtonTitle: "Ok").show()
  }

  // MARK: - Interstitial Button Actions

  @IBAction func playAgain(sender: AnyObject) {
    startNewGame()
  }

  // MARK: - UIAlertViewDelegate

  func alertView(alertView: UIAlertView, willDismissWithButtonIndex buttonIndex: Int) {
    if interstitial.isReady {
      interstitial.presentFromRootViewController(self)
    } else {
      print("Ad wasn't ready")
    }
    playAgainButton.hidden = false
  }

  // MARK: - deinit

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self,
        name: UIApplicationDidEnterBackgroundNotification, object: nil)
    NSNotificationCenter.defaultCenter().removeObserver(self,
        name: UIApplicationDidBecomeActiveNotification, object: nil)
  }

}
