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

#import "MainViewController.h"

#import <GoogleMobileAds/GoogleMobileAds.h>

#import "GoogleMobileAdsConsentManager.h"
#import "SplashViewController.h"

/// Number of seconds to count down before showing the app open ad.
/// This simulates the time needed to load the app.
static const NSInteger CounterTime = 5;

@implementation SplashViewController {
  /// Number of seconds remaining to show the app open ad.
  NSInteger _secondsRemaining;
  /// The countdown timer.
  NSTimer *_countdownTimer;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  AppOpenAdManager.sharedInstance.delegate = self;
  [self startTimer];

  __weak __typeof__(self) weakSelf = self;
  [GoogleMobileAdsConsentManager.sharedInstance
      gatherConsentFromConsentPresentationViewController:self
                                consentGatheringComplete:^(NSError *_Nullable consentError) {
                                  __strong __typeof__(self) strongSelf = weakSelf;
                                  if (!strongSelf) {
                                    return;
                                  }

                                  if (consentError) {
                                    // Consent gathering failed.
                                    NSLog(@"Error: %@", consentError.localizedDescription);
                                  }

                                  if (GoogleMobileAdsConsentManager.sharedInstance.canRequestAds) {
                                    [strongSelf startGoogleMobileAdsSDK];
                                  }

                                  // Move onto the main screen if the app is done loading.
                                  if (strongSelf->_secondsRemaining <= 0) {
                                    [strongSelf startMainScreen];
                                  }
                                }];

  // This sample attempts to load ads using consent obtained in the previous session.
  if (GoogleMobileAdsConsentManager.sharedInstance.canRequestAds) {
    [self startGoogleMobileAdsSDK];
  }
}

- (void)startTimer {
  _secondsRemaining = CounterTime;
  self.splashScreenLabel.text = [NSString stringWithFormat:@"App is done loading in: %ld",
                                 (long)_secondsRemaining];
  _countdownTimer = [NSTimer
                     scheduledTimerWithTimeInterval:1.0
                     target:self
                     selector:@selector(decrementCounter)
                     userInfo:nil
                     repeats:YES];
}

- (void)decrementCounter {
  _secondsRemaining--;
  if (_secondsRemaining > 0) {
    self.splashScreenLabel.text = [NSString stringWithFormat:@"App is done loading in: %ld",
                                   (long)_secondsRemaining];
    return;
  }

  self.splashScreenLabel.text = @"Done.";
  [_countdownTimer invalidate];
  _countdownTimer = nil;

  [AppOpenAdManager.sharedInstance showAdIfAvailable:self];
}

- (void)startGoogleMobileAdsSDK {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    // Initialize the Google Mobile Ads SDK.
    [GADMobileAds.sharedInstance startWithCompletionHandler:nil];

    // Request an ad.
    [AppOpenAdManager.sharedInstance loadAd];
  });
}

- (void)startMainScreen {
  AppOpenAdManager.sharedInstance.delegate = nil;

  UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
  UINavigationController *navigationController = (UINavigationController *)[mainStoryBoard
      instantiateViewControllerWithIdentifier:@"NavigationController"];
  navigationController.modalPresentationStyle = UIModalPresentationOverFullScreen;
  [self presentViewController:navigationController
                     animated:YES
                   completion:^{
                     [self dismissViewControllerAnimated:NO
                                              completion:^{
                                                // Find the keyWindow which is currently being
                                                // displayed on the device, and set its
                                                // rootViewController to mainViewController.
                                                NSPredicate *predicate = [NSPredicate
                                                    predicateWithFormat:@"SELF.isKeyWindow == YES"];
                                                UIWindow *keyWindow =
                                                    [[UIApplication.sharedApplication.windows
                                                        filteredArrayUsingPredicate:predicate]
                                                        firstObject];
                                                keyWindow.rootViewController = navigationController;
                                              }];
                   }];
}

#pragma mark - AppOpenAdManagerDelegate

- (void)adDidComplete {
  [self startMainScreen];
}

@end
