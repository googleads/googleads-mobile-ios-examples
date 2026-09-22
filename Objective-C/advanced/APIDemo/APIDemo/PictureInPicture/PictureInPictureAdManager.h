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

/// Singleton class that loads, manages lifecycle, and handles events for Picture-in-Picture (PiP)
/// ads.
@interface PictureInPictureAdManager : NSObject <GADPictureInPictureAdDelegate>

@property(class, nonatomic, readonly, strong) PictureInPictureAdManager *sharedInstance;

@property(nonatomic, readonly, nullable) GADPictureInPictureAd *pipAd;

@property(nonatomic, copy, nullable) void (^onAdShownListener)(void);
@property(nonatomic, copy, nullable) void (^onAdHiddenListener)(void);

/// Loads a Picture-in-Picture ad.
- (void)loadAdWithCompletionHandler:(nullable void (^)(GADPictureInPictureAd *_Nullable ad,
                                                       NSError *_Nullable error))completionHandler;

/// Shows the Picture-in-Picture ad with the provided options.
- (void)showAdWithOptions:(GADPictureInPictureAdOptions *)options;

/// Hides the currently showing Picture-in-Picture ad.
- (void)hideAd;

/// Destroys the Picture-in-Picture ad and cleans up resources.
- (void)destroyAd;

/// Checks if an ad exists and is available to show.
- (BOOL)isAdAvailable;

@end

NS_ASSUME_NONNULL_END
