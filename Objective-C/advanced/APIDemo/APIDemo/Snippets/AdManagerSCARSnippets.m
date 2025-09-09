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

#import <UIKit/UIKit.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

/// A class demonstrating how to use the Google Mobile Ads SDK for SCAR requests.
@interface AdManagerSCARSnippets : NSObject <GADNativeAdLoaderDelegate,
                                            GAMBannerAdLoaderDelegate,
                                            GADBannerViewDelegate>
@property(nonatomic, strong) GADAdLoader *adLoader;
@property(nonatomic, strong) GAMBannerView *bannerView;

- (void)loadNative:(NSString *)adUnitID rootViewController:(UIViewController *)rootViewController;
- (void)loadBanner:(NSString *)adUnitID rootViewController:(UIViewController *)rootViewController;
- (void)loadNativePlusBanner:(NSString *)adUnitID
          rootViewController:(UIViewController *)rootViewController;
- (void)loadNativeWithOptions:(NSString *)adUnitID
           rootViewController:(UIViewController *)rootViewController;
@end

@implementation AdManagerSCARSnippets

- (void)loadNative:(NSString *)adUnitID rootViewController:(UIViewController *)rootViewController {
  // [START signal_request_native]
  // Create a signal request for an ad.
  // Specify the "signal_type_ad_manager_s2s" to denote that the usage of @c GADSignal is for Ad
  // Manager S2S.
  GADNativeSignalRequest *signalRequest =
      [[GADNativeSignalRequest alloc] initWithSignalType:@"signal_type_ad_manager_s2s"];
  signalRequest.requestAgent = @"REQUEST_AGENT";
  signalRequest.adUnitID = adUnitID;

  [GADMobileAds generateSignal:signalRequest
             completionHandler:^(GADSignal *_Nullable signal, NSError *_Nullable error) {
               if (error != nil) {
                 NSLog(@"Error getting signal: %@", error.localizedDescription);
                 return;
               }
               if (signal == nil) {
                 NSLog(@"Unexpected error - signal is nil.");
                 return;
               }
               NSLog(@"Signal string: %@", signal.signalString);
               // Fetch the ad response using your generated signal.
               NSString *adResponseString = [self fetchAdResponseString:signal];
               [self renderNative:adUnitID
                     adResponseString:adResponseString
                   rootViewController:rootViewController];
             }];
  // [END signal_request_native]
}

- (void)loadBanner:(NSString *)adUnitID rootViewController:(UIViewController *)rootViewController {
  // [START signal_request_banner]
  // Create a signal request for an ad.
  // Specify the "signal_type_ad_manager_s2s" to
  // denote that the usage of @c GADSignal is for Ad Manager S2S.
  GADBannerSignalRequest *signalRequest =
      [[GADBannerSignalRequest alloc] initWithSignalType:@"signal_type_ad_manager_s2s"];
  signalRequest.requestAgent = @"REQUEST_AGENT";
  signalRequest.adUnitID = adUnitID;
  // Refer to the @c AdSize class for available ad sizes.
  signalRequest.adSize = GADCurrentOrientationInlineAdaptiveBannerAdSizeWithWidth(375);

  [GADMobileAds generateSignal:signalRequest
             completionHandler:^(GADSignal *_Nullable signal, NSError *_Nullable error) {
               if (error != nil) {
                 NSLog(@"Error getting signal: %@", error.localizedDescription);
                 return;
               }
               if (signal == nil) {
                 NSLog(@"Unexpected error - signal is nil.");
                 return;
               }
               NSLog(@"Signal string: %@", signal.signalString);
               // Fetch the ad response using your generated signal.
               NSString *adResponseString = [self fetchAdResponseString:signal];
               [self renderBanner:adUnitID
                     adResponseString:adResponseString
                   rootViewController:rootViewController];
             }];
  // [END signal_request_banner]
}

