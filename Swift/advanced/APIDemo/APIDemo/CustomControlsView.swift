// Copyright 2024 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation
import GoogleMobileAds
import UIKit

/// A custom view which encapsulates the display of video controller related information and also
/// custom video controls. Set the video options when requesting an ad, then set the video
/// controller when the ad is received.
class CustomControlsView: UIView {

  /// The play button.
  @IBOutlet weak var playButton: UIButton!
  /// The mute button.
  @IBOutlet weak var muteButton: UIButton!

  /// Resets the controls status, and lets the controls view know the initial mute state.
  /// The controller for the ad currently being displayed. Setting this sets up the view according
  /// to the video controller state.
  weak var mediaContent: GADMediaContent? {
    didSet {
      if let mediaContent = mediaContent {
        self.isHidden = !mediaContent.videoController.customControlsEnabled()
        mediaContent.videoController.delegate = self
      } else {
        self.isHidden = true
      }
    }
  }

  /// Boolean reflecting current playback state for UI.
  var isPlaying = false {
    didSet {
      let image =
        isPlaying ? UIImage(named: "video_pause") : UIImage(named: "video_play")
      playButton.setImage(image, for: .normal)
    }
  }

  /// Boolean reflecting current mute state for UI.
  var isMuted: Bool? = false {
    didSet {
      let image =
        isMuted == true ? UIImage(named: "video_mute") : UIImage(named: "video_unmute")
      muteButton.setImage(image, for: .normal)
    }
  }

  func reset(withStartMuted startMuted: Bool) {
    isMuted = startMuted
    isPlaying = false
    self.isHidden = true
  }

  @IBAction func playPause(_ sender: Any) {
    guard let mediaContent = mediaContent else {
      return
    }
    if isPlaying {
      mediaContent.videoController.pause()
    } else {
      mediaContent.videoController.play()
    }
  }

  @IBAction func muteUnmute(_ sender: Any) {
    if let mediaContent = mediaContent {
      mediaContent.videoController.setMute(!mediaContent.videoController.isMuted)
    }
  }
}

extension CustomControlsView: GADVideoControllerDelegate {
  func videoControllerDidPlayVideo(_ videoController: GADVideoController) {
    print("\(#function)")
    isPlaying = true
  }
  func videoControllerDidPauseVideo(_ videoController: GADVideoController) {
    print("\(#function)")
    isPlaying = false
  }
  func videoControllerDidMuteVideo(_ videoController: GADVideoController) {
    print("\(#function)")
    isMuted = true
  }
  func videoControllerDidUnmuteVideo(_ videoController: GADVideoController) {
    print("\(#function)")
    isMuted = false
  }
  func videoControllerDidEndVideoPlayback(_ videoController: GADVideoController) {
    print("\(#function)")
    isPlaying = false
  }
}
