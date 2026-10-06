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

#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <GoogleMobileAds/GoogleMobileAds_Beta.h>

NS_ASSUME_NONNULL_BEGIN

/// Singleton class that loads, manages lifecycle, and handles events for squeezeback ads.
@interface SqueezebackAdManager : NSObject <GADSqueezebackAdDelegate>

@property(class, nonatomic, readonly, strong) SqueezebackAdManager *sharedInstance;

@property(nonatomic, readonly, nullable) GADSqueezebackAd *squeezebackAd;

@property(nonatomic, copy, nullable) void (^onAdShownListener)(void);
@property(nonatomic, copy, nullable) void (^onAdHiddenListener)(void);

/// Loads a squeezeback ad.
- (void)loadAdWithCompletionHandler:(nullable void (^)(GADSqueezebackAd *_Nullable ad,
                                                       NSError *_Nullable error))completionHandler;

/// Shows the squeezeback ad.
- (void)showAd;

/// Hides the currently showing squeezeback ad.
- (void)hideAd;

/// Destroys the squeezeback ad and cleans up resources.
- (void)destroyAd;

/// Checks if an ad exists and is available to show.
- (BOOL)isAdAvailable;

@end

NS_ASSUME_NONNULL_END
