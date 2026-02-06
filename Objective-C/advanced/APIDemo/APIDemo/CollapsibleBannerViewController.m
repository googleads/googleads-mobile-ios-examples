//
//  Copyright 2024 Google LLC
//
//  Licensed under the Apache License, Version 2.0 (the "License")
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

#import "CollapsibleBannerViewController.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "Constants.h"

@interface CollapsibleBannerViewController () <GADBannerViewDelegate>

@end

@implementation CollapsibleBannerViewController {
  // The banner ad view.
  GADBannerView *_bannerView;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  _bannerView = [[GADBannerView alloc] init];

  [self.view addSubview:_bannerView];

  _bannerView.translatesAutoresizingMaskIntoConstraints = false;

  // Layout constraints that align the banner view to the bottom center of the screen.
  [NSLayoutConstraint activateConstraints:@[
    [_bannerView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
    [_bannerView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor]
  ]];

  _bannerView.adUnitID = AdUnitIDCollapsibleBanner;
  _bannerView.rootViewController = self;
  _bannerView.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:true];

  // Here safe area is taken into account, hence the view frame is used after the
  // view has been laid out.
  CGRect frame = UIEdgeInsetsInsetRect(self.view.frame, self.view.safeAreaInsets);
  CGFloat viewWidth = frame.size.width;
  GADAdSize adSize = GADLargeAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth);
  _bannerView.adSize = adSize;

  [self loadAd];
}

- (IBAction)refreshAd:(id)sender {
  [self loadAd];
}

- (void)loadAd {
  GADRequest *request = [GADRequest request];

  // Create an extra parameter that aligns the bottom of the expanded ad to the
  // bottom of the bannerView.
  GADExtras *extras = [[GADExtras alloc] init];
  extras.additionalParameters = @{@"collapsible" : @"bottom"};
  [request registerAdNetworkExtras:extras];

  [_bannerView loadRequest:request];
}

#pragma mark - GADBannerViewDelegate

- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView {
  NSLog(@"The last loaded banner is %@collapsible.", (bannerView.isCollapsible ? @"" : @"not "));
  }

@end
