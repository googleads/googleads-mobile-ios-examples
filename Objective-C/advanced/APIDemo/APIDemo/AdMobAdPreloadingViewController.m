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

#import "AdMobAdPreloadingViewController.h"

#import <GoogleMobileAds/GoogleMobileAds.h>
#import <GoogleMobileAds/GoogleMobileAds_Beta.h>

#import "PreloadView.h"

// Preload status messages.
static NSString *const kPreloadAvailable = @"Is available.";
static NSString *const kPreloadExhausted = @"Is exhausted.";

// AdMob test ad unit IDs.
static NSString *const kAppOpenAdUnitID = @"ca-app-pub-3940256099942544/5575463023";
static NSString *const kInterstitialAdUnitID = @"ca-app-pub-3940256099942544/4411468910";
static NSString *const kRewardedAdUnitID = @"ca-app-pub-3940256099942544/1712485313";
static NSString *const kRewardedInterstitialAdUnitID = @"ca-app-pub-3940256099942544/6978759866";

@interface AdMobAdPreloadingViewController () <GADPreloadDelegate, GADFullScreenContentDelegate>

@property(nonatomic, strong) PreloadView *appOpenView;
@property(nonatomic, strong) PreloadView *interstitialView;
@property(nonatomic, strong) PreloadView *rewardedView;
@property(nonatomic, strong) PreloadView *rewardedInterstitialView;

@property(weak, nonatomic) IBOutlet UIStackView *preloadContainer;

@end

@implementation AdMobAdPreloadingViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [self startGoogleMobileAdsSDK];
  [self configurePreloadViews];
}

- (void)startGoogleMobileAdsSDK {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    // Initialize the Google Mobile Ads SDK.
    __weak __typeof__(self) weakSelf = self;
    [[GADMobileAds sharedInstance]
        startWithCompletionHandler:^(GADInitializationStatus *_Nonnull status) {
          // Start ad preloading.
          __typeof__(self) strongSelf = weakSelf;
          if (!strongSelf) {
            return;
          }
          [strongSelf startGoogleMobileAdsPreload];
        }];
  });
}

- (void)startGoogleMobileAdsPreload {
  GADRequest *request = [GADRequest request];
  GADPreloadConfigurationV2 *interstitialConfig =
      [[GADPreloadConfigurationV2 alloc] initWithAdUnitID:kInterstitialAdUnitID
                                                  request:request];
  [GADInterstitialAdPreloader.sharedInstance
      preloadForPreloadID:kInterstitialAdUnitID
            configuration:interstitialConfig
                 delegate:self];
  GADPreloadConfigurationV2 *appOpenConfig =
      [[GADPreloadConfigurationV2 alloc] initWithAdUnitID:kAppOpenAdUnitID
                                                  request:request];
  [GADAppOpenAdPreloader.sharedInstance
      preloadForPreloadID:kAppOpenAdUnitID
            configuration:appOpenConfig
                 delegate:self];
  GADPreloadConfigurationV2 *rewardedConfig =
      [[GADPreloadConfigurationV2 alloc] initWithAdUnitID:kRewardedAdUnitID
                                                  request:request];
  [GADRewardedAdPreloader.sharedInstance
      preloadForPreloadID:kRewardedAdUnitID
            configuration:rewardedConfig
                 delegate:self];
  GADPreloadConfigurationV2 *rewardedInterstitialConfig =
      [[GADPreloadConfigurationV2 alloc] initWithAdUnitID:kRewardedInterstitialAdUnitID
                                                  request:request];
  [GADRewardedInterstitialAdPreloader.sharedInstance
      preloadForPreloadID:kRewardedInterstitialAdUnitID
            configuration:rewardedInterstitialConfig
                 delegate:self];
}

- (BOOL)isInterstitialAvailable {
  return [GADInterstitialAdPreloader.sharedInstance
      isAdAvailableWithPreloadID:kInterstitialAdUnitID];
}

- (BOOL)isRewardedAvailable {
  return [GADRewardedAdPreloader.sharedInstance
      isAdAvailableWithPreloadID:kRewardedAdUnitID];
}

