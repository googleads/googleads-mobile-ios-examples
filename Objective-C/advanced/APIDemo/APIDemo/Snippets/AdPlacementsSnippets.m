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

// Replace with your own placement ID.
static long adPlacementID = 2500718471;
static NSString *const adUnitID = @"ca-app-pub-3940256099942544/4411468910";

@interface AdPlacementsSnippets : UIViewController

@end

@interface AdPlacementsSnippets ()
- (void)loadInterstitial;
- (void)showBannerView:(GADBannerView *)bannerView;
- (void)showAd:(GADInterstitialAd *)ad;
- (void)configureView:(GADNativeAdView *)nativeAdView withNativeAd:(GADNativeAd *)nativeAd;
@end

@implementation AdPlacementsSnippets

// [START load_interstitial]
- (void)loadInterstitial {
  GADRequest *request = [GADRequest request];
  request.placementID = adPlacementID;
  [GADInterstitialAd loadWithAdUnitID:adUnitID
                              request:request
                    completionHandler:^(GADInterstitialAd *ad, NSError *error) {
                      if (!error) {
                        NSLog(@"Placement ID: %lld", ad.placementID);
                        return;
                      }
                    }];
}
// [END load_interstitial]

// [START show_banner]
- (void)showBannerView:(GADBannerView *)bannerView {
  bannerView.placementID = adPlacementID;
  [self.view addSubview:bannerView];
}
// [END show_banner]

// [START show_interstitial]
- (void)showAd:(GADInterstitialAd *)ad {
  ad.placementID = adPlacementID;
  [ad presentFromRootViewController:self];
}
// [END show_interstitial]

// [START show_native]
- (void)configureView:(GADNativeAdView *)nativeAdView withNativeAd:(GADNativeAd *)nativeAd {
  nativeAd.placementID = adPlacementID;
  nativeAdView.nativeAd = nativeAd;
}
// [END show_native]

@end
