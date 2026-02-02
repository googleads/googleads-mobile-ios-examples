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

static NSString *const testAdUnitID = @"ca-app-pub-3940256099942544/2435281174";

@interface BannerSnippets : UIViewController <GADBannerViewDelegate>

@property(nonatomic, strong) GADBannerView *bannerView;

@end

@implementation BannerSnippets

- (void)viewDidLoad {
  [super viewDidLoad];
  [self setUpBannerViewProgrammatically];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self loadInlineAdaptiveBanner];
}

// [START handle_orientation_changes]
- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
  [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
    // Load a new ad for the new orientation.
  } completion:nil];
}
// [END handle_orientation_changes]

- (void)setUpBannerViewProgrammatically {
  // [START create_admob_banner_view]
  // Initialize the banner view.
  GADBannerView *bannerView = [[GADBannerView alloc] init];
  // [START set_delegate]
  bannerView.delegate = self;
  // [END set_delegate]
  UIView *view = self.view;

  bannerView.translatesAutoresizingMaskIntoConstraints = NO;
  [view addSubview:bannerView];

  // This example doesn't give width or height constraints, as the ad size gives the banner an
  // intrinsic content size to size the view.
  [NSLayoutConstraint activateConstraints:@[
    // Align the banner's bottom edge with the safe area's bottom edge
    [bannerView.bottomAnchor
        constraintEqualToAnchor:view.safeAreaLayoutGuide.bottomAnchor],
    // Center the banner horizontally in the view
    [bannerView.centerXAnchor constraintEqualToAnchor:view.centerXAnchor],
  ]];

  self.bannerView = bannerView;
  // [END create_admob_banner_view]
}

- (void)loadInlineAdaptiveBanner {
  GADBannerView *bannerView = self.bannerView;
  UIView *view = self.view;

  // [START get_width]
  CGFloat totalWidth = CGRectGetWidth(view.bounds);
  // Make sure the ad fits inside the readable area.
  UIEdgeInsets insets = view.safeAreaInsets;
  CGFloat adWidth = totalWidth - insets.left - insets.right;
  // [END get_width]

  // View is not laid out yet, return early.
  if (adWidth <= 0) {
    return;
  }

  // [START set_adaptive_ad_size]
  GADAdSize adSize = GADLargeLandscapeAnchoredAdaptiveBannerAdSizeWithWidth(adWidth);
  bannerView.adSize = adSize;
  // [END set_adaptive_ad_size]

  // Test ad unit ID for inline adaptive banners.
  bannerView.adUnitID = testAdUnitID;
  [bannerView loadRequest:[GADRequest request]];
}

- (void)createCustomAdSize:(GADBannerView *)bannerView {
  // [START create_custom_ad_size]
  bannerView.adSize = GADAdSizeFromCGSize(CGSizeMake(250, 250));
  // [END create_custom_ad_size]
}

// [START create_ad_view]
- (void)createAdView:(UIView *)adViewContainer
    rootViewController:(UIViewController *)rootViewController {
  GADBannerView *bannerView = [[GADBannerView alloc] initWithAdSize:GADAdSizeBanner];
  bannerView.adUnitID = testAdUnitID;
  bannerView.rootViewController = rootViewController;
  [adViewContainer addSubview:bannerView];
}
// [END create_ad_view]

- (void)loadBannerAd {
  // [START load_ad]
  // [START ad_size]
  // Request a large anchored adaptive banner with a width of 375.
  self.bannerView.adSize = GADLargeLandscapeAnchoredAdaptiveBannerAdSizeWithWidth(375);
  // [END ad_size]

  [self.bannerView loadRequest:[GADRequest request]];
  // [END load_ad]
}

  // [START ad_events]
- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView {
  NSLog(@"bannerViewDidReceiveAd");
}

- (void)bannerView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error {
  NSLog(@"bannerView:didFailToReceiveAdWithError: %@", [error localizedDescription]);
}

- (void)bannerViewDidRecordImpression:(GADBannerView *)bannerView {
  NSLog(@"bannerViewDidRecordImpression");
}

- (void)bannerViewWillPresentScreen:(GADBannerView *)bannerView {
  NSLog(@"bannerViewWillPresentScreen");
}

- (void)bannerViewWillDismissScreen:(GADBannerView *)bannerView {
  NSLog(@"bannerViewWillDismissScreen");
}

- (void)bannerViewDidDismissScreen:(GADBannerView *)bannerView {
  NSLog(@"bannerViewDidDismissScreen");
}

// [END ad_events]

@end
