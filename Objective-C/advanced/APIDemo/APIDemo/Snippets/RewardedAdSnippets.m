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

@interface RewardedAdSnippets : NSObject

@property(strong, nonatomic) GADRewardedAd *rewardedAd;

@end

@implementation RewardedAdSnippets

- (void)validateServerSideVerification {
  // [START validate_server_side_verification]
  // Replace this ad unit ID with your own ad unit ID.
  [GADRewardedAd loadWithAdUnitID:@"ca-app-pub-3940256099942544/1712485313"
                          request:[GADRequest request]
                completionHandler:^(GADRewardedAd *ad, NSError *error) {
                  if (error) {
                    NSLog(@"Rewarded ad failed to load with error: %@", error.localizedDescription);
                    return;
                  }
                  self.rewardedAd = ad;
                  GADServerSideVerificationOptions *options =
                      [[GADServerSideVerificationOptions alloc] init];
                  options.customRewardString = @"SAMPLE_CUSTOM_DATA_STRING";
                  ad.serverSideVerificationOptions = options;
                }];
  // [END validate_server_side_verification]
}

@end
