//
//  Copyright (C) 2025 Google, Inc.
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

// Replace this ad unit ID with your own ad unit ID.
static NSString *const adUnitID = @"ca-app-pub-3940256099942544/6978759866";
static NSString *const adManagerAdUnitID = @"/21775744923/example/rewarded-interstitial";

@interface RewardedInterstitialAdSnippets : UIViewController <GADFullScreenContentDelegate>

@property(strong, nonatomic) GADRewardedInterstitialAd *rewardedInterstitialAd;

@end

@implementation RewardedInterstitialAdSnippets

// [START load_ad]
- (void)loadRewardedInterstitialAd {
  [GADRewardedInterstitialAd loadWithAdUnitID:adUnitID
                                      request:[GADRequest request]
                            completionHandler:^(GADRewardedInterstitialAd *ad, NSError *error) {
                              if (error) {
                                NSLog(@"Failed to load rewarded interstitial ad with error: %@",
                                      error.localizedDescription);
                                return;
                              }
                              self.rewardedInterstitialAd = ad;
                              // [START set_delegate]
                              self.rewardedInterstitialAd.fullScreenContentDelegate = self;
                              // [END set_delegate]
                            }];
}
// [END load_ad]

// [START load_ad_gam]
- (void)loadAdManagerRewardedInterstitialAd {
  [GADRewardedInterstitialAd loadWithAdUnitID:adUnitID
                                      request:[GAMRequest request]
                            completionHandler:^(GADRewardedInterstitialAd *ad, NSError *error) {
                              if (error) {
                                NSLog(@"Failed to load rewarded interstitial ad with error: %@",
                                      error.localizedDescription);
                                return;
                              }
                              self.rewardedInterstitialAd = ad;
                              self.rewardedInterstitialAd.fullScreenContentDelegate = self;
                            }];
}
// [END load_ad_gam]

// [START validate_server_side_verification]
- (void)validateServerSideVerification {
  // Replace this ad unit ID with your own ad unit ID.
  [GADRewardedInterstitialAd loadWithAdUnitID:adUnitID
                                      request:[GADRequest request]
                            completionHandler:^(GADRewardedInterstitialAd *ad, NSError *error) {
                              if (error) {
                                NSLog(@"Rewarded interstitial ad failed to load with error: %@",
                                      error.localizedDescription);
                                return;
                              }
                              self.rewardedInterstitialAd = ad;
                              GADServerSideVerificationOptions *options =
                                  [[GADServerSideVerificationOptions alloc] init];
                              options.customRewardString = @"SAMPLE_CUSTOM_DATA_STRING";
                              ad.serverSideVerificationOptions = options;
                            }];
}
// [END validate_server_side_verification]

// [START validate_gam_server_side_verification]
- (void)validateAdManagerServerSideVerification {
  // Replace this ad unit ID with your own ad unit ID.
  [GADRewardedInterstitialAd loadWithAdUnitID:adUnitID
                                      request:[GAMRequest request]
                            completionHandler:^(GADRewardedInterstitialAd *ad, NSError *error) {
                              if (error) {
                                NSLog(@"Rewarded interstitial ad failed to load with error: %@",
                                      error.localizedDescription);
                                return;
                              }
                              self.rewardedInterstitialAd = ad;
                              GADServerSideVerificationOptions *options =
                                  [[GADServerSideVerificationOptions alloc] init];
                              options.customRewardString = @"SAMPLE_CUSTOM_DATA_STRING";
                              ad.serverSideVerificationOptions = options;
                            }];
}
// [END validate_gam_server_side_verification]

#pragma mark GADFullScreeContentDelegate implementation

// [START ad_events]
- (void)adDidRecordImpression:(id<GADFullScreenPresentingAd>)ad {
  NSLog(@"%s called", __PRETTY_FUNCTION__);
}

- (void)adDidRecordClick:(id<GADFullScreenPresentingAd>)ad {
  NSLog(@"%s called", __PRETTY_FUNCTION__);
}

- (void)adWillPresentFullScreenContent:(id<GADFullScreenPresentingAd>)ad {
  NSLog(@"%s called", __PRETTY_FUNCTION__);
}

- (void)adWillDismissFullScreenContent:(id<GADFullScreenPresentingAd>)ad {
  NSLog(@"%s called", __PRETTY_FUNCTION__);
}

- (void)adDidDismissFullScreenContent:(id<GADFullScreenPresentingAd>)ad {
  NSLog(@"%s called", __PRETTY_FUNCTION__);
  // Clear the rewarded interstitial ad.
  self.rewardedInterstitialAd = nil;
}

- (void)ad:(id)ad didFailToPresentFullScreenContentWithError:(NSError *)error {
  NSLog(@"%s called with error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
}
// [END ad_events]

// [START show_ad]
- (void)showRewardedInterstitialAd {
  [self.rewardedInterstitialAd presentFromRootViewController:self
                                    userDidEarnRewardHandler:^{
                                      GADAdReward *reward = self.rewardedInterstitialAd.adReward;

                                      NSString *rewardMessage = [NSString
                                          stringWithFormat:@"Reward received with "
                                                           @"currency %@ , amount %ld",
                                                           reward.type, [reward.amount longValue]];
                                      NSLog(@"%@", rewardMessage);
                                      // TODO: Reward the user.
                                    }];
}
// [END show_ad]

@end
