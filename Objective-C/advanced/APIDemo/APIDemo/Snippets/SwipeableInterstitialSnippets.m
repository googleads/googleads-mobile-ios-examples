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

#import <GoogleMobileAds/GoogleMobileAds.h>
#import <GoogleMobileAds/GoogleMobileAds_Beta.h>
#import <UIKit/UIKit.h>

static NSString *const kAdUnitID = @"ca-app-pub-3940256099942544/2737863066";

/// Objective-C code snippets for swipeable interstitial ad lifecycle events.
@interface SwipeableInterstitialSnippets : NSObject <GADSwipeableInterstitialAdDelegate>
// [START swipeable_interstitial_reference]
// The swipeable interstitial ad object must be maintained as a strong reference
// while the ad is on screen. If released early, impression tracking and click
// handling will be lost.
@property(nonatomic, strong) GADSwipeableInterstitialAd *swipeableInterstitialAd;
// [END swipeable_interstitial_reference]
@end

@interface SwipeableInterstitialSnippets (Video) <GADVideoControllerDelegate>
- (void)registerVideoControllerDelegate;
@end

@implementation SwipeableInterstitialSnippets (Video)

- (void)registerVideoControllerDelegate {
  // [START set_video_controller_delegate]
  self.swipeableInterstitialAd.videoControllerDelegate = self;
  // [END set_video_controller_delegate]
}

// [START video_controller_delegate]
- (void)videoControllerDidPlayVideo:(GADVideoController *)videoController {
  // Optional: Pause any app video content when the ad video plays.
  NSLog(@"Video started playing.");
}

- (void)videoControllerDidEndVideoPlayback:(GADVideoController *)videoController {
  // Optional: Resume app video content or handle video completion.
  NSLog(@"Video ended.");
}
// [END video_controller_delegate]

@end

@implementation SwipeableInterstitialSnippets

- (void)registerAdEventCallbacks {
  // [START set_the_delegate]
  self.swipeableInterstitialAd.delegate = self;
  // [END set_the_delegate]
}

// [START register_ad_event_callbacks]
- (void)swipeableInterstitialAdDidRecordImpression:(GADSwipeableInterstitialAd *)ad {
  NSLog(@"Ad recorded an impression.");
}

- (void)swipeableInterstitialAdDidRecordClick:(GADSwipeableInterstitialAd *)ad {
  NSLog(@"Ad recorded a click.");
}

- (void)swipeableInterstitialAdWillPresentScreen:(GADSwipeableInterstitialAd *)ad {
  NSLog(@"Ad will present full screen view.");
}

- (void)swipeableInterstitialAdWillDismissScreen:(GADSwipeableInterstitialAd *)ad {
  NSLog(@"Ad will dismiss full screen view.");
}

- (void)swipeableInterstitialAdDidDismissScreen:(GADSwipeableInterstitialAd *)ad {
  NSLog(@"Ad dismissed full screen view.");
}
// [END register_ad_event_callbacks]

// [START swipeable_interstitial_load]
- (void)loadSwipeableInterstitialAd {
  GADRequest *request = [GADRequest request];
  [GADSwipeableInterstitialAd
       loadWithAdUnitID:kAdUnitID
                request:request
                options:nil
      completionHandler:^(GADSwipeableInterstitialAd *_Nullable ad, NSError *_Nullable error) {
        if (error) {
          NSLog(@"Failed to load swipeable interstitial: %@.", error);
          return;
        }
        self.swipeableInterstitialAd = ad;
      }];
}
// [END swipeable_interstitial_load]

// [START swipeable_interstitial_options_screen_hold]
- (GADSwipeableInterstitialAdOptions *)
    swipeableInterstitialAdOptionsWithMaxScreenHoldDuration:
        (NSTimeInterval)maxScreenHoldDuration {
  GADSwipeableInterstitialAdOptions *options = [[GADSwipeableInterstitialAdOptions alloc] init];
  options.maxScreenHoldDuration = maxScreenHoldDuration;
  return options;
}
// [END swipeable_interstitial_options_screen_hold]

// [START show_swipeable_interstitial]
- (void)showSwipeableInterstitialAd:(GADSwipeableInterstitialAd *)ad
                 fromViewController:(UIViewController *)viewController {
  // Add the swipeable interstitial ad view to your swipeable container.
  if (ad.adView) {
    ad.rootViewController = viewController;
    [viewController.view addSubview:ad.adView];
  }
}
// [END show_swipeable_interstitial]

// [START check_min_screen_hold_duration]
- (void)holdScreen {
  GADSwipeableInterstitialAd *ad = self.swipeableInterstitialAd;
  if (!ad || ad.minScreenHoldDuration <= 0.0) {
    return;
  }

  // Disable scrolling during screen hold.
  [self disableScrolling];

  // Post a delayed action to unlock the interface once elapsed.
  __weak __typeof__(self) weakSelf = self;
  int64_t delay = (int64_t)(ad.minScreenHoldDuration * NSEC_PER_SEC);
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay), dispatch_get_main_queue(), ^{
    [weakSelf enableScrolling];
  });
}

- (void)disableScrolling {
  // TODO: Disable scrolling.
}

- (void)enableScrolling {
  // TODO: Enable scrolling.
}
// [END check_min_screen_hold_duration]

// [START register_screen_hold_callback]
- (void)swipeableInterstitialAdDidStartScreenHoldTimer:(GADSwipeableInterstitialAd *)ad {
  NSLog(@"GMA SDK detected a swipeable interstitial ad screen hold.");
}
// [END register_screen_hold_callback]

- (void)setCustomClickGesture {
  // [START set_custom_click_gesture]
  // Optional: Custom click gestures require a separate allowlisting with your
  // account manager. This feature is intended for apps that use swipe gestures
  // to click on content.
  GADSwipeableInterstitialAdOptions *options = [[GADSwipeableInterstitialAdOptions alloc] init];
  [options enableCustomClickSwipeGestureWithDirection:UISwipeGestureRecognizerDirectionRight
                                          tapsAllowed:YES];
  // [END set_custom_click_gesture]
}

// [START swipeable_interstitial_options_ad_size]
- (GADSwipeableInterstitialAdOptions *)swipeableInterstitialAdOptionsWithAdSize:(CGSize)adSize {
  GADSwipeableInterstitialAdOptions *options = [[GADSwipeableInterstitialAdOptions alloc] init];
  // Optional: Overrides the default fullscreen size with a custom size.
  // Custom ad sizes must fill at least 60% of the screen size.
  options.adSize = adSize;
  return options;
}
// [END swipeable_interstitial_options_ad_size]

- (void)discardAd {
  // [START discard_swipeable_interstitial]
  self.swipeableInterstitialAd = nil;
  // [END discard_swipeable_interstitial]
}

@end

// CI Kick

// CI Kick
