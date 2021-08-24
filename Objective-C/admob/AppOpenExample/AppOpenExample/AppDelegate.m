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

#import "AppDelegate.h"

#import <GoogleMobileAds/GoogleMobileAds.h>


@implementation AppDelegate {
  /// The app open ad.
  GADAppOpenAd *_appOpenAd;
  /// Keeps track of is an app open ad loading.
  BOOL _isLoadingAd;
  /// Keeps track of is an app open ad showing.
  BOOL _isShowingAd;
  /// Keeps track of the time an app open ad is loaded to ensure you don't show an expired ad.
  NSDate *_loadTime;
}

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary<NSString *, __kindof NSObject *> *)launchOptions {
  // Initialize Google Mobile Ads SDK
  [GADMobileAds.sharedInstance startWithCompletionHandler:nil];

  return YES;
}

- (void) applicationDidBecomeActive:(UIApplication *)application {
  UIWindow *keyWindow = application.keyWindow;
  if (keyWindow) {
    [self showAdIfAvailable:keyWindow.rootViewController];
  }
}

- (void)loadAd {
  // Do not load ad if there is an unused ad or one is already loading.
  if (_isLoadingAd || [self isAdAvailable]) {
    return;
  }
  _isLoadingAd = YES;
  NSLog(@"Start loading ad.");
  [GADAppOpenAd loadWithAdUnitID:@"ca-app-pub-3940256099942544/5662855259"
                         request:[GADRequest request]
                     orientation:UIInterfaceOrientationPortrait
               completionHandler:^(GADAppOpenAd * _Nullable appOpenAd, NSError * _Nullable error) {
    self->_isLoadingAd = NO;
    if (error) {
      NSLog(@"App open ad failed to load with error: %@.", error);
      return;
    }
    self->_appOpenAd = appOpenAd;
    self->_appOpenAd.fullScreenContentDelegate = self;
    self->_loadTime = [NSDate date];
    NSLog(@"Loading Succeeded.");
  }];
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
  // Ad references in the app open beta will time out after four hours, but this time limit
  // may change in future beta versions. For details, see:
  // https://support.google.com/admob/answer/9341964?hl=en
  return _appOpenAd && [self wasLoadTimeLessThanNHoursAgo:4];
}

- (void)showAdIfAvailable:(nonnull UIViewController*)viewController {
  // If the app open ad is already showing, do not show the ad again.
  if (_isShowingAd) {
    NSLog(@"The app open ad is already showing.");
    return;
  }
  // If the app open ad is not available yet, invoke the callback then load the ad.
  if (![self isAdAvailable]) {
    NSLog(@"The app open ad is not ready yet.");
    [self loadAd];
    return;
  }
  NSLog(@"Will show ad.");
  _isShowingAd = YES;
  [_appOpenAd presentFromRootViewController:viewController];
}

#pragma mark - GADFullScreenContentDelegate

/// Tells the delegate that the ad presented full screen content.
- (void)adDidPresentFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
  NSLog(@"App open ad presented.");
}

/// Tells the delegate that the ad dismissed full screen content.
- (void)adDidDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
  _appOpenAd = nil;
  _isShowingAd = NO;
  NSLog(@"App open ad dismissed.");
  [self loadAd];
}

/// Tells the delegate that the ad failed to present full screen content.
- (void)ad:(nonnull id<GADFullScreenPresentingAd>)ad
    didFailToPresentFullScreenContentWithError:(nonnull NSError *)error {
  _appOpenAd = nil;
  _isShowingAd = NO;
  NSLog(@"App open ad failed to present with error: %@.", error.localizedDescription);
  [self loadAd];
}

@end
