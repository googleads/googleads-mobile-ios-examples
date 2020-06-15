// Copyright (C) 2018 Google, Inc.
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

#import "AdMobNativeCustomMuteThisAdViewController.h"

// Native Advanced ad unit ID for testing.
static NSString *const GADAPIDemoNativeTestAdUnit = @"ca-app-pub-3940256099942544/3986624511";

@interface AdMobNativeCustomMuteThisAdViewController () <GADUnifiedNativeAdLoaderDelegate,
                                                         GADVideoControllerDelegate,
                                                         GADUnifiedNativeAdDelegate,
                                                         UIPickerViewDelegate,
                                                         UIPickerViewDataSource>

/// You must keep a strong reference to the GADAdLoader during the ad loading process.
@property(nonatomic, strong) GADAdLoader *adLoader;

/// The native ad view that is being presented.
@property(nonatomic, strong) GADUnifiedNativeAdView *nativeAdView;

/// The height constraint applied to the ad view, where necessary.
@property(nonatomic, strong) NSLayoutConstraint *heightConstraint;

/// A picker view for displaying mute this ad reasons.
@property(weak, nonatomic) IBOutlet UIPickerView *pickerView;

/// An array of mute reasons for displaying custom Mute This Ad interface.
@property(nonatomic, copy) NSArray<GADMuteThisAdReason *> *muteReasons;

@end

@implementation AdMobNativeCustomMuteThisAdViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.versionLabel.text = [GADRequest sdkVersion];

  NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"UnifiedNativeAdView"
                                                      owner:nil
                                                    options:nil];
  [self setAdView:nibObjects.firstObject];
  self.nativeAdView.hidden = YES;

  self.pickerView.dataSource = self;
  self.pickerView.delegate = self;
  [self refreshAd:nil];
}

- (IBAction)refreshAd:(id)sender {
  // Loads an ad for unified native ad.
  self.refreshButton.enabled = NO;

  // Provide the custom mute this ad loader options to request custom mute feature.
  GADNativeMuteThisAdLoaderOptions *muteOptions = [GADNativeMuteThisAdLoaderOptions new];
  self.adLoader = [[GADAdLoader alloc] initWithAdUnitID:GADAPIDemoNativeTestAdUnit
                                     rootViewController:self
                                                adTypes:@[ kGADAdLoaderAdTypeUnifiedNative ]
                                                options:@[ muteOptions ]];
  self.adLoader.delegate = self;
  [self.adLoader loadRequest:[GADRequest request]];
}

