//
//  Copyright 2026 Google LLC
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

import Foundation
import UIKit

/// Demonstrates squeezeback ads.
@MainActor
class SqueezebackViewController: UIViewController, SqueezebackAdManagerDelegate {

  @IBOutlet weak var loadAdButton: UIButton!
  @IBOutlet weak var showAdButton: UIButton!
  @IBOutlet weak var hideAdButton: UIButton!
  @IBOutlet weak var statusLabel: UILabel!

  private var loadAdTask: Task<Void, Never>?

  override func viewDidLoad() {
    super.viewDidLoad()

    let manager = SqueezebackAdManager.shared
    manager.delegate = self
    updateButtonStates()

    if manager.isAdShowing {
      statusLabel.text = "Squeezeback ad shown."
    } else if manager.isAdAvailable() {
      statusLabel.text = "Squeezeback ad loaded."
    }
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    guard isMovingFromParent else { return }
    loadAdTask?.cancel()
    loadAdTask = nil
    if SqueezebackAdManager.shared.delegate === self {
      SqueezebackAdManager.shared.delegate = nil
    }
  }

  // MARK: - Actions

  @IBAction func loadAdButtonTapped(_ sender: Any) {
    guard !SqueezebackAdManager.shared.isAdShowing else { return }

    loadAdButton.isEnabled = false
    showAdButton.isEnabled = false
    hideAdButton.isEnabled = false
    statusLabel.text = "Loading squeezeback ad..."

    loadAdTask?.cancel()
    loadAdTask = Task { [weak self] in
      await self?.performAdLoad()
    }
  }

  @IBAction func showAdButtonTapped(_ sender: Any) {
    guard SqueezebackAdManager.shared.isAdAvailable() else {
      statusLabel.text = "No ad loaded to show."
      return
    }

    SqueezebackAdManager.shared.showAd()
  }

  @IBAction func hideAdButtonTapped(_ sender: Any) {
    SqueezebackAdManager.shared.hideAd()
  }

  private func performAdLoad() async {
    do {
      _ = try await SqueezebackAdManager.shared.loadAd()
      guard !Task.isCancelled else { return }
      statusLabel.text = "Squeezeback ad loaded."
    } catch {
      guard !Task.isCancelled else { return }
      print("Squeezeback ad failed to load: \(error.localizedDescription)")
      statusLabel.text = "Squeezeback ad failed to load: \(error.localizedDescription)"
    }
    loadAdTask = nil
    updateButtonStates()
  }

  private func updateButtonStates() {
    let manager = SqueezebackAdManager.shared
    loadAdButton.isEnabled = !manager.isAdShowing
    showAdButton.isEnabled = manager.isAdAvailable()
    hideAdButton.isEnabled = manager.isAdShowing
  }

  // MARK: - SqueezebackAdManagerDelegate

  func squeezebackAdManagerDidShowAd(_ manager: SqueezebackAdManager) {
    statusLabel.text = "Squeezeback ad shown."
    updateButtonStates()
  }

  func squeezebackAdManagerDidHideAd(_ manager: SqueezebackAdManager) {
    statusLabel.text = "Squeezeback ad hidden."
    updateButtonStates()
  }

  func squeezebackAdManager(
    _ manager: SqueezebackAdManager, didFailToShowAdWith error: Error
  ) {
    statusLabel.text = "Squeezeback ad failed to show: \(error.localizedDescription)"
    updateButtonStates()
  }
}
