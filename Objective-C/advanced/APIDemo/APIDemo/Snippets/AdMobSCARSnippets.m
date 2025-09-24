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

#import <GoogleMobileAds/GoogleMobileAds.h>
#import <UIKit/UIKit.h>

@interface AdMobSCARSnippets : NSObject
- (void)loadNative:(NSString *)adUnitID;
- (void)loadBanner:(NSString *)adUnitID;
@end

@implementation AdMobSCARSnippets

- (void)loadNative:(NSString *)adUnitID {
  // [START signal_request_native]
  // Create a signal request for an ad.
  GADNativeSignalRequest *signalRequest =
      [[GADNativeSignalRequest alloc] initWithSignalType:@"SIGNAL_TYPE"];
  signalRequest.requestAgent = @"REQUEST_AGENT";
  signalRequest.adUnitID = adUnitID;

  [GADMobileAds generateSignal:signalRequest
             completionHandler:^(GADSignal *_Nullable signal, NSError *_Nullable error) {
               if (error != nil) {
                 NSLog(@"Error getting ad info: %@", error.localizedDescription);
                 return;
               }
               if (signal == nil) {
                 NSLog(@"Unexpected error - signal is nil.");
                 return;
               }
               NSLog(@"Signal string: %@", signal.signalString);
               // TODO: Fetch the ad response using your generated signal.
             }];
  // [END signal_request_native]
}

- (void)loadBanner:(NSString *)adUnitID {
  // [START signal_request_banner]
  // Create a signal request for an ad.
  // Contact your account manager for your assigned signal type.
  GADBannerSignalRequest *signalRequest =
      [[GADBannerSignalRequest alloc] initWithSignalType:@"SIGNAL_TYPE"];
  signalRequest.requestAgent = @"REQUEST_AGENT";
  signalRequest.adUnitID = adUnitID;
  // Refer to the AdSize class for available ad sizes.
  signalRequest.adSize = GADCurrentOrientationInlineAdaptiveBannerAdSizeWithWidth(375);

  [GADMobileAds generateSignal:signalRequest
             completionHandler:^(GADSignal *_Nullable signal, NSError *_Nullable error) {
               if (error != nil) {
                 NSLog(@"Error getting ad info: %@", error.localizedDescription);
                 return;
               }
               if (signal == nil) {
                 NSLog(@"Unexpected error - Signal is nil.");
                 return;
               }
               NSLog(@"Signal string: %@", signal.signalString);
               // TODO: Fetch the ad response using your generated signal.
             }];
  // [END signal_request_banner]
}

@end
