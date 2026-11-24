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

import Combine
import Foundation
import GoogleMobileAds
import GoogleMobileAds_Private

/// Manages view state and user actions for the Picture-in-Picture (PiP) ad example.
@MainActor
final class PictureInPictureViewModel: ObservableObject {
  @Published var selectedScope: PictureInPictureAdPresentationScope = .screen
  @Published var selectedPosition: PictureInPictureAdPosition = .default
  @Published private(set) var isLoading = false
  @Published private(set) var isAdAvailable = false
  @Published private(set) var isAdShowing = false
  @Published private(set) var statusMessage = ""

  private let adManager: PictureInPictureAdManager

  init(adManager: PictureInPictureAdManager = .shared) {
    self.adManager = adManager
    isAdAvailable = adManager.isAdAvailable
    isAdShowing = adManager.isAdShowing
  }

  /// Registers ad event listeners and syncs current ad state when the view appears.
  func onAppear() {
    isAdAvailable = adManager.isAdAvailable
    isAdShowing = adManager.isAdShowing

    adManager.onAdShownListener = { [weak self] in
      guard let self else { return }
      self.isAdShowing = true
      self.statusMessage = "Picture-in-Picture ad shown."
    }

    adManager.onAdHiddenListener = { [weak self] in
      guard let self else { return }
      self.isAdShowing = false
      self.isAdAvailable = self.adManager.isAdAvailable
      self.statusMessage = "Picture-in-Picture ad hidden."
    }
  }

  /// Cleans up listeners and destroys screen-scoped ads when the view disappears.
  func onDisappear() {
    adManager.onAdShownListener = nil
    adManager.onAdHiddenListener = nil

    // Only destroy the ad on dismissal if the scope is not application.
    if !adManager.isPresentingScreen && adManager.pipAd?.presentationScope != .application {
      adManager.destroyAd()
      isAdAvailable = false
      isAdShowing = false
    }
  }

  /// Loads a PiP ad.
  func loadAd() async {
    isLoading = true
    statusMessage = "Loading Picture-in-Picture ad..."
    defer { isLoading = false }

    do {
      try await adManager.loadAd()
      isAdAvailable = adManager.isAdAvailable
      isAdShowing = adManager.isAdShowing
      statusMessage = "Picture-in-Picture ad loaded."
    } catch {
      isAdAvailable = adManager.isAdAvailable
      isAdShowing = adManager.isAdShowing
      statusMessage = "Picture-in-Picture ad failed to load: \(error.localizedDescription)"
    }
  }

  /// Shows the loaded PiP ad using the selected options.
  func showAd() {
    guard adManager.isAdAvailable else {
      statusMessage = "No ad loaded to show."
      return
    }

    let options = PictureInPictureAdOptions()
    options.presentationScope = selectedScope
    options.position = selectedPosition
    adManager.showAd(options: options)
  }

  /// Hides the currently showing PiP ad.
  func hideAd() {
    adManager.hideAd()
  }
}
