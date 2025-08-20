//
//  Copyright (C) 2025 Google, Inc.
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
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// Replace this ad unit ID with your own ad unit ID.
static NSString *const nativeAdUnitID = @"ca-app-pub-3940256099942544/3986624511";

@interface NativeAdOptionsSnippets : UIViewController <GADNativeAdDelegate>
// The ad loader.
@property(nonatomic, strong) GADAdLoader *adLoader;
@end

@implementation NativeAdOptionsSnippets

- (void)setMediaAspectRatio {
  // [START set_media_aspect_ratio]
  GADNativeAdMediaAdLoaderOptions *nativeOptions = [[GADNativeAdMediaAdLoaderOptions alloc] init];
  nativeOptions.mediaAspectRatio = GADMediaAspectRatioAny;

  self.adLoader = [[GADAdLoader alloc] initWithAdUnitID:nativeAdUnitID
                                     rootViewController:self
                                                adTypes:@[ GADAdLoaderAdTypeNative ]
                                                options:@[ nativeOptions ]];
  // [END set_media_aspect_ratio]
}

- (void)setDisableImageLoading {
  // [START set_disable_image_loading]
  GADNativeAdImageAdLoaderOptions *nativeOptions = [[GADNativeAdImageAdLoaderOptions alloc] init];
  nativeOptions.disableImageLoading = YES;

  self.adLoader = [[GADAdLoader alloc] initWithAdUnitID:nativeAdUnitID
                                     rootViewController:self
                                                adTypes:@[ GADAdLoaderAdTypeNative ]
                                                options:@[ nativeOptions ]];
  // [END set_disable_image_loading]
}

- (void)setRequestMultipleImages {
  // [START set_request_multiple_images]
  GADNativeAdImageAdLoaderOptions *nativeOptions = [[GADNativeAdImageAdLoaderOptions alloc] init];
  nativeOptions.shouldRequestMultipleImages = YES;

  self.adLoader = [[GADAdLoader alloc] initWithAdUnitID:nativeAdUnitID
                                     rootViewController:self
                                                adTypes:@[ GADAdLoaderAdTypeNative ]
                                                options:@[ nativeOptions ]];
  // [END set_request_multiple_images]
}

- (void)setAdChoicesPosition {
  // [START set_ad_choices_position]
  GADNativeAdViewAdOptions *nativeOptions = [[GADNativeAdViewAdOptions alloc] init];
  nativeOptions.preferredAdChoicesPosition = GADAdChoicesPositionTopRightCorner;

  self.adLoader = [[GADAdLoader alloc] initWithAdUnitID:nativeAdUnitID
                                     rootViewController:self
                                                adTypes:@[ GADAdLoaderAdTypeNative ]
                                                options:@[ nativeOptions ]];
  // [END set_ad_choices_position]
}

// [START create_ad_choices_view]
- (void)createAdChoicesViewWithNativeAdView:(GADNativeAdView *)nativeAdView {
  // Define a custom position for the AdChoices icon.
  CGRect customRect = CGRectMake(100, 100, 15, 15);
  GADAdChoicesView *customAdChoicesView = [[GADAdChoicesView alloc] initWithFrame:customRect];
  [nativeAdView addSubview:customAdChoicesView];
  nativeAdView.adChoicesView = customAdChoicesView;
}
// [END create_ad_choices_view]

- (void)setMuted {
  // [START set_muted]
  GADVideoOptions *videoOptions = [[GADVideoOptions alloc] init];
  videoOptions.startMuted = NO;

  self.adLoader = [[GADAdLoader alloc] initWithAdUnitID:nativeAdUnitID
                                     rootViewController:self
                                                adTypes:@[ GADAdLoaderAdTypeNative ]
                                                options:@[ videoOptions ]];
  // [END set_muted]
}

- (void)setRequestCustomPlaybackControls {
  // [START set_request_custom_playback_controls]
  GADVideoOptions *videoOptions = [[GADVideoOptions alloc] init];
  videoOptions.customControlsRequested = YES;

  self.adLoader = [[GADAdLoader alloc] initWithAdUnitID:nativeAdUnitID
                                     rootViewController:self
                                                adTypes:@[ GADAdLoaderAdTypeNative ]
                                                options:@[ videoOptions ]];
  // [END set_request_custom_playback_controls]
}

// [START check_custom_controls_enabled]
- (BOOL)checkCustomControlsEnabledWithNativeAd:(GADNativeAd *)nativeAd {
  GADVideoController *videoController = nativeAd.mediaContent.videoController;
  return videoController.customControlsEnabled;
}
// [END check_custom_controls_enabled]

- (void)setCustomSwipeGesture {
  // [START set_custom_swipe_gesture]
  GADNativeAdCustomClickGestureOptions *swipeGestureOptions =
      [[GADNativeAdCustomClickGestureOptions alloc]
          initWithSwipeGestureDirection:UISwipeGestureRecognizerDirectionRight
                            tapsAllowed:YES];

  self.adLoader = [[GADAdLoader alloc] initWithAdUnitID:nativeAdUnitID
                                     rootViewController:self
                                                adTypes:@[ GADAdLoaderAdTypeNative ]
                                                options:@[ swipeGestureOptions ]];
  // [END set_custom_swipe_gesture]
}

#pragma mark - GADNativeAdDelegate

// [START custom_swipe_gesture_delegate]
// Called when a swipe gesture click is recorded, as configured in
// GADNativeAdCustomClickGestureOptions.
- (void)nativeAdDidRecordSwipeGestureClick:(GADNativeAd *)nativeAd {
  NSLog(@"A swipe gesture click has occurred.");
}

// Called when a swipe gesture click or a tap click is recorded.
- (void)nativeAdDidRecordClick:(GADNativeAd *)nativeAd {
  NSLog(@"A swipe gesture click or tap click has occurred.");
}
// [END custom_swipe_gesture_delegate]

NS_ASSUME_NONNULL_END

@end
