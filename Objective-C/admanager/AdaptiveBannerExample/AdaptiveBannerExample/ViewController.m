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

#import "ViewController.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

static NSString *_Nonnull const reservationAdUnitID =
    @"/30497360/adaptive_banner_test_iu/reservation";
static NSString *_Nonnull const backfillAdUnitID = @"/30497360/adaptive_banner_test_iu/backfill";

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.bannerView.rootViewController = self;
  self.bannerView.backgroundColor = UIColor.grayColor;
  [self updateLabel];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
  [coordinator
      animateAlongsideTransition:^(
          id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        [self loadBannerAd:nil];
      }
                      completion:nil];
}

- (IBAction)adUnitIDSwitchChanged:(id)sender {
  [self updateLabel];
}

- (void)updateLabel {
  self.iuLabel.text =
      [[self adUnitID] isEqual:reservationAdUnitID] ? @"Reservation Ad Unit" : @"Backfill Ad Unit";
}

- (NSString *)adUnitID {
  return self.iuSwitch.isOn ? reservationAdUnitID : backfillAdUnitID;
}

- (IBAction)loadBannerAd:(id)sender {
  CGRect frame = self.view.frame;
  // Here safe area is taken into account, hence the view frame is used after the
  // view has been laid out.
  if (@available(iOS 11.0, *)) {
    frame = UIEdgeInsetsInsetRect(self.view.frame, self.view.safeAreaInsets);
  }
  CGFloat viewWidth = frame.size.width;

  // Replace this ad unit ID with your own ad unit ID.
  self.bannerView.adUnitID = [self adUnitID];

  // Here the current interface orientation is used. If the ad is being preloaded
  // for a future orientation change or different orientation, the function for the
  // relevant orientation should be used.
  GADAdSize adaptiveSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth);

  // Note that Google may serve any reservation ads that that are smaller than
  // the adaptive size as outlined here - https://support.google.com/admanager/answer/9464128.
  // The returned ad will be centered in the ad view.
  self.bannerView.adSize = adaptiveSize;

  [self.bannerView loadRequest:[DFPRequest request]];
}

@end
