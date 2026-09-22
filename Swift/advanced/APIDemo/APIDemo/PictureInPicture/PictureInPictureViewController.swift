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

/// A view controller that demonstrates Picture-in-Picture (PiP) ads.
@MainActor
class PictureInPictureViewController: UIViewController {

  @IBOutlet weak var scopeSegmentedControl: UISegmentedControl!
  @IBOutlet weak var positionValueLabel: UILabel!
  @IBOutlet weak var loadAdButton: UIButton!
  @IBOutlet weak var showAdButton: UIButton!
  @IBOutlet weak var hideAdButton: UIButton!
  @IBOutlet weak var statusLabel: UILabel!

  private let presentationScopes: [PictureInPictureAdPresentationScope] = [
    .screen,
    .application,
  ]

  private let positions: [(title: String, position: PictureInPictureAdPosition)] = [
    ("Default", .default),
    ("Top Left", .topLeft),
    ("Top Right", .topRight),
    ("Bottom Left", .bottomLeft),
    ("Bottom Right", .bottomRight),
  ]

  private var selectedPosition: PictureInPictureAdPosition = .default

  private var loadAdTask: Task<Void, Never>?

  override func viewDidLoad() {
    super.viewDidLoad()

    // Register callback listeners for ad shown / hidden events.
    PictureInPictureAdManager.shared.onAdShownListener = { [weak self] in
      guard let self = self else { return }
      self.showAdButton.isEnabled = false
      self.hideAdButton.isEnabled = true
      self.statusLabel.text = "Picture-in-Picture ad shown."
    }

    PictureInPictureAdManager.shared.onAdHiddenListener = { [weak self] in
      guard let self = self else { return }
      self.statusLabel.text = "Picture-in-Picture ad hidden."
      self.showAdButton.isEnabled = PictureInPictureAdManager.shared.isAdAvailable()
      self.hideAdButton.isEnabled = false
    }

    showAdButton.isEnabled = PictureInPictureAdManager.shared.isAdAvailable()
    hideAdButton.isEnabled = false
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    if isMovingFromParent {
      loadAdTask?.cancel()
      PictureInPictureAdManager.shared.onAdShownListener = nil
      PictureInPictureAdManager.shared.onAdHiddenListener = nil

      // Only destroy the ad on dismissal if the scope is not application.
      if PictureInPictureAdManager.shared.pipAd?.presentationScope != .application {
        PictureInPictureAdManager.shared.destroyAd()
      }
    }
  }

  // MARK: - Actions

  @IBAction func positionRowTapped(_ sender: UIButton) {
    let sheet = UIAlertController(
      title: "Position",
      message: "Select an initial position for the Picture-in-Picture ad.",
      preferredStyle: .actionSheet
    )

    for item in positions {
      sheet.addAction(
        UIAlertAction(title: item.title, style: .default) { [weak self] _ in
          guard let self = self else { return }
          self.selectedPosition = item.position
          self.positionValueLabel.text = item.title
        }
      )
    }

    sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))

    if let popover = sheet.popoverPresentationController {
      popover.sourceView = sender
      popover.sourceRect = sender.bounds
    }

    present(sheet, animated: true)
  }

  @IBAction func loadAdButtonTapped(_ sender: Any) {
    loadAdButton.isEnabled = false
    showAdButton.isEnabled = false
    hideAdButton.isEnabled = false
    statusLabel.text = "Loading Picture-in-Picture ad..."

    loadAdTask?.cancel()
    loadAdTask = Task {
      do {
        _ = try await PictureInPictureAdManager.shared.loadAd()
        guard !Task.isCancelled else { return }
        statusLabel.text = "Picture-in-Picture ad loaded."
        loadAdButton.isEnabled = true
        showAdButton.isEnabled = true
        hideAdButton.isEnabled = false
      } catch {
        guard !Task.isCancelled else { return }
        statusLabel.text = "Picture-in-Picture ad failed to load: \(error.localizedDescription)"
        loadAdButton.isEnabled = true
        showAdButton.isEnabled = false
        hideAdButton.isEnabled = false
      }
      loadAdTask = nil
    }
  }

  @IBAction func showAdButtonTapped(_ sender: Any) {
    guard PictureInPictureAdManager.shared.isAdAvailable() else {
      statusLabel.text = "No ad loaded to show."
      return
    }

    let selectedScope = presentationScopes[scopeSegmentedControl.selectedSegmentIndex]

    let options = PictureInPictureAdOptions()
    options.presentationScope = selectedScope
    options.position = selectedPosition

    PictureInPictureAdManager.shared.showAd(options: options)
  }

  @IBAction func hideAdButtonTapped(_ sender: Any) {
    PictureInPictureAdManager.shared.hideAd()
  }
}
