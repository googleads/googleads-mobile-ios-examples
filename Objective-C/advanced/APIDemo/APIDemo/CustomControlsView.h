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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

/// A custom view which encapsulates the display of video controller related information and also
/// custom video controls. Set the video options when requesting an ad, then set the video
/// controller when the ad is received.
@interface CustomControlsView : UIView<GADVideoControllerDelegate>

/// Resets the controls status, and lets the controls view know the initial mute state.
- (void)resetWithStartMuted:(BOOL)startMuted;

/// The controller for the ad currently being displayed. Setting this sets up the view according to
/// the video controller state.
@property(nonatomic, weak) GADVideoController *controller;

@end