- (void)loadNativePlusBanner:(NSString *)adUnitID
          rootViewController:(UIViewController *)rootViewController {
  // [START signal_request_native_plus_banner]
  // Create a signal request for an ad.
  // Specify the "signal_type_ad_manager_s2s" to denote that the usage of @c GADSignal is for Ad
  // Manager S2S.
  GADNativeSignalRequest *signalRequest =
      [[GADNativeSignalRequest alloc] initWithSignalType:@"signal_type_ad_manager_s2s"];
  signalRequest.adUnitID = adUnitID;
  signalRequest.adLoaderAdTypes =
      [NSSet setWithArray:@[ GADAdLoaderAdTypeNative, GADAdLoaderAdTypeGAMBanner ]];
  // Refer to the @c AdSize class for available ad sizes.
  signalRequest.adSizes =
      @[ NSValueFromGADAdSize(GADCurrentOrientationInlineAdaptiveBannerAdSizeWithWidth(375)) ];

  [GADMobileAds generateSignal:signalRequest
             completionHandler:^(GADSignal *_Nullable signal, NSError *_Nullable error) {
               if (error != nil) {
                 NSLog(@"Error getting signal: %@", error.localizedDescription);
                 return;
               }
               if (signal == nil) {
                 NSLog(@"Unexpected error - signal is nil.");
                 return;
               }
               NSLog(@"Signal string: %@", signal.signalString);
               // Fetch the ad response using your generated signal.
               NSString *adResponseString = [self fetchAdResponseString:signal];
               [self renderNativePlusBanner:adUnitID
                           adResponseString:adResponseString
                         rootViewController:rootViewController];
             }];
  // [END signal_request_native_plus_banner]
}

- (void)loadNativeWithOptions:(NSString *)adUnitID
           rootViewController:(UIViewController *)rootViewController {
  // [START native_ad_options]
  // Create a signal request for an ad.
  // Specify the "signal_type_ad_manager_s2s" to denote that the usage of @c GADSignal is for Ad
  // Manager S2S.
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
                 NSLog(@"Error getting signal: %@", error.localizedDescription);
                 return;
               }
               if (signal == nil) {
                 NSLog(@"Unexpected error - signal is nil.");
                 return;
               }
               NSLog(@"Signal string: %@", signal.signalString);
               // Fetch the ad response using your generated signal.
               NSString *adResponseString = [self fetchAdResponseString:signal];
               [self renderNative:adUnitID
                     adResponseString:adResponseString
                   rootViewController:rootViewController];
             }];
  // [END native_ad_options]
}

// [START fetch_response]
// Emulates a request to your ad server.
- (NSString *)fetchAdResponseString:(GADSignal *)signal {
  return @"adResponseString";
}
// [END fetch_response]

- (void)renderBanner:(NSString *)adUnitID
      adResponseString:(NSString *)adResponseString
    rootViewController:(UIViewController *)rootViewController {
  // [START render_banner]
  self.bannerView = [[GAMBannerView alloc]
      initWithAdSize:GADCurrentOrientationInlineAdaptiveBannerAdSizeWithWidth(375)];
  self.bannerView.adUnitID = adUnitID;
  self.bannerView.rootViewController = rootViewController;
  self.bannerView.delegate = self;
  [self.bannerView loadWithAdResponseString:adResponseString
                          completionHandler:^(NSError *_Nullable error) {
                            if (error) {
                              NSLog(@"Failed to load banner ad with error: %@", error);
                              return;
                            }
                            NSLog(@"Successfully loaded banner ad.");
                          }];
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

#pragma mark - GADBannerViewDelegate

- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView {
  NSLog(@"Banner ad received.");
}

- (void)bannerView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error {
  NSLog(@"Banner ad failed to load with error: %@", error);
}

#pragma mark - GAMBannerAdLoaderDelegate

- (void)adLoader:(nonnull GADAdLoader *)adLoader
    didReceiveGAMBannerView:(nonnull GAMBannerView *)bannerView {
  // GAM Banner ad received.
}

- (nonnull NSArray<NSValue *> *)validGAMBannerSizesForAdLoader:(nonnull GADAdLoader *)adLoader {
  return @[ NSValueFromGADAdSize(GADCurrentOrientationInlineAdaptiveBannerAdSizeWithWidth(375)) ];
}

#pragma mark - GADNativeAdLoaderDelegate

- (void)adLoader:(nonnull GADAdLoader *)adLoader
    didReceiveNativeAd:(nonnull GADNativeAd *)nativeAd {
  // Native ad received.
}

- (void)adLoader:(nonnull GADAdLoader *)adLoader
    didFailToReceiveAdWithError:(nonnull NSError *)error {
  // Native ad failed to load.
}

@end
