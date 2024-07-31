// Copyright 2022 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "NativeAdViewController.h"

@interface NativeAdViewController () <GADNativeAdDelegate>

/// Container that holds the native ad.
@property(nonatomic, weak) IBOutlet UIView *nativeAdPlaceholder;

/// The native ad view that is being presented.
@property(nonatomic, strong) GADNativeAdView *nativeAdView;

/// The height constraint applied to the ad view, where necessary.
@property(nonatomic, strong) NSLayoutConstraint *heightConstraint;

@end

@implementation NativeAdViewController

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];

  [self setAdView:[[NSBundle mainBundle] loadNibNamed:@"NativeAdView" owner:nil options:nil]
                      .firstObject];

  GADNativeAdView *nativeAdView = self.nativeAdView;

  // Deactivate the height constraint that was set when the previous video ad loaded.
  self.heightConstraint.active = NO;

  // Populate the native ad view with the native ad assets.
  // The headline and mediaContent are guaranteed to be present in every native ad.
  ((UILabel *)nativeAdView.headlineView).text = self.nativeAd.headline;
  nativeAdView.mediaView.mediaContent = self.nativeAd.mediaContent;

  // These assets are not guaranteed to be present. Check that they are before
  // showing or hiding them.
  ((UILabel *)nativeAdView.bodyView).text = self.nativeAd.body;
  nativeAdView.bodyView.hidden = self.nativeAd.body ? NO : YES;

  [((UIButton *)nativeAdView.callToActionView) setTitle:self.nativeAd.callToAction
                                               forState:UIControlStateNormal];
  nativeAdView.callToActionView.hidden = self.nativeAd.callToAction ? NO : YES;

  ((UIImageView *)nativeAdView.iconView).image = self.nativeAd.icon.image;
  nativeAdView.iconView.hidden = self.nativeAd.icon ? NO : YES;
  nativeAdView.iconView.layer.cornerRadius = 10;
  nativeAdView.iconView.clipsToBounds = true;

  // This app uses a fixed width for the GADMediaView and changes its height
  // to match the aspect ratio of the media content it displays.
  if (self.nativeAd.mediaContent.aspectRatio > 0) {
    self.heightConstraint =
        [NSLayoutConstraint constraintWithItem:nativeAdView.mediaView
                                     attribute:NSLayoutAttributeHeight
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:nativeAdView.mediaView
                                     attribute:NSLayoutAttributeWidth
                                    multiplier:(1 / self.nativeAd.mediaContent.aspectRatio)
                                      constant:0];
    self.heightConstraint.active = YES;
  }

  // In order for the SDK to process touch events properly, user interaction
  // should be disabled.
  nativeAdView.callToActionView.userInteractionEnabled = NO;

  // Associate the native ad view with the native ad object. This is
  // required to make the ad clickable.
  // Note: this should always be done after populating the ad views.
  nativeAdView.nativeAd = self.nativeAd;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  // Set the ad delegate to be notified of native ad events.
  self.nativeAd.delegate = self;
}

- (void)setAdView:(GADNativeAdView *)view {
  // Remove previous ad view.
  [self.nativeAdView removeFromSuperview];
  self.nativeAdView = view;

  // Add new ad view and set constraints to fill its container.
  [self.nativeAdPlaceholder addSubview:view];
  //self.nativeAdViewsetTranslatesAutoresizingMaskIntoConstraints:NO];
  self.nativeAdView.translatesAutoresizingMaskIntoConstraints = NO;

  NSDictionary<NSString *, id> *viewDictionary = NSDictionaryOfVariableBindings(_nativeAdView);
  [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_nativeAdView]|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:viewDictionary]];
  [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_nativeAdView]|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:viewDictionary]];
}

#pragma mark GADNativeAdDelegate

- (void)nativeAdDidRecordClick:(GADNativeAd *)nativeAd {
  NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)nativeAdDidRecordImpression:(GADNativeAd *)nativeAd {
  NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)nativeAdWillPresentScreen:(GADNativeAd *)nativeAd {
  NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)nativeAdWillDismissScreen:(GADNativeAd *)nativeAd {
  NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)nativeAdDidDismissScreen:(GADNativeAd *)nativeAd {
  NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)nativeAdWillLeaveApplication:(GADNativeAd *)nativeAd {
  NSLog(@"%s", __PRETTY_FUNCTION__);
}

@end
