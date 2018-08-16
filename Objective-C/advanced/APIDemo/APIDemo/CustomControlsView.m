//
//  Copyright (C) 2018 Google, Inc.
//
//  CustomControlsView.m
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

/// The label showing the video status for the current video controller.
@property(nonatomic, weak) IBOutlet UILabel *videoStatusLabel;

@end

@implementation CustomControlsView

- (void)resetWithStartMuted:(BOOL)startMuted {
  self.muted = startMuted;
  self.playing = NO;
  self.controlsView.hidden = YES;
  self.videoStatusLabel.text = @"";
}

- (void)setController:(GADVideoController *)controller {
  _controller = controller;
  self.controlsView.hidden = !controller.customControlsEnabled;
  controller.delegate = self;
  self.videoStatusLabel.text = controller.hasVideoContent ? @"Ad contains video content."
                                                          : @"Ad does not contain video content.";
}

- (IBAction)playPause:(id)sender {
  if (self.playing) {
    [self.controller pause];
  } else {
    [self.controller play];
  }
}

- (IBAction)muteUnmute:(id)sender {
  self.muted = !self.muted;
  [self.controller setMute:self.muted];
}

- (void)setPlaying:(BOOL)playing {
  if (playing != self.playing) {
    NSString *title = playing ? @"Pause" : @"Play";
    [self.playButton setTitle:title forState:UIControlStateNormal];
  }
  _playing = playing;
}

- (void)setMuted:(BOOL)muted {
  if (muted != self.muted) {
    NSString *title = muted ? @"Unmute" : @"Mute";
    [self.muteButton setTitle:title forState:UIControlStateNormal];
  }
  _muted = muted;
}

#pragma mark - GADVideoControllerDelegate

- (void)videoControllerDidPlayVideo:(GADVideoController *)videoController {
  self.videoStatusLabel.text = @"Video did play.";
  NSLog(@"%@", @(__PRETTY_FUNCTION__));
  self.playing = YES;
}

- (void)videoControllerDidPauseVideo:(GADVideoController *)videoController {
  self.videoStatusLabel.text = @"Video did pause.";
  NSLog(@"%@", @(__PRETTY_FUNCTION__));
  self.playing = NO;
}

- (void)videoControllerDidMuteVideo:(GADVideoController *)videoController {
  self.videoStatusLabel.text = @"Video has muted.";
  NSLog(@"%@", @(__PRETTY_FUNCTION__));
  self.muted = YES;
}

- (void)videoControllerDidUnmuteVideo:(GADVideoController *)videoController {
  self.videoStatusLabel.text = @"Video has unmuted.";
  NSLog(@"%@", @(__PRETTY_FUNCTION__));
  self.muted = NO;
}

- (void)videoControllerDidEndVideoPlayback:(GADVideoController *)videoController {
  self.videoStatusLabel.text = @"Video playback has ended.";
  NSLog(@"%@", @(__PRETTY_FUNCTION__));
  self.playing = NO;
}

@end
