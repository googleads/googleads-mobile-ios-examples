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

@interface AdManagerSCARSnippets : NSObject <GADNativeAdLoaderDelegate, GAMBannerAdLoaderDelegate>
@property(nonatomic, strong) GADAdLoader *adLoader;

- (void)loadNative:(NSString *)adUnitID;
- (void)loadBanner:(NSString *)adUnitID;
- (void)loadNativePlusBanner:(NSString *)adUnitID;
@end

@implementation AdManagerSCARSnippets

- (void)loadNative:(NSString *)adUnitID {
  // [START signal_request_native]
  // Create a signal request for an ad.
  // Specify the "signal_type_ad_manager_s2s" to
  // denote that the usage of QueryInfo is for Ad Manager S2S.
  GADNativeSignalRequest *signalRequest =
      [[GADNativeSignalRequest alloc] initWithSignalType:@"signal_type_ad_manager_s2s"];
  signalRequest.requestAgent = @"REQUEST_AGENT";
  signalRequest.adUnitID = adUnitID;

  [GADMobileAds generateSignal:signalRequest
             completionHandler:^(GADSignal *_Nullable signal, NSError *_Nullable error) {
               if (error != nil) {
                 NSLog(@"Error getting ad info: %@", error.localizedDescription);
                 return;
               }
               if (signal == nil) {
                 NSLog(@"Unexpected error - query info is nil.");
                 return;
               }
               NSLog(@"Signal string: %@", signal.signalString);
               // Fetch the ad response using your generated signal.
               NSString *adResponseString = [self fetchAdResponseString:signal];
             }];
  // [END signal_request_native]
}

- (void)loadBanner:(NSString *)adUnitID {
  // [START signal_request_banner]
  // Create a signal request for an ad.
  // Specify the "signal_type_ad_manager_s2s" to
  // denote that the usage of QueryInfo is for Ad Manager S2S.
  GADBannerSignalRequest *signalRequest =
      [[GADBannerSignalRequest alloc] initWithSignalType:@"signal_type_ad_manager_s2s"];
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
                 NSLog(@"Unexpected error - query info is nil.");
                 return;
               }
               NSLog(@"Signal string: %@", signal.signalString);
               // Fetch the ad response using your generated signal.
               NSString *adResponseString = [self fetchAdResponseString:signal];
             }];
  // [END signal_request_banner]
}

- (void)loadNativePlusBanner:(NSString *)adUnitID {
  // [START signal_request_native_plus_banner]
  // Create a signal request for an ad.
  // Specify the "signal_type_ad_manager_s2s" to
  // denote that the usage of QueryInfo is for Ad Manager S2S.
  GADNativeSignalRequest *signalRequest =
      [[GADNativeSignalRequest alloc] initWithSignalType:@"signal_type_ad_manager_s2s"];
  signalRequest.adUnitID = adUnitID;
  signalRequest.adLoaderAdTypes =
      [NSSet setWithArray:@[ GADAdLoaderAdTypeNative, GADAdLoaderAdTypeGAMBanner ]];
  // Refer to the AdSize class for available ad sizes.
  signalRequest.adSizes =
      @[ NSValueFromGADAdSize(GADCurrentOrientationInlineAdaptiveBannerAdSizeWithWidth(375)) ];

  [GADMobileAds generateSignal:signalRequest
             completionHandler:^(GADSignal *_Nullable signal, NSError *_Nullable error) {
               if (error != nil) {
                 NSLog(@"Error getting ad info: %@", error.localizedDescription);
                 return;
               }
               if (signal == nil) {
                 NSLog(@"Unexpected error - query info is nil.");
                 return;
               }
               NSLog(@"Signal string: %@", signal.signalString);
               // Fetch the ad response using your generated signal.
               NSString *adResponseString = [self fetchAdResponseString:signal];
             }];
  // [END signal_request_native_plus_banner]
}

