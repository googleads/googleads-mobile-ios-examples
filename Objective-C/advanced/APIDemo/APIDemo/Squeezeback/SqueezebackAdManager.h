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

@class SqueezebackAdManager;

/// Delegate protocol for receiving squeezeback ad presentation state updates.
@protocol SqueezebackAdManagerDelegate <NSObject>

/// Tells the delegate that the squeezeback ad was shown on screen.
- (void)squeezebackAdManagerDidShowAd:(SqueezebackAdManager *)manager;

/// Tells the delegate that the squeezeback ad was hidden or dismissed.
- (void)squeezebackAdManagerDidHideAd:(SqueezebackAdManager *)manager;

/// Tells the delegate that the squeezeback ad failed to show on screen.
- (void)squeezebackAdManager:(SqueezebackAdManager *)manager
    didFailToShowAdWithError:(NSError *)error;

@end

/// Singleton class that loads, manages lifecycle, and handles events for squeezeback ads.
@interface SqueezebackAdManager : NSObject <GADSqueezebackAdDelegate>

@property(class, nonatomic, readonly, strong) SqueezebackAdManager *sharedInstance;

@property(nonatomic, readonly, nullable) GADSqueezebackAd *squeezebackAd;

@property(nonatomic, readonly, getter=isAdShowing) BOOL adShowing;

@property(nonatomic, weak, nullable) id<SqueezebackAdManagerDelegate> delegate;

/// Loads a squeezeback ad.
- (void)loadAdWithCompletionHandler:(nullable void (^)(GADSqueezebackAd *_Nullable ad,
                                                       NSError *_Nullable error))completionHandler;

/// Shows the squeezeback ad.
- (void)showAd;

/// Hides the currently showing squeezeback ad.
- (void)hideAd;

/// Destroys the squeezeback ad and cleans up resources.
- (void)destroyAd;

/// Checks if an ad is loaded and available to show.
- (BOOL)isAdAvailable;

@end

NS_ASSUME_NONNULL_END