- (void)setAdView:(GADUnifiedNativeAdView *)view {
  // Remove previous ad view.
  [self.nativeAdView removeFromSuperview];
  self.nativeAdView = view;

  // Add new ad view and set constraints to fill its container.
  [self.nativeAdPlaceholder addSubview:view];
  [self.nativeAdView setTranslatesAutoresizingMaskIntoConstraints:NO];

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

/// Gets an image representing the number of stars. Returns nil if rating is less than 3.5 stars.
- (UIImage *)imageForStars:(NSDecimalNumber *)numberOfStars {
  double starRating = numberOfStars.doubleValue;
  if (starRating >= 5) {
    return [UIImage imageNamed:@"stars_5"];
  } else if (starRating >= 4.5) {
    return [UIImage imageNamed:@"stars_4_5"];
  } else if (starRating >= 4) {
    return [UIImage imageNamed:@"stars_4"];
  } else if (starRating >= 3.5) {
    return [UIImage imageNamed:@"stars_3_5"];
  } else {
    return nil;
  }
}

#pragma mark Custom Mute implementation

// Called when mute ad button is pressed.
- (IBAction)muteAd:(id)sender {
  [self showMuteAdDialog];
}

// Called when a mute reason is selected.
- (void)muteAdDialogDidSelectReason:(GADMuteThisAdReason *)reason {
  [self.nativeAdView.nativeAd muteThisAdWithReason:reason];
  [self resetMuteAdDialog];
  [self muteAd];
}

- (void)showMuteAdDialog {
  GADUnifiedNativeAd *nativeAd = self.nativeAdView.nativeAd;
  NSArray *reasons = nativeAd.muteThisAdReasons;
  if (!self.pickerView.isHidden || nativeAd == nil || reasons == nil) {
    return;
  }

  self.muteAdButton.enabled = NO;
  self.muteReasons = reasons;

  [self.pickerView reloadComponent:0];

  // Show the picker view.
  self.pickerView.hidden = NO;
}

- (void)muteAd {
  // Our custom mute implementation simply hides the ad view.
  self.nativeAdView.hidden = YES;
}

// Resets the mute ad interface.
- (void)resetMuteAdDialog {
  self.pickerView.hidden = YES;
  self.muteReasons = nil;
}

#pragma mark UIPickerViewDataSource implementation

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
  return self.muteReasons.count;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
  return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component {
  return self.muteReasons[row].reasonDescription;
}

#pragma mark UIPickerViewDelegate implementation

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {
  [self muteAdDialogDidSelectReason:self.muteReasons[row]];
}

#pragma mark GADAdLoaderDelegate implementation

- (void)adLoader:(GADAdLoader *)adLoader didFailToReceiveAdWithError:(GADRequestError *)error {
  NSLog(@"%@ failed with error: %@", adLoader, error);
  self.refreshButton.enabled = YES;
}

#pragma mark GADUnifiedNativeAdLoaderDelegate implementation

- (void)adLoader:(GADAdLoader *)adLoader didReceiveUnifiedNativeAd:(GADUnifiedNativeAd *)nativeAd {
  self.refreshButton.enabled = YES;

  GADUnifiedNativeAdView *nativeAdView = self.nativeAdView;
  self.nativeAdView.hidden = NO;

  /// Enable the mute button if custom mute is available.
  self.muteAdButton.enabled = nativeAd.isCustomMuteThisAdAvailable;

  // Deactivate the height constraint that was set when the previous video ad loaded.
  self.heightConstraint.active = NO;

  // Set ourselves as the ad delegate to be notified of native ad events.
  nativeAd.delegate = self;

  // Populate the native ad view with the native ad assets.
  // Some assets are guaranteed to be present in every native ad.
  ((UILabel *)nativeAdView.headlineView).text = nativeAd.headline;
  nativeAdView.mediaView.mediaContent = nativeAd.mediaContent;

  // The UI for this controller constrains the image view's height to match the
  // media view's height, so by changing the one here, the height of both views
  // are being adjusted.
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

  // These assets are not guaranteed to be present, and should be checked first.
  ((UIImageView *)nativeAdView.iconView).image = nativeAd.icon.image;
  nativeAdView.iconView.hidden = nativeAd.icon ? NO : YES;

  ((UIImageView *)nativeAdView.starRatingView).image = [self imageForStars:nativeAd.starRating];
  nativeAdView.starRatingView.hidden = nativeAd.starRating ? NO : YES;

  ((UILabel *)nativeAdView.storeView).text = nativeAd.store;
  nativeAdView.storeView.hidden = nativeAd.store ? NO : YES;

  ((UILabel *)nativeAdView.priceView).text = nativeAd.price;
  nativeAdView.priceView.hidden = nativeAd.price ? NO : YES;

  ((UILabel *)nativeAdView.advertiserView).text = nativeAd.advertiser;
  nativeAdView.advertiserView.hidden = nativeAd.advertiser ? NO : YES;

  // In order for the SDK to process touch events properly, user interaction
  // should be disabled.
  nativeAdView.callToActionView.userInteractionEnabled = NO;

  // Associate the native ad view with the native ad object. This is
  // required to make the ad clickable.
  // Note: this should always be done after populating the ad views.
  nativeAdView.nativeAd = nativeAd;

}

#pragma mark GADUnifiedNativeAdDelegate

- (void)nativeAdIsMuted:(GADUnifiedNativeAd *)nativeAd {
  NSLog(@"%s", __PRETTY_FUNCTION__);
}

@end
