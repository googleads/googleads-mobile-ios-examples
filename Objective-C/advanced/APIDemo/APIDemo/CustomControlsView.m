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

#import "CustomControlsView.h"

@interface CustomControlsView ()
/// Boolean reflecting current playback state for UI.
@property(nonatomic) BOOL playing;

/// Boolean reflecting current mute state for UI.
@property(nonatomic) BOOL muted;

/// The container view for the actual video controls
@property(nonatomic, weak) IBOutlet UIView *controlsView;

/// The play button.
@property(nonatomic, weak) IBOutlet UIButton *playButton;

/// The mute button.
@property(nonatomic, weak) IBOutlet UIButton *muteButton;

@end

@implementation CustomControlsView

- (void)resetWithStartMuted:(BOOL)startMuted {
  self.playing = NO;
  self.controlsView.hidden = YES;
  self.muted = startMuted;
  UIImage *image =
      startMuted ? [UIImage imageNamed:@"video_mute"] : [UIImage imageNamed:@"video_unmute"];
  [self.muteButton setImage:image forState:UIControlStateNormal];
}

- (void)setMediaContent:(GADMediaContent *)mediaContent {
  _mediaContent = mediaContent;
  self.controlsView.hidden = !_mediaContent.videoController.customControlsEnabled;
  _mediaContent.videoController.delegate = self;
}

- (IBAction)playPause:(id)sender {
  if (self.playing) {
    [self.mediaContent.videoController pause];
  } else {
    [self.mediaContent.videoController play];
  }
}

- (IBAction)muteUnmute:(id)sender {
  self.muted = !self.muted;
  [self.mediaContent.videoController setMute:self.muted];
}

- (void)setPlaying:(BOOL)playing {
  if ((!playing && self.playing) || (playing && !self.playing)) {
    UIImage *image =
        playing ? [UIImage imageNamed:@"video_pause"] : [UIImage imageNamed:@"video_play"];
    [self.playButton setImage:image forState:UIControlStateNormal];
  }
  _playing = playing;
}

- (void)setMuted:(BOOL)muted {
  if ((!muted && self.muted) || (muted && !self.muted)) {
    UIImage *image =
        muted ? [UIImage imageNamed:@"video_mute"] : [UIImage imageNamed:@"video_unmute"];
    [self.muteButton setImage:image forState:UIControlStateNormal];
  }
  _muted = muted;
}

#pragma mark - GADVideoControllerDelegate

- (void)videoControllerDidPlayVideo:(GADVideoController *)videoController {
  NSLog(@"%@", @(__PRETTY_FUNCTION__));
  self.playing = YES;
}

- (void)videoControllerDidPauseVideo:(GADVideoController *)videoController {
  NSLog(@"%@", @(__PRETTY_FUNCTION__));
  self.playing = NO;
}

- (void)videoControllerDidMuteVideo:(GADVideoController *)videoController {
  NSLog(@"%@", @(__PRETTY_FUNCTION__));
  self.muted = YES;
}

- (void)videoControllerDidUnmuteVideo:(GADVideoController *)videoController {
  NSLog(@"%@", @(__PRETTY_FUNCTION__));
  self.muted = NO;
}

- (void)videoControllerDidEndVideoPlayback:(GADVideoController *)videoController {
  NSLog(@"%@", @(__PRETTY_FUNCTION__));
  self.playing = NO;
}

@end
