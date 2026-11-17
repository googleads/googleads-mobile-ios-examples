//
//  Copyright (C) 2026 Google, Inc.
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

#import <UIKit/UIKit.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

NS_ASSUME_NONNULL_BEGIN

// Replace this ad unit ID with your own ad unit ID.
static NSString *const kNativeAdUnitID = @"/21775744923/example/native";

// Demonstrates how to use custom click gesture options for native ads in Google Ad Manager.
@interface AdManagerNativeAdOptionsSnippets : UIViewController <GADNativeAdDelegate>
// The ad loader.
@property(nonatomic, strong) GADAdLoader *adLoader;
@end

@implementation AdManagerNativeAdOptionsSnippets

// Sets up a GADAdLoader with custom swipe gesture options.
- (void)setCustomSwipeGesture {
  // [START set_custom_swipe_gesture]
  GADNativeAdCustomClickGestureOptions *swipeGestureOptions =
      [[GADNativeAdCustomClickGestureOptions alloc]
          initWithSwipeGestureDirection:UISwipeGestureRecognizerDirectionRight
                            tapsAllowed:YES];

  self.adLoader = [[GADAdLoader alloc] initWithAdUnitID:kNativeAdUnitID
                                     rootViewController:self
                                                adTypes:@[ GADAdLoaderAdTypeNative ]
                                                options:@[ swipeGestureOptions ]];
  // [END set_custom_swipe_gesture]
}

#pragma mark - GADNativeAdDelegate

// Called when a swipe gesture click is recorded, as configured in
// GADNativeAdCustomClickGestureOptions.
// [START custom_swipe_gesture_delegate]
- (void)nativeAdDidRecordSwipeGestureClick:(GADNativeAd *)nativeAd {
  NSLog(@"A swipe gesture click has occurred.");
}

// Called when a swipe gesture click or a tap click is recorded.
- (void)nativeAdDidRecordClick:(GADNativeAd *)nativeAd {
  NSLog(@"A swipe gesture click or tap click has occurred.");
}
// [END custom_swipe_gesture_delegate]

@end

NS_ASSUME_NONNULL_END