- (BOOL)isRewardedInterstitialAvailable {
  return [GADRewardedInterstitialAdPreloader.sharedInstance
      isAdAvailableWithPreloadID:kRewardedInterstitialAdUnitID];
}

- (BOOL)isAppOpenAvailable {
  return [GADAppOpenAdPreloader.sharedInstance
      isAdAvailableWithPreloadID:kAppOpenAdUnitID];
}

- (void)showInterstitialAd {
  if (![self isInterstitialAvailable]) {
    [self logAndShowAlert:@"Preloaded interstitial ad is not available."];
    return;
  }

  // Getting the preloaded ad loads another ad in the background.
  GADInterstitialAd *ad =
      [GADInterstitialAdPreloader.sharedInstance adWithPreloadID:kInterstitialAdUnitID];

  // Interact with the ad object as needed.
  NSLog(@"Interstitial ad response info: %@", ad.responseInfo);
  ad.paidEventHandler = ^(GADAdValue *_Nonnull value) {
    NSLog(@"Interstitial ad paid event: %@ %@ ", value.value, value.currencyCode);
  };
  ad.fullScreenContentDelegate = self;
  [ad presentFromRootViewController:self];
}

- (void)showRewardedAd {
  if (![self isRewardedAvailable]) {
    [self logAndShowAlert:@"Preloaded rewarded ad is not available."];
    return;
  }

  // Getting the preloaded ad loads another ad in the background.
  __weak __typeof__(self) weakSelf = self;
  GADRewardedAd *ad =
      [GADRewardedAdPreloader.sharedInstance adWithPreloadID:kRewardedAdUnitID];

  // Interact with the ad object as needed.
  NSLog(@"Rewarded ad response info: %@", ad.responseInfo);
  ad.paidEventHandler = ^(GADAdValue *_Nonnull value) {
    NSLog(@"Rewarded ad paid event: %@ %@ ", value.value, value.currencyCode);
  };
  ad.fullScreenContentDelegate = self;
  [ad presentFromRootViewController:self
           userDidEarnRewardHandler:^{
             __typeof__(self) strongSelf = weakSelf;
             if (!strongSelf) {
               return;
             }
             GADAdReward *reward = ad.adReward;
             NSLog(@"User was rewarded %@ %@", reward.amount, reward.type);
           }];
}

- (void)showRewardedInterstitialAd {
  if (![self isRewardedInterstitialAvailable]) {
    [self logAndShowAlert:@"Preloaded rewarded interstitial ad is not available."];
    return;
  }

  // Polling returns the next available ad and loads another ad in the background.
  __weak __typeof__(self) weakSelf = self;
  GADRewardedInterstitialAd *ad = [GADRewardedInterstitialAdPreloader.sharedInstance
      adWithPreloadID:kRewardedInterstitialAdUnitID];

  // Interact with the ad object as needed.
  NSLog(@"Rewarded interstitial ad response info: %@", ad.responseInfo);
  ad.paidEventHandler = ^(GADAdValue *_Nonnull value) {
    NSLog(@"Rewarded interstitial ad paid event: %@ %@ ", value.value, value.currencyCode);
  };
  ad.fullScreenContentDelegate = self;
  [ad presentFromRootViewController:self
           userDidEarnRewardHandler:^{
             __typeof__(self) strongSelf = weakSelf;
             if (!strongSelf) {
               return;
             }
             GADAdReward *reward = ad.adReward;
             NSLog(@"User was rewarded %@ %@", reward.amount, reward.type);
           }];
}

- (void)showAppOpenAd {
  if (![self isAppOpenAvailable]) {
    [self logAndShowAlert:@"Preloaded app open ad is not available."];
    return;
  }

  // Getting the preloaded loads another ad in the background.
  GADAppOpenAd *ad =
      [GADAppOpenAdPreloader.sharedInstance adWithPreloadID:kAppOpenAdUnitID];

  // Interact with the ad object as needed.
  NSLog(@"App open ad response info: %@", ad.responseInfo);
  ad.paidEventHandler = ^(GADAdValue *_Nonnull value) {
    NSLog(@"App open ad paid event: %@ %@ ", value.value, value.currencyCode);
  };
  ad.fullScreenContentDelegate = self;
  [ad presentFromRootViewController:self];
}

