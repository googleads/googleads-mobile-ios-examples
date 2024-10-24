//
//  Copyright 2024 Google LLC
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

#import <GoogleMobileAds/GADMobileAds.h>
#import <GoogleMobileAds/GADRewardedAd.h>

@interface GADRewardedAd ()

/// Returns if a rewarded ad is preloaded for the given ad unit ID.
+ (BOOL)isPreloadedAdAvailable:(nonnull NSString *)adUnitID;

/// Returns a rewarded ad associated with the ad unit ID. Returns nil if
/// an ad is not available.
+ (nullable GADRewardedAd *)preloadedAdWithAdUnitID:(nonnull NSString *)adUnitID;

@end
