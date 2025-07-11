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

@interface BannerSnippets : UIViewController

@property(nonatomic, strong) GADBannerView *bannerView;

@end

@implementation BannerSnippets

- (void)viewDidLoad {
  [super viewDidLoad];
  [self createBannerViewProgrammatically];
}

- (void)createBannerViewProgrammatically {
    // [START create_banner_view]
    // Initialize the GADBannerView.
    self.bannerView = [[GADBannerView alloc] init];

    self.bannerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.bannerView];

    // This example doesn't give width or height constraints, as the ad size gives the banner an
    // intrinsic content size to size the view.
    [NSLayoutConstraint activateConstraints:@[
        // Align the banner's bottom edge with the safe area's bottom edge
        [self.bannerView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
        // Center the banner horizontally in the view
        [self.bannerView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
    ]];
    // [END create_banner_view]
}

@end