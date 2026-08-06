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
import SwiftUI
import UIKit

enum AdLoadState {
  case idle, loading, loaded, failed

  var statusText: String {
    switch self {
    case .idle: return ""
    case .loading: return "Ad loading..."
    case .loaded: return "Ad loaded"
    case .failed: return "Ad failed to load"
    }
  }

  var statusColor: Color {
    switch self {
    case .idle: return .clear
    case .loading: return .yellow
    case .loaded: return .green
    case .failed: return .red
    }
  }
}

@available(iOS 17.0, *)
@MainActor
class SwipeableFeedViewModel:
  NSObject, ObservableObject, SwipeableInterstitialAdDelegate,
  VideoControllerDelegate
{
  @Published var swipeableInterstitialAd: SwipeableInterstitialAd?
  @Published var adLoadState: AdLoadState = .idle
  @Published var requestedMaxScreenHoldDuration: TimeInterval = 0
  @Published var isScrollDisabled = false
  @Published var scrolledID: Int? = 0

  private var lastSettledID: Int = 0
  private var holdEndTime: Date?

  override init() {
    super.init()
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(checkScreenHold),
      name: UIApplication.didBecomeActiveNotification,
      object: nil)
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  func handleSlideSettled() {
    // Ignore redundant slide-settle events when snapping back to the same slide
    // after a partial swipe, so we do not restart the hold timer or reload the ad.
    guard let id = scrolledID, id != lastSettledID else { return }
    lastSettledID = id
    if id.isMultiple(of: 2) {
      // Landing on a content slide discards the old ad, preloads a fresh ad
      // for the next ad slot, and locks scrolling until the new ad loads.
      reloadAd()
    } else if let ad = swipeableInterstitialAd, ad.minScreenHoldDuration > 0 {
      // Landing on an ad slot (`id % 2 == 1`) enforces a minimum screen hold
      // duration if required by the ad payload (`minScreenHoldDuration > 0`)
      // by locking feed scrolling inputs.
      startScreenHold(duration: ad.minScreenHoldDuration)
    }
  }

  private func startScreenHold(duration: TimeInterval) {
    isScrollDisabled = true
    holdEndTime = Date().addingTimeInterval(duration)
    Task { [weak self] in
      try? await Task.sleep(for: .seconds(duration))
      self?.checkScreenHold()
    }
  }

  @objc func checkScreenHold() {
    guard isScrollDisabled, let endTime = holdEndTime, Date() >= endTime else { return }
    isScrollDisabled = false
    holdEndTime = nil
    print("Screen hold completed.")
  }

  func reloadAd() {
    guard adLoadState != .loading else { return }
    discardAd()
    adLoadState = .loading
    isScrollDisabled = true

    Task {
      do {
        // By default, swipeable interstitial ads match the fullscreen size. If
        // requesting a custom ad size (options.adSize), it must fill at least
        // 60% of the screen size.
        let options =
          requestedMaxScreenHoldDuration > 0 ? SwipeableInterstitialAdOptions() : nil
        options?.maxScreenHoldDuration = requestedMaxScreenHoldDuration
        let ad = try await SwipeableInterstitialAd.load(
          with: Constants.swipeableInterstitialAdUnitID,
          request: Request(),
          options: options)
        ad.delegate = self
        ad.videoControllerDelegate = self
        swipeableInterstitialAd = ad
        adLoadState = .loaded
        print("Ad loaded.")
      } catch {
        adLoadState = .failed
        print("Ad failed to load: \(error.localizedDescription)")
      }
      isScrollDisabled = false
    }
  }

  func discardAd() {
    swipeableInterstitialAd?.adView.removeFromSuperview()
    swipeableInterstitialAd = nil
  }

  // MARK: - Delegates

  func swipeableInterstitialAdDidRecordImpression(_ ad: SwipeableInterstitialAd) {
    print("Ad recorded an impression.")
  }

  func swipeableInterstitialAdDidRecordClick(_ ad: SwipeableInterstitialAd) {
    print("Ad recorded a click.")
  }

  func swipeableInterstitialAdWillPresentScreen(_ ad: SwipeableInterstitialAd) {
    print("Ad will present screen.")
  }

  func swipeableInterstitialAdWillDismissScreen(_ ad: SwipeableInterstitialAd) {
    print("Ad will dismiss screen.")
  }

  func swipeableInterstitialAdDidDismissScreen(_ ad: SwipeableInterstitialAd) {
    print("Ad did dismiss screen.")
    checkScreenHold()
  }

  func videoControllerDidPlayVideo(_ videoController: VideoController) {
    // Optional: Pause any app video content when the ad video plays.
    print("Video started playing.")
  }

  func videoControllerDidEndVideoPlayback(_ videoController: VideoController) {
    // Optional: Resume app video content or handle video completion.
    print("Video ended.")
  }
}
