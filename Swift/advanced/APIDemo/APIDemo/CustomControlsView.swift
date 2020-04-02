//
//  Copyright (C) 2018 Google, Inc.
//
//  CustomControlsView.h
//  APIDemo
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
import Foundation
import GoogleMobileAds
import UIKit

/// A custom view which encapsulates the display of video controller related information and also
/// custom video controls. Set the video options when requesting an ad, then set the video
/// controller when the ad is received.
class CustomControlsView: UIView {
  /// Resets the controls status, and lets the controls view know the initial mute state.
  /// The controller for the ad currently being displayed. Setting this sets up the view according to
  /// the video controller state.
  weak var controller: GADVideoController? {
    didSet {
      if let controller = controller {
        controlsView.isHidden = !controller.customControlsEnabled()
        controller.delegate = self
        videoStatusLabel.text =
          controller.hasVideoContent()
          ? "Ad contains video content." : "Ad does not contain video content."
      } else {
        controlsView.isHidden = true
        videoStatusLabel.text = ""
      }
    }
  }

  /// The container view for the actual video controls
  @IBOutlet weak var controlsView: UIView!
  /// The play button.
  @IBOutlet weak var playButton: UIButton!
  /// The mute button.
  @IBOutlet weak var muteButton: UIButton!
  /// The label showing the video status for the current video controller.
  @IBOutlet weak var videoStatusLabel: UILabel!

  /// Boolean reflecting current playback state for UI.
  private var _isPlaying = false
  var isPlaying: Bool {
    get {
      return _isPlaying
    }
    set(playing) {
      _isPlaying = playing
      let title: String = _isPlaying ? "Pause" : "Play"
      playButton.setTitle(title, for: .normal)
    }
  }

  /// Boolean reflecting current mute state for UI.
  private var _isMuted = false
  var isMuted: Bool {
    get {
      return _isMuted
    }
    set(muted) {
      if muted != isMuted {
        let title: String = muted ? "Unmute" : "Mute"
        muteButton.setTitle(title, for: .normal)
      }
      _isMuted = muted
    }
  }

  func reset(withStartMuted startMuted: Bool) {
    isMuted = startMuted
    isPlaying = false
    controlsView.isHidden = true
    videoStatusLabel.text = ""
  }

  @IBAction func playPause(_ sender: Any) {
    if isPlaying {
      controller?.pause()
    } else {
      controller?.play()
    }
  }
  @IBAction func muteUnmute(_ sender: Any) {
    isMuted = !isMuted
    controller?.setMute(isMuted)
  }
}

extension CustomControlsView: GADVideoControllerDelegate {
  func videoControllerDidPlayVideo(_ videoController: GADVideoController) {
    videoStatusLabel.text = "Video did play."
    print("\(#function)")
    isPlaying = true
  }
  func videoControllerDidPauseVideo(_ videoController: GADVideoController) {
    videoStatusLabel.text = "Video did pause."
    print("\(#function)")
    isPlaying = false
  }
  func videoControllerDidMuteVideo(_ videoController: GADVideoController) {
    videoStatusLabel.text = "Video has muted."
    print("\(#function)")
    isMuted = true
  }
  func videoControllerDidUnmuteVideo(_ videoController: GADVideoController) {
    videoStatusLabel.text = "Video has unmuted."
    print("\(#function)")
    isMuted = false
  }
  func videoControllerDidEndVideoPlayback(_ videoController: GADVideoController) {
    videoStatusLabel.text = "Video playback has ended."
    print("\(#function)")
    isPlaying = false
  }
}
