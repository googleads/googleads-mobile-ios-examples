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

NS_ASSUME_NONNULL_BEGIN

// Replace this ad unit ID with your own ad unit ID.
static NSString *const kNativeAdUnitID = @"ca-app-pub-3940256099942544/3986624511";

@interface NativeAdSnippets : UIViewController <GADNativeAdLoaderDelegate,
                                                GADNativeAdDelegate,
                                                GADCustomNativeAdLoaderDelegate,
                                                GADCustomNativeAdDelegate>
@property(nonatomic, strong) GADAdLoader *adLoader;
@end

@implementation NativeAdSnippets

- (void)viewDidLoad {
  [super viewDidLoad];
  [self setNativeAdLoader];
}

- (void)setNativeAdLoader {
  // [START set_ad_loader]
  self.adLoader =
      [[GADAdLoader alloc] initWithAdUnitID:kNativeAdUnitID
                         // The UIViewController parameter is optional.
                         rootViewController:self
                                    // To receive native ads, the ad loader's delegate must
                                    // conform to the NativeAdLoaderDelegate protocol.
                                    adTypes:@[ GADAdLoaderAdTypeNative ]
                                    // Use nil for default options.
                                    options:nil];
  // Set the delegate before making an ad request.
  self.adLoader.delegate = self;
  // [END set_ad_loader]
}

/**
 * Loads an AdMob native ad.
 */
- (void)loadAdMobNativeAd {
  // [START load_ad]
  [self.adLoader loadRequest:[GADRequest request]];
  // [END load_ad]
}

/**
 * Loads an Ad Manager native ad.
 */
- (void)loadAdManagerNativeAd {
  // [START load_admanager_ad]
  [self.adLoader loadRequest:[GAMRequest request]];
  // [END load_admanager_ad]
}

- (void)loadMultipleNativeAds {
  // [START load_multiple_ads]
  GADMultipleAdsAdLoaderOptions *multipleAdOptions = [[GADMultipleAdsAdLoaderOptions alloc] init];
  multipleAdOptions.numberOfAds = 5;

  self.adLoader = [[GADAdLoader alloc] initWithAdUnitID:kNativeAdUnitID
                                     // The UIViewController parameter is optional.
                                     rootViewController:self
                                                adTypes:@[ GADAdLoaderAdTypeNative ]
                                                options:@[ multipleAdOptions ]];
  // [END load_multiple_ads]
}

- (void)setContentMode:(GADNativeAdView *)nativeAdView forAd:(GADNativeAd *)ad {
  // [START set_content_mode]
  nativeAdView.mediaView.contentMode = UIViewContentModeScaleAspectFit;
  // [END set_content_mode]
}

#pragma mark - GADNativeAdLoaderDelegate

// [START ad_loader_did_receive_ad]
- (void)adLoader:(GADAdLoader *)adLoader didReceiveNativeAd:(GADNativeAd *)nativeAd {
  // Set the delegate to receive notifications for interactions with the native ad.
  // [START set_native_ad_delegate]
  nativeAd.delegate = self;
  // [END set_native_ad_delegate]

  // TODO: Display the native ad.
}
// [END ad_loader_did_receive_ad]

// [START ad_loader_did_finish_loading]
- (void)adLoaderDidFinishLoading:(GADAdLoader *)adLoader {
  // The adLoader has finished loading ads.
}
// [END ad_loader_did_finish_loading]

// [START ad_loader_failed]
- (void)adLoader:(GADAdLoader *)adLoader didFailToReceiveAdWithError:(NSError *)error {
  // The adLoader failed to receive an ad.
}
// [END ad_loader_failed]

#pragma mark - GADCustomNativeAdLoaderDelegate

// [START ad_loader_did_receive_custom_ad]
- (void)adLoader:(GADAdLoader *)adLoader
    didReceiveCustomNativeAd:(GADCustomNativeAd *)customNativeAd {
  // To be notified of events related to the custom native ad interactions, set the delegate
  // property of the native ad
  customNativeAd.delegate = self;

  // TODO: Display the custom native ad.
}
// [END ad_loader_did_receive_custom_ad]

- (NSArray<NSString *> *)customNativeAdFormatIDsForAdLoader:(GADAdLoader *)adLoader {
  // Your list of custom native ad format IDs for the ad loader.
  return @[];
}

#pragma mark - GADNativeAdDelegate

// [START native_ad_delegate_methods]
- (void)nativeAdDidRecordImpression:(GADNativeAd *)nativeAd {
  // The native ad was shown.
}

- (void)nativeAdDidRecordClick:(GADNativeAd *)nativeAd {
  // The native ad was clicked on.
}

- (void)nativeAdWillPresentScreen:(GADNativeAd *)nativeAd {
  // The native ad will present a full screen view.
}

- (void)nativeAdWillDismissScreen:(GADNativeAd *)nativeAd {
  // The native ad will dismiss a full screen view.
}

- (void)nativeAdDidDismissScreen:(GADNativeAd *)nativeAd {
  // The native ad did dismiss a full screen view.
}

- (void)nativeAdWillLeaveApplication:(GADNativeAd *)nativeAd {
  // The native ad will cause the app to become inactive and
  // open a new app.
}
// [END native_ad_delegate_methods]

#pragma mark - GADCustomNativeAdDelegate

- (void)customNativeAdDidRecordImpression:(GADCustomNativeAd *)customNativeAd {
  // The custom native ad was shown.
}

- (void)customNativeAdDidRecordClick:(GADCustomNativeAd *)customNativeAd {
  // The custom native ad was clicked on.
}

- (void)customNativeAdWillDismissScreen:(GADCustomNativeAd *)customNativeAd {
  // The custom native ad will dismiss a full screen view.
}

- (void)customNativeAdDidDismissScreen:(GADCustomNativeAd *)customNativeAd {
  // The custom native ad did dismiss a full screen view.
}

- (void)customNativeAdWillPresentScreen:(GADCustomNativeAd *)customNativeAd {
  // The custom native ad will cause the app to become inactive and
  // open a new app.
}

NS_ASSUME_NONNULL_END

@end
