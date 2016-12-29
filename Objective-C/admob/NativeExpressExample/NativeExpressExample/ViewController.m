// Copyright (C) 2016 Google, Inc.
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

#import "ViewController.h"

@import GoogleMobileAds;

// This is a test ad unit, which serves test ads automatically.
static NSString *const AdUnitId = @"ca-app-pub-3940256099942544/8897359316";

@interface ViewController () <GADNativeExpressAdViewDelegate, GADVideoControllerDelegate>

/// The native express ad view in which the ad is displayed.
@property(nonatomic, weak) IBOutlet GADNativeExpressAdView *nativeExpressAdView;

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.nativeExpressAdView.adUnitID = AdUnitId;
  self.nativeExpressAdView.rootViewController = self;
  self.nativeExpressAdView.delegate = self;

  // The video options object can be used to control the initial mute state of video assets.
  // By default, they start muted.
  GADVideoOptions *videoOptions = [[GADVideoOptions alloc] init];
  videoOptions.startMuted = true;
  [self.nativeExpressAdView setAdOptions:@[ videoOptions ]];

  // Set this UIViewController as the video controller delegate, so it will be notified of events
  // in the video lifecycle.
  self.nativeExpressAdView.videoController.delegate = self;

  GADRequest *request = [GADRequest request];
  [self.nativeExpressAdView loadRequest:request];
}

#pragma mark - GADNativeExpressAdViewDelegate

- (void)nativeExpressAdViewDidReceiveAd:(GADNativeExpressAdView *)nativeExpressAdView {
  if (nativeExpressAdView.videoController.hasVideoContent) {
    NSLog(@"Received ad an with a video asset.");
  } else {
    NSLog(@"Received ad an without a video asset.");
  }
}

#pragma mark - GADVideoControllerDelegate

- (void)videoControllerDidEndVideoPlayback:(GADVideoController *)videoController {
  NSLog(@"Playback has ended for this ad's video asset.");
}

@end
