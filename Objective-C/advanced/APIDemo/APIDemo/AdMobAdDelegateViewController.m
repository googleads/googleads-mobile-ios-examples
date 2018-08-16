//
//  Copyright (C) 2015 Google, Inc.
//
//  AdMobAdDelegateViewController.m
//  APIDemo
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

#import "AdMobAdDelegateViewController.h"

#import "Constants.h"

/// AdMob - Ad Delegate
/// Demonstrates handling GADBannerViewDelegate ad request status and ad click lifecycle messages.
/// This is an AdMob example, so it uses a GADBannerView to show an AdMob ad. GADBannerViewDelegate
/// also works with DFPBannerView objects, so publishers displaying ads from
/// DoubleClick For Publishers (DFP) can also use it with their banners. To see this in action,
/// use the DFPBannerView class instead of GADBannerView.
@interface AdMobAdDelegateViewController () <GADBannerViewDelegate>

/// The banner view.
@property(nonatomic, weak) IBOutlet GADBannerView *bannerView;

@end

@implementation AdMobAdDelegateViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.bannerView.delegate = self;

  self.bannerView.adUnitID = kAdMobAdUnitID;
  self.bannerView.rootViewController = self;

  GADRequest *request = [GADRequest request];
  [self.bannerView loadRequest:request];
}

#pragma mark - GADBannerViewDelegate

// Called when an ad request loaded an ad.
- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
  NSLog(@"%s", __PRETTY_FUNCTION__);
}

// Called when an ad request failed.
- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error {
  NSLog(@"%s: %@", __PRETTY_FUNCTION__, error.localizedDescription);
}

// Called just before presenting the user a full screen view, such as a browser, in response to
// clicking on an ad.
- (void)adViewWillPresentScreen:(GADBannerView *)bannerView {
  NSLog(@"%s", __PRETTY_FUNCTION__);
}

// Called just before dismissing a full screen view.
- (void)adViewWillDismissScreen:(GADBannerView *)bannerView {
  NSLog(@"%s", __PRETTY_FUNCTION__);
}

// Called just after dismissing a full screen view.
- (void)adViewDidDismissScreen:(GADBannerView *)bannerView {
  NSLog(@"%s", __PRETTY_FUNCTION__);
}

// Called just before the application will background or terminate because the user clicked on an ad
// that will launch another application (such as the App Store).
- (void)adViewWillLeaveApplication:(GADBannerView *)bannerView {
  NSLog(@"%s", __PRETTY_FUNCTION__);
}

@end
