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

@interface AdManagerBannerSnippets : UIViewController <GADAppEventDelegate>

@property(nonatomic, strong) GAMBannerView *bannerView;

@end

@implementation AdManagerBannerSnippets

- (void)viewDidLoad {
  [super viewDidLoad];
  [self setUpBannerViewProgrammatically];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self loadInlineAdaptiveBanner];
}

- (void)setUpBannerViewProgrammatically {
  // [START create_admanager_banner_view]
  // Initialize the banner view.
  GAMBannerView *bannerView = [[GAMBannerView alloc] init];
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
  // [END create_admanager_banner_view]
}

- (void)loadInlineAdaptiveBanner {
  GAMBannerView *bannerView = self.bannerView;
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
  GADAdSize adSize = GADCurrentOrientationInlineAdaptiveBannerAdSizeWithWidth(adWidth);
  bannerView.adSize = adSize;

  // For Ad Manager, the `adSize` property is used for the adaptive banner ad
  // size. The `validAdSizes` property is used as normal for the supported
  // reservation sizes for the ad placement.
  GADAdSize validAdSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(adWidth);
  bannerView.validAdSizes = @[ NSValueFromGADAdSize(validAdSize) ];
  // [END set_adaptive_ad_size]

  // Test ad unit ID for inline adaptive banners.
  bannerView.adUnitID = @"/21775744923/example/adaptive-banner";
  [bannerView loadRequest:[GAMRequest request]];
}

- (void)enableManualImpressionCountingForBannerView {
  // [START enable_manual_impression_counting]
  self.bannerView.enableManualImpressions = YES;
  // [END enable_manual_impression_counting]
}

- (void)recordManualImpression {
  // [START record_manual_impression]
  [self.bannerView recordImpression];
  // [END record_manual_impression]
}

- (void)setAppEventListener {
  // [START set_app_event_listener]
  // Set this property before making the request for an ad.
  self.bannerView.appEventDelegate = self;
  // [END set_app_event_listener]
}

// [START app_events]
- (void)bannerView:(GAMBannerView *)banner
    didReceiveAppEvent:(NSString *)name
              withInfo:(NSString *)info {
  if ([name isEqual:@"color"]) {
    if ([info isEqual:@"green"]) {
      // Set background color to green.
      self.view.backgroundColor = [UIColor greenColor];
    } else if ([info isEqual:@"blue"]) {
      // Set background color to blue.
      self.view.backgroundColor = [UIColor blueColor];
    } else {
      // Set background color to black.
      self.view.backgroundColor = [UIColor blackColor];
    }
  }
}
// [END app_events]

@end