- (void)loadNativeWithOptions:(NSString *)adUnitID {
  // [START native_ad_options]
  // Create a signal request for an ad.
  // Specify the "signal_type_ad_manager_s2s" to
  // denote that the usage of QueryInfo is for Ad Manager S2S.
  GADNativeSignalRequest *signalRequest =
      [[GADNativeSignalRequest alloc] initWithSignalType:@"signal_type_ad_manager_s2s"];
  signalRequest.requestAgent = @"REQUEST_AGENT";
  signalRequest.adUnitID = adUnitID;

  // Enable shared native ad options.
  signalRequest.disableImageLoading = NO;
  signalRequest.mediaAspectRatio = GADMediaAspectRatioAny;
  signalRequest.preferredAdChoicesPosition = GADAdChoicesPositionTopRightCorner;

  // Enable video options.
  GADVideoOptions *videoOptions = [[GADVideoOptions alloc] init];
  videoOptions.startMuted = YES;
  signalRequest.videoOptions = videoOptions;

  [GADMobileAds generateSignal:signalRequest
             completionHandler:^(GADSignal *_Nullable signal, NSError *_Nullable error) {
               if (error != nil) {
                 NSLog(@"Error getting ad info: %@", error.localizedDescription);
                 return;
               }
               if (signal == nil) {
                 NSLog(@"Unexpected error - query info is nil.");
                 return;
               }
               NSLog(@"Signal string: %@", signal.signalString);
               // Fetch the ad response using your generated signal.
               NSString *adResponseString = [self fetchAdResponseString:signal];
             }];
  // [END native_ad_options]
}

// [START fetch_response]
// This function emulates a request to your ad server.
- (NSString *)fetchAdResponseString:(GADSignal *)signal {
  return @"adResponseString";
}
// [END fetch_response]

- (void)renderBanner:(NSString *)adUnitID
      adResponseString:(NSString *)adResponseString
    rootViewController:(UIViewController *)rootViewController {
  // [START render_banner]
  self.adLoader = [[GADAdLoader alloc] initWithAdUnitID:adUnitID
                                     rootViewController:rootViewController
                                                adTypes:@[ GADAdLoaderAdTypeGAMBanner ]
                                                options:nil];
  self.adLoader.delegate = self;
  [self.adLoader loadWithAdResponseString:adResponseString];
  // [END render_banner]
}

- (void)renderNative:(NSString *)adUnitID
      adResponseString:(NSString *)adResponseString
    rootViewController:(UIViewController *)rootViewController {
  // [START render_native]
  self.adLoader = [[GADAdLoader alloc] initWithAdUnitID:adUnitID
                                     rootViewController:rootViewController
                                                adTypes:@[ GADAdLoaderAdTypeNative ]
                                                options:nil];
  self.adLoader.delegate = self;
  [self.adLoader loadWithAdResponseString:adResponseString];
  // [END render_native]
}

- (void)renderNativePlusBanner:(NSString *)adUnitID
              adResponseString:(NSString *)adResponseString
            rootViewController:(UIViewController *)rootViewController {
  // [START render_native_plus_banner]
  self.adLoader =
      [[GADAdLoader alloc] initWithAdUnitID:adUnitID
                         rootViewController:rootViewController
                                    adTypes:@[ GADAdLoaderAdTypeNative, GADAdLoaderAdTypeGAMBanner ]
                                    options:nil];
  self.adLoader.delegate = self;
  [self.adLoader loadWithAdResponseString:adResponseString];
  // [END render_native_plus_banner]
}

#pragma mark - GADNativeAdLoaderDelegate

- (void)adLoader:(nonnull GADAdLoader *)adLoader
    didReceiveGAMBannerView:(nonnull GAMBannerView *)bannerView {
  // GAM Banner ad received.
}

- (void)adLoader:(nonnull GADAdLoader *)adLoader
    didReceiveNativeAd:(nonnull GADNativeAd *)nativeAd {
  // Native ad received.
}

- (void)adLoader:(nonnull GADAdLoader *)adLoader
    didFailToReceiveAdWithError:(nonnull NSError *)error {
  // Native ad failed to load.
}

@end
