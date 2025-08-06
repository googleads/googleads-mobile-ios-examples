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

// [START app_open_ad_manager]
@interface AppOpenAdManager ()

/// The app open ad.
@property(nonatomic, strong, nullable) GADAppOpenAd *appOpenAd;
/// Keeps track of if an app open ad is loading.
@property(nonatomic, assign) BOOL isLoadingAd;
/// Keeps track of if an app open ad is showing.
@property(nonatomic, assign) BOOL isShowingAd;
/// Keeps track of the time when an app open ad was loaded to discard expired ad.
@property(nonatomic, strong, nullable) NSDate *loadTime;

@end

/// For more interval details, see https://support.google.com/admob/answer/9341964
static const NSInteger kTimeoutInterval = 4;

@implementation AppOpenAdManager

+ (nonnull AppOpenAdManager *)sharedInstance {
  static AppOpenAdManager *instance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[AppOpenAdManager alloc] init];
  });
  return instance;
}
// [END app_open_ad_manager]

// [START ad_expiration]
- (BOOL)wasLoadTimeLessThanNHoursAgo:(int)n {
  // Check if ad was loaded more than n hours ago.
  NSDate *now = [NSDate date];
  NSTimeInterval timeIntervalBetweenNowAndLoadTime = [now timeIntervalSinceDate:self.loadTime];
  double secondsPerHour = 3600.0;
  double intervalInHours = timeIntervalBetweenNowAndLoadTime / secondsPerHour;
  return intervalInHours < n;
}

- (BOOL)isAdAvailable {
  // Check if ad exists and can be shown.
  return _appOpenAd && [self wasLoadTimeLessThanNHoursAgo:kTimeoutInterval];
}
// [END ad_expiration]

- (void)adDidComplete {
  // The app open ad is considered to be complete when it dismisses or fails to show.
  [self.delegate adDidComplete];
  self.delegate = nil;
}

// [START load_ad]
- (void)loadAd {
  // Do not load ad if there is an unused ad or one is already loading.
  if ([self isAdAvailable] || self.isLoadingAd) {
    return;
  }
  self.isLoadingAd = YES;

  [GADAppOpenAd loadWithAdUnitID:@"ca-app-pub-3940256099942544/5575463023"
                         request:[GADRequest request]
               completionHandler:^(GADAppOpenAd * _Nullable appOpenAd, NSError * _Nullable error) {
    self.isLoadingAd = NO;
    if (error) {
      NSLog(@"App open ad failed to load with error: %@", error);
      self.appOpenAd = nil;
      self.loadTime = nil;
      return;
    }
    self.appOpenAd = appOpenAd;
    // [START set_delegate]
    self.appOpenAd.fullScreenContentDelegate = self;
    // [END set_delegate]
    self.loadTime = [NSDate date];
  }];
}
// [END load_ad]

// [START show_ad]
- (void)showAdIfAvailable {
  // If the app open ad is already showing, do not show the ad again.
  if (self.isShowingAd) {
    NSLog(@"App open ad is already showing.");
    return;
  }

  // If the app open ad is not available yet but is supposed to show, load
  // a new ad.
  if (![self isAdAvailable]) {
    NSLog(@"App open ad is not ready yet.");
    // The app open ad is considered to be complete in this example.
    [self adDidComplete];
    // Load a new ad.
    // [START_EXCLUDE silent]
    if ([GoogleMobileAdsConsentManager.sharedInstance canRequestAds]) {
      [self loadAd];
    }
    // [END_EXCLUDE]
    return;
  }

  [self.appOpenAd presentFromRootViewController:nil];
  self.isShowingAd = YES;
}
// [END show_ad]

#pragma mark - GADFullScreenContentDelegate

// [START ad_events]
- (void)adDidRecordImpression:(nonnull id<GADFullScreenPresentingAd>)ad {
  NSLog(@"App open ad recorded an impression.");
}

- (void)adDidRecordClick:(nonnull id<GADFullScreenPresentingAd>)ad {
  NSLog(@"App open ad recorded a click.");
}

- (void)adWillPresentFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
  NSLog(@"App open ad will be presented.");
}

- (void)adWillDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
  NSLog(@"App open ad will be dismissed.");
}

- (void)adDidDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
  NSLog(@"App open ad was dismissed.");
  self.appOpenAd = nil;
  self.isShowingAd = NO;
  [self adDidComplete];
  [self loadAd];
}

- (void)ad:(nonnull id<GADFullScreenPresentingAd>)ad
    didFailToPresentFullScreenContentWithError:(nonnull NSError *)error {
  NSLog(@"App open ad failed to present with error: %@", error.localizedDescription);
  self.appOpenAd = nil;
  self.isShowingAd = NO;
  [self adDidComplete];
  [self loadAd];
}
// [END ad_events]

@end
