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

@import GoogleMobileAds;

@interface ImpressionLevelAdRevenueSnippets : NSObject
@property(nonatomic, strong) GADRewardedAd *rewardedAd;
@end

@implementation ImpressionLevelAdRevenueSnippets

- (void)requestRewardedAd {
  NSString *adUnitID = @"ca-app-pub-3940256099942544/6978759866";

  [GADRewardedAd loadWithAdUnitID:adUnitID
                          request:[GADRequest request]
                completionHandler:^(GADRewardedAd *_Nullable rewardedAd, NSError *_Nullable error) {
                  if (error) {
                    NSLog(@"Failed to load rewarded ad with error: %@", error.localizedDescription);
                    return;
                  }

                  self.rewardedAd = rewardedAd;

                  // [START get_impression_level_ad_revenue]
                  rewardedAd.paidEventHandler = ^(GADAdValue *_Nonnull adValue) {
                    // TODO: Send the impression-level ad revenue information to your preferred
                    // analytics server directly within this callback.

                    // Extract the impression-level ad revenue data.
                    NSDecimalNumber *value = adValue.value;
                    NSString *currencyCode = adValue.currencyCode;
                    GADAdValuePrecision precision = adValue.precision;

                    NSLog(@"Ad paid event. Value: %@ %@, with precision: %ld.", value, currencyCode,
                          (long)precision);
                  };
                  // [END get_impression_level_ad_revenue]

                  // Get the ad unit ID.
                  NSString *adUnitID = rewardedAd.adUnitID;
                  NSLog(@"Ad unit ID: %@", adUnitID);

                  // Get the response info.
                  GADResponseInfo *responseInfo = rewardedAd.responseInfo;
                  GADAdNetworkResponseInfo *loadedAdNetworkResponseInfo =
                      responseInfo.loadedAdNetworkResponseInfo;

                  // Accessing network info properties
                  NSString *adSourceID = loadedAdNetworkResponseInfo.adSourceID;
                  NSString *adSourceInstanceID = loadedAdNetworkResponseInfo.adSourceInstanceID;
                  NSString *adSourceInstanceName = loadedAdNetworkResponseInfo.adSourceInstanceName;
                  NSString *adSourceName = loadedAdNetworkResponseInfo.adSourceName;

                  NSLog(@"Ad source ID: %@", adSourceID);
                  NSLog(@"Ad source instance ID: %@", adSourceInstanceID);
                  NSLog(@"Ad source instance name: %@", adSourceInstanceName);
                  NSLog(@"Ad source name: %@", adSourceName);

                  // Get the extras info.
                  NSDictionary *extras = responseInfo.extrasDictionary;
                  NSString *mediationGroupName = extras[@"mediation_group_name"];
                  NSString *mediationABTestName = extras[@"mediation_ab_test_name"];
                  NSString *mediationABTestVariant = extras[@"mediation_ab_test_variant"];

                  NSLog(@"Mediation group name: %@", mediationGroupName);
                  NSLog(@"Mediation AB test name: %@", mediationABTestName);
                  NSLog(@"Mediation AB test variant: %@", mediationABTestVariant);
                }];
}

@end
