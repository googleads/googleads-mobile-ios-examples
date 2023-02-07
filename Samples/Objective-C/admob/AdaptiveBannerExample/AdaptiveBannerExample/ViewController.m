//
//  Copyright (C) 2019 Google, Inc.
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
#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  // Replace this ad unit ID with your own ad unit ID.
  self.bannerView.adUnitID = @"ca-app-pub-3940256099942544/2435281174";
  self.bannerView.rootViewController = self;
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  // Note loadBannerAd is called in viewDidAppear as this is the first time that
  // the safe area is known. If safe area is not a concern (eg your app is locked
  // in portrait mode) the banner can be loaded in viewDidLoad.
  [self loadBannerAd];
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
  [coordinator
      animateAlongsideTransition:^(
          id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        [self loadBannerAd];
      }
                      completion:nil];
}

- (void)loadBannerAd {
  CGRect frame = self.view.frame;
  // Here safe area is taken into account, hence the view frame is used after the
  // view has been laid out.
  if (@available(iOS 11.0, *)) {
    frame = UIEdgeInsetsInsetRect(self.view.frame, self.view.safeAreaInsets);
  }
  CGFloat viewWidth = frame.size.width;

  // Here the current interface orientation is used. If the ad is being preloaded
  // for a future orientation change or different orientation, the function for the
  // relevant orientation should be used.
  self.bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth);

  [self.bannerView loadRequest:[GADRequest request]];
}

@end
