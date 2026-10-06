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

import GoogleMobileAds
import GoogleMobileAds_Private
import UIKit

/// A view controller that demonstrates squeezeback ads.
@MainActor
class SqueezebackViewController: UIViewController {

  @IBOutlet weak var loadAdButton: UIButton!
  @IBOutlet weak var showAdButton: UIButton!
  @IBOutlet weak var hideAdButton: UIButton!
  @IBOutlet weak var statusLabel: UILabel!

  private var loadAdTask: Task<Void, Never>?

  override func viewDidLoad() {
    super.viewDidLoad()

    // Register callback listeners for ad shown / hidden events.
    SqueezebackAdManager.shared.onAdShownListener = { [weak self] in
      guard let self = self else { return }
      self.showAdButton.isEnabled = false
      self.hideAdButton.isEnabled = true
      self.statusLabel.text = "Squeezeback ad shown."
    }

    SqueezebackAdManager.shared.onAdHiddenListener = { [weak self] in
      guard let self = self else { return }
      self.statusLabel.text = "Squeezeback ad hidden."
      self.showAdButton.isEnabled = SqueezebackAdManager.shared.isAdAvailable()
      self.hideAdButton.isEnabled = false
    }

    showAdButton.isEnabled = SqueezebackAdManager.shared.isAdAvailable()
    hideAdButton.isEnabled = false
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    if isMovingFromParent {
      loadAdTask?.cancel()
      SqueezebackAdManager.shared.onAdShownListener = nil
      SqueezebackAdManager.shared.onAdHiddenListener = nil
      SqueezebackAdManager.shared.destroyAd()
    }
  }

  // MARK: - Actions

  @IBAction func loadAdButtonTapped(_ sender: Any) {
    loadAdButton.isEnabled = false
    showAdButton.isEnabled = false
    hideAdButton.isEnabled = false
    statusLabel.text = "Loading squeezeback ad..."

    loadAdTask?.cancel()
    loadAdTask = Task {
      do {
        _ = try await SqueezebackAdManager.shared.loadAd()
        guard !Task.isCancelled else { return }
        statusLabel.text = "Squeezeback ad loaded."
        loadAdButton.isEnabled = true
        showAdButton.isEnabled = true
        hideAdButton.isEnabled = false
      } catch {
        guard !Task.isCancelled else { return }
        statusLabel.text = "Squeezeback ad failed to load: \(error.localizedDescription)"
        loadAdButton.isEnabled = true
        showAdButton.isEnabled = false
        hideAdButton.isEnabled = false
      }
      loadAdTask = nil
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
}
