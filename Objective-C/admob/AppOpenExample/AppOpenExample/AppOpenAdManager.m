//
//  Copyright 2021 Google LLC
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "AppOpenAdManager.h"

#import "GoogleMobileAdsConsentManager.h"

/// Ad references in the app open beta will time out after four hours, but this time limit
/// may change in future beta versions. For details, see:
/// https://support.google.com/admob/answer/9341964?hl=en
static const NSInteger TimeoutInterval = 4;

@interface AppOpenAdManager ()

@end

@implementation AppOpenAdManager {
  /// The app open ad.
  GADAppOpenAd *_appOpenAd;
  /// Keeps track of if an app open ad is loading.
  BOOL _isLoadingAd;
  /// Keeps track of if an app open ad is showing.
  BOOL _isShowingAd;
  /// Keeps track of the time when an app open ad was loaded to discard expired ad.
  NSDate *_loadTime;
}

+ (nonnull AppOpenAdManager *)sharedInstance {
  static AppOpenAdManager *instance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[AppOpenAdManager alloc] init];
  });
  return instance;
}

- (BOOL)wasLoadTimeLessThanNHoursAgo:(int)n {
  // Check if ad was loaded more than n hours ago.
  NSDate *now = [NSDate date];
  NSTimeInterval timeIntervalBetweenNowAndLoadTime = [now timeIntervalSinceDate:_loadTime];
  double secondsPerHour = 3600.0;
  double intervalInHours = timeIntervalBetweenNowAndLoadTime / secondsPerHour;
  return intervalInHours < n;
}

- (BOOL)isAdAvailable {
  // Check if ad exists and can be shown.
  return _appOpenAd && [self wasLoadTimeLessThanNHoursAgo:TimeoutInterval];
}

- (void)adDidComplete {
  // The app open ad is considered to be complete when it dismisses or fails to show,
  // call the delegate's adDidComplete method if the delegate is not nil.
  if (!_delegate) {
    return;
  }
  [_delegate adDidComplete];
  _delegate = nil;
}

- (void)loadAd {
  // Do not load ad if there is an unused ad or one is already loading.
  if ([self isAdAvailable] || _isLoadingAd) {
    return;
  }
  _isLoadingAd = YES;
  NSLog(@"Start loading app open ad.");
  [GADAppOpenAd loadWithAdUnitID:@"ca-app-pub-3940256099942544/5575463023"
                         request:[GADRequest request]
                     orientation:UIInterfaceOrientationPortrait
               completionHandler:^(GADAppOpenAd * _Nullable appOpenAd, NSError * _Nullable error) {
    self->_isLoadingAd = NO;
    if (error) {
      self->_appOpenAd = nil;
      self->_loadTime = nil;
      NSLog(@"App open ad failed to load with error: %@", error);
      return;
    }
    self->_appOpenAd = appOpenAd;
    self->_appOpenAd.fullScreenContentDelegate = self;
    self->_loadTime = [NSDate date];
    NSLog(@"App open ad loaded successfully.");
  }];
}

- (void)showAdIfAvailable:(nonnull UIViewController *)viewController {
  // If the app open ad is already showing, do not show the ad again.
  if (_isShowingAd) {
    NSLog(@"App open ad is already showing.");
    return;
  }
  // If the app open ad is not available yet but it is supposed to show,
  // it is considered to be complete in this example. Call the adDidComplete method
  // and load a new ad.
  if (![self isAdAvailable]) {
    NSLog(@"App open ad is not ready yet.");
    [self adDidComplete];
    if ([GoogleMobileAdsConsentManager.sharedInstance canRequestAds]) {
      [self loadAd];
    }
    return;
  }
  NSLog(@"App open ad will be displayed.");
  _isShowingAd = YES;
  [_appOpenAd presentFromRootViewController:viewController];
}

#pragma mark - GADFullScreenContentDelegate

/// Tells the delegate that the ad will present full screen content.
- (void)adWillPresentFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
  NSLog(@"App open ad is will be presented.");
}

/// Tells the delegate that the ad dismissed full screen content.
- (void)adDidDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
  _appOpenAd = nil;
  _isShowingAd = NO;
  NSLog(@"App open ad was dismissed.");
  [self adDidComplete];
  [self loadAd];
}

/// Tells the delegate that the ad failed to present full screen content.
- (void)ad:(nonnull id<GADFullScreenPresentingAd>)ad
    didFailToPresentFullScreenContentWithError:(nonnull NSError *)error {
  _appOpenAd = nil;
  _isShowingAd = NO;
  NSLog(@"App open ad failed to present with error: %@", error.localizedDescription);
  [self adDidComplete];
  [self loadAd];
}

@end
