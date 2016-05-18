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

  /// The starting time for game counter.
  let gameLength = 10

  /// The interstitial ad.
  var interstitial: DFPInterstitial!

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
    gameState = .Playing
    counter = gameLength
    playAgainButton.hidden = true
    loadInterstitial()
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

  private func endGame() {
    gameState = .Ended
    gameText.text = "Game over!"
    playAgainButton.hidden = false
    timer?.invalidate()
    timer = nil
  }

  // MARK: - Interstitial Button Actions

  @IBAction func playAgain(sender: AnyObject) {
    if interstitial?.isReady == true {
      interstitial?.presentFromRootViewController(self)
    } else {
      UIAlertView(title: "Interstitial not ready",
          message: "The interstitial didn't finish loading or failed to load",
          delegate: self,
          cancelButtonTitle: "Drat").show()
    }
  }

  private func loadInterstitial() {
    interstitial = DFPInterstitial(adUnitID: "/6499/example/interstitial")
    interstitial?.delegate = self

    // Request test ads on devices you specify. Your test device ID is printed to the console when
    // an ad request is made.
    interstitial?.loadRequest(DFPRequest())
  }

  // MARK: - UIAlertViewDelegate

  func alertView(alertView: UIAlertView, willDismissWithButtonIndex buttonIndex: Int) {
    startNewGame()
  }

  // MARK: - GADInterstitialDelegate

  func interstitialDidFailToReceiveAdWithError(interstitial: DFPInterstitial,
      error: GADRequestError) {
    print("\(#function): \(error.localizedDescription)")
  }

  func interstitialDidDismissScreen (interstitial: GADInterstitial) {
    print(#function)
    startNewGame()
  }

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self,
        name: UIApplicationDidEnterBackgroundNotification, object: nil)
    NSNotificationCenter.defaultCenter().removeObserver(self,
        name: UIApplicationDidBecomeActiveNotification, object: nil)
  }

}
