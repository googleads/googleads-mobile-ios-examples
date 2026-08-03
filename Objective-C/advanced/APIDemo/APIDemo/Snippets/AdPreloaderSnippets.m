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

#import <UIKit/UIKit.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <GoogleMobileAds/GoogleMobileAds_Beta.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdPreloaderSnippets : UIViewController <GADPreloadDelegate, GADFullScreenContentDelegate>

@end

NS_ASSUME_NONNULL_END

@implementation AdPreloaderSnippets

- (void)startPreloadingWithAdUnitID:(nonnull NSString *)adUnitID {
  // [START start_preload]
  // Start the preloading initialization process.
  GADRequest *request = [GADRequest request];
  GADPreloadConfigurationV2 *interstitialConfig =
      [[GADPreloadConfigurationV2 alloc] initWithAdUnitID:adUnitID
                                                  request:request];

  [GADInterstitialAdPreloader.sharedInstance preloadForPreloadID:adUnitID
                                                   configuration:interstitialConfig
                                                        delegate:self];
  // [END start_preload]
}

- (void)setBufferSizeWithAdUnitID:(nonnull NSString *)adUnitID {
  // [START set_buffer_size]
  GADPreloadConfigurationV2 *preloadConfig =
      [[GADPreloadConfigurationV2 alloc] initWithAdUnitID:adUnitID];
  // Define a PreloadConfiguration and set the buffer size to 2 preloaded ads.
  preloadConfig.bufferSize = 2;
  // [END set_buffer_size]
}

// [START pollAndShowAd]
- (void)showInterstitialAdWithAdUnitID:(nonnull NSString *)adUnitID {
  // Verify that the preloaded ad is available before polling.
  if (![self isInterstitialAvailableWithAdUnitID:adUnitID]) {
    NSLog(@"Preloaded interstitial ad is not available.");
    return;
  }

  // Getting the preloaded ad loads another ad in the background.
  GADInterstitialAd *ad =
      [GADInterstitialAdPreloader.sharedInstance adWithPreloadID:adUnitID];

  // Interact with the ad object as needed.
  NSLog(@"Interstitial ad response info: %@", ad.responseInfo);
  ad.paidEventHandler = ^(GADAdValue *_Nonnull value) {
    NSLog(@"Interstitial ad paid event: %@ %@ ", value.value, value.currencyCode);
  };
  ad.fullScreenContentDelegate = self;
  [ad presentFromRootViewController:self];
}
// [END pollAndShowAd]

// [START peek_ad]
- (void)getInterstitialAdResponseInfoWithPreloadID:(nonnull NSString *)preloadID {
  // Get the response info for the preloaded ad.
  GADResponseInfo *responseInfo =
      [GADInterstitialAdPreloader.sharedInstance
          adResponseInfoWithPreloadID:preloadID];
  if (responseInfo) {
    NSLog(@"Ad response ID: %@", responseInfo.responseIdentifier);
  }
}
// [END peek_ad]

// [START isAdAvailable]
- (BOOL)isInterstitialAvailableWithAdUnitID:(nonnull NSString *)adUnitID {
  // Verify that an ad is available before polling.
  return [GADInterstitialAdPreloader.sharedInstance isAdAvailableWithPreloadID:adUnitID];
}
// [END isAdAvailable]

#pragma mark - GADPreloadDelegate

// [START set_callback]
- (void)adAvailableForPreloadID:(nonnull NSString *)preloadID
                   responseInfo:(nonnull GADResponseInfo *)responseInfo {
  // This callback indicates that an ad is available for the specified configuration.
  // No action is required here, but updating the UI can be useful in some cases.
  NSLog(@"Ad preloaded successfully for ad unit ID: %@", preloadID);
}

- (void)adsExhaustedForPreloadID:(nonnull NSString *)preloadID {
  // This callback indicates that all the ads for the specified configuration have been
  // consumed and no ads are available to show. No action is required here, but updating
  // the UI can be useful in some cases.
  // Don't call [GAD<Format>AdPreloader preloadForPreloadID:] or
  // [GAD<Format>AdPreloader adWithPreloadID:] from adsExhaustedForPreloadID.
  NSLog(@"Ad exhausted for ad preload ID: %@", preloadID);
}

- (void)adFailedToPreloadForPreloadID:(nonnull NSString *)preloadID
                                error:(nonnull NSError *)error {
  NSLog(@"Ad failed to load with ad preload ID: %@, Error: %@", preloadID,
        error.localizedDescription);
}
// [END set_callback]

@end