- (void)configurePreloadViews {
  __weak __typeof__(self) weakSelf = self;
  self.interstitialView = [PreloadView preloadViewWithTitle:@"Interstitial"
                                               showDelegate:^{
                                                 [weakSelf showInterstitialAd];
                                               }];
  self.rewardedView = [PreloadView preloadViewWithTitle:@"Rewarded"
                                           showDelegate:^{
                                             [weakSelf showRewardedAd];
                                           }];
  self.rewardedInterstitialView = [PreloadView preloadViewWithTitle:@"Rewarded Interstitial"
                                                       showDelegate:^{
                                                         [weakSelf showRewardedInterstitialAd];
                                                       }];
  self.appOpenView = [PreloadView preloadViewWithTitle:@"App open"
                                          showDelegate:^{
                                            [weakSelf showAppOpenAd];
                                          }];

  [self.preloadContainer addArrangedSubview:self.interstitialView];
  [self.preloadContainer addArrangedSubview:self.appOpenView];
  [self.preloadContainer addArrangedSubview:self.rewardedView];
  [self.preloadContainer addArrangedSubview:self.rewardedInterstitialView];

  [self updatePreloadViews];
}

- (void)updatePreloadViews {
  [self updatePreloadView:self.interstitialView isAvailable:[self isInterstitialAvailable]];
  [self updatePreloadView:self.rewardedView isAvailable:[self isRewardedAvailable]];
  [self updatePreloadView:self.rewardedInterstitialView isAvailable:[self isRewardedInterstitialAvailable]];
  [self updatePreloadView:self.appOpenView isAvailable:[self isAppOpenAvailable]];
}

- (void)updatePreloadView:(PreloadView *)preloadView isAvailable:(BOOL)isAvailable {
  preloadView.showButton.enabled = isAvailable;
  UILabel *statusText = preloadView.statusText;
  statusText.text = isAvailable ? kPreloadAvailable : kPreloadExhausted;
  statusText.textColor = isAvailable ? UIColor.blueColor : UIColor.redColor;
  UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification,
                                  statusText.text);
}

- (void)logAndShowAlert:(NSString *)message {
  UIAlertController *alert =
      [UIAlertController alertControllerWithTitle:@"Alert"
                                          message:message
                                   preferredStyle:UIAlertControllerStyleAlert];

  UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"Dismiss"
                                                          style:UIAlertActionStyleDefault
                                                        handler:nil];
  [alert addAction:dismissAction];
  [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - GADPreloadDelegate

- (void)adAvailableForPreloadID:(nonnull NSString *)preloadID responseInfo:(nonnull GADResponseInfo *)responseInfo {
  // This callback indicates that an ad is available for the specified configuration.
  // No action is required here, but updating the UI can be useful in some cases.
  NSLog(@"Ad preloaded successfully for ad unit ID: %@", preloadID);
  [self updatePreloadViews];
}

- (void)adsExhaustedForPreloadID:(nonnull NSString *)preloadID {
  // This callback indicates that all the ads for the specified configuration have been
  // consumed and no ads are available to show. No action is required here, but updating
  // the UI can be useful in some cases.
  // [Important] Don't call [GAD<Format>AdPreloader preloadForPreloadID:] or
  // [GAD<Format>AdPreloader adWithPreloadID:] from adsExhaustedForPreloadID.
  NSLog(@"Ad exhausted for ad preload ID: %@", preloadID);
  [self updatePreloadViews];
}

- (void)adFailedToPreloadForPreloadID:(nonnull NSString *)preloadID error:(nonnull NSError *)error {
  NSLog(@"Ad failed to load with ad preload ID: %@, Error: %@", preloadID, error.localizedDescription);
}

#pragma mark - GADFullScreenContentDelegate

- (void)adWillPresentFullScreenContent:(id<GADFullScreenPresentingAd>)ad {
  NSLog(@"Preloaded ad will be presented.");
}

- (void)adDidDismissFullScreenContent:(id<GADFullScreenPresentingAd>)ad {
  NSLog(@"Preloaded ad dismissed.");
}

@end
