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

#import "ViewController.h"

// Video only FSN testing ad unit.
static NSString *const TestAdUnit = @"ca-app-pub-3940256099942544/5406332512";

@interface ViewController () <GADNativeAdLoaderDelegate,
                              GADVideoControllerDelegate,
                              GADNativeAdDelegate>

/// You must keep a strong reference to the GADAdLoader during the ad loading
/// process.
@property(nonatomic, strong) GADAdLoader *adLoader;

/// The native ad view that is being presented.
@property(nonatomic, strong) GADNativeAdView *nativeAdView;

/// The height constraint applied to the ad view, where necessary.
@property(nonatomic, strong) NSLayoutConstraint *heightConstraint;

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  [self setAdView:[[NSBundle mainBundle] loadNibNamed:@"NativeAdView" owner:nil options:nil]
                      .firstObject];
  [self refreshAd:nil];
}

- (IBAction)refreshAd:(id)sender {
  // Loads a native ad.
  self.refreshButton.enabled = NO;

  GADVideoOptions *videoOptions = [[GADVideoOptions alloc] init];
  videoOptions.startMuted = YES;
  videoOptions.customControlsRequested = YES;
  GADNativeAdMediaAdLoaderOptions *mediaLoaderOptions = [[GADNativeAdMediaAdLoaderOptions alloc]
                                                         init];
  mediaLoaderOptions.mediaAspectRatio = GADMediaAspectRatioPortrait;
  self.adLoader = [[GADAdLoader alloc] initWithAdUnitID:TestAdUnit
                                     rootViewController:self
                                                adTypes:@[ GADAdLoaderAdTypeNative ]
                                                options:@[ mediaLoaderOptions, videoOptions ]];
  self.adLoader.delegate = self;
  [self.adLoader loadRequest:[GADRequest request]];
}

- (void)setAdView:(GADNativeAdView *)view {
  // Remove previous ad view.
  [self.nativeAdView removeFromSuperview];
  self.nativeAdView = view;

  // Add new ad view and set constraints to fill its container.
  [self.nativeAdPlaceholder addSubview:view];
  //self.nativeAdViewsetTranslatesAutoresizingMaskIntoConstraints:NO];
  self.nativeAdView.translatesAutoresizingMaskIntoConstraints = NO;

  NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_nativeAdView);
  [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_nativeAdView]|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:viewDictionary]];
  [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_nativeAdView]|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:viewDictionary]];
}

#pragma mark GADAdLoaderDelegate implementation

- (void)adLoader:(GADAdLoader *)adLoader didFailToReceiveAdWithError:(NSError *)error {
  NSLog(@"%@ failed with error: %@", adLoader, error);
  self.refreshButton.enabled = YES;
}

#pragma mark GADNativeAdLoaderDelegate implementation

- (void)adLoader:(GADAdLoader *)adLoader didReceiveNativeAd:(GADNativeAd *)nativeAd {
  self.refreshButton.enabled = YES;

  GADNativeAdView *nativeAdView = self.nativeAdView;

  // Deactivate the height constraint that was set when the previous video ad loaded.
  self.heightConstraint.active = NO;

  // Set ourselves as the ad delegate to be notified of native ad events.
  nativeAd.delegate = self;

  // Populate the native ad view with the native ad assets.
  // The headline and mediaContent are guaranteed to be present in every native ad.
  ((UILabel *)nativeAdView.headlineView).text = nativeAd.headline;
  nativeAdView.mediaView.mediaContent = nativeAd.mediaContent;

  // This app uses a fixed width for the GADMediaView and changes its height
  // to match the aspect ratio of the media content it displays.
  if (nativeAd.mediaContent.aspectRatio > 0) {
    self.heightConstraint =
        [NSLayoutConstraint constraintWithItem:nativeAdView.mediaView
                                     attribute:NSLayoutAttributeHeight
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:nativeAdView.mediaView
                                     attribute:NSLayoutAttributeWidth
                                    multiplier:(1 / nativeAd.mediaContent.aspectRatio)
                                      constant:0];
    self.heightConstraint.active = YES;
  }

  // These assets are not guaranteed to be present. Check that they are before
  // showing or hiding them.
  ((UILabel *)nativeAdView.bodyView).text = nativeAd.body;
  nativeAdView.bodyView.hidden = nativeAd.body ? NO : YES;

  [((UIButton *)nativeAdView.callToActionView) setTitle:nativeAd.callToAction
                                               forState:UIControlStateNormal];
  nativeAdView.callToActionView.hidden = nativeAd.callToAction ? NO : YES;

  ((UIImageView *)nativeAdView.iconView).image = nativeAd.icon.image;
  nativeAdView.iconView.hidden = nativeAd.icon ? NO : YES;
  nativeAdView.iconView.layer.cornerRadius = 10;
  nativeAdView.iconView.clipsToBounds = true;

  // In order for the SDK to process touch events properly, user interaction
  // should be disabled.
  nativeAdView.callToActionView.userInteractionEnabled = NO;

  // Associate the native ad view with the native ad object. This is
  // required to make the ad clickable.
  // Note: this should always be done after populating the ad views.
  nativeAdView.nativeAd = nativeAd;
}

#pragma mark GADVideoControllerDelegate implementation

- (void)videoControllerDidEndVideoPlayback:(GADVideoController *)videoController {
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
