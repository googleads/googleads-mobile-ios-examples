//  Copyright (c) 2015 Google. All rights reserved.

#import "ViewController.h"

@interface ViewController () <GADNativeAppInstallAdLoaderDelegate, GADNativeContentAdLoaderDelegate,
                              GADNativeCustomTemplateAdLoaderDelegate>

/// You must keep a strong reference to the GADAdLoader during the ad loading process.
@property(strong, nonatomic) GADAdLoader *adLoader;

/// The native ad view that is being presented.
@property(strong, nonatomic) UIView *nativeAdView;

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.versionLabel.text = [GADRequest sdkVersion];

  [self refreshAd:nil];
}

- (IBAction)refreshAd:(id)sender {
  // Loads an ad for any of app install, content, or custom native ads.
  NSMutableArray *adTypes = [[NSMutableArray alloc] init];
  if (self.appInstallAdSwitch.on) {
    [adTypes addObject:kGADAdLoaderAdTypeNativeAppInstall];
  }
  if (self.contentAdSwitch.on) {
    [adTypes addObject:kGADAdLoaderAdTypeNativeContent];
  }
  if (self.customNativeAdSwitch.on) {
    [adTypes addObject:kGADAdLoaderAdTypeNativeCustomTemplate];
  }

  if (!adTypes.count) {
    NSLog(@"Error: You must specify at least one ad type to load.");
    return;
  }

  self.refreshButton.enabled = NO;
  self.adLoader = [[GADAdLoader alloc] initWithAdUnitID:@"/6499/example/native"
                                     rootViewController:self
                                                adTypes:adTypes
                                                options:nil];
  self.adLoader.delegate = self;
  [self.adLoader loadRequest:[GADRequest request]];
}

- (void)setAdView:(UIView *)view {
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

#pragma mark GADAdLoaderDelegate implementation

- (void)adLoader:(GADAdLoader *)adLoader didFailToReceiveAdWithError:(GADRequestError *)error {
  NSLog(@"%@ failed with error: %@", adLoader, [error localizedDescription]);
  self.refreshButton.enabled = YES;
}

#pragma mark GADNativeAppInstallAdLoaderDelegate implementation

- (void)adLoader:(GADAdLoader *)adLoader
    didReceiveNativeAppInstallAd:(GADNativeAppInstallAd *)nativeAppInstallAd {
  NSLog(@"Received native app install ad: %@", nativeAppInstallAd);
  self.refreshButton.enabled = YES;

  // Create and place ad in view hierarchy.
  GADNativeAppInstallAdView *appInstallAdView =
      [[[NSBundle mainBundle] loadNibNamed:@"NativeAppInstallAdView"
                                     owner:nil
                                   options:nil] firstObject];
  [self setAdView:appInstallAdView];

  // Associate the app install ad view with the app install ad object. This is required to make the
  // ad clickable.
  appInstallAdView.nativeAppInstallAd = nativeAppInstallAd;

  // Populate the app install ad view with the app install ad assets.
  // Some assets are guaranteed to be present in every app install ad.
  ((UILabel *)appInstallAdView.headlineView).text = nativeAppInstallAd.headline;
  ((UIImageView *)appInstallAdView.iconView).image = nativeAppInstallAd.icon.image;
  ((UILabel *)appInstallAdView.bodyView).text = nativeAppInstallAd.body;
  ((UIImageView *)appInstallAdView.imageView).image =
      ((GADNativeAdImage *)[nativeAppInstallAd.images firstObject]).image;
  [((UIButton *)appInstallAdView.callToActionView)setTitle:nativeAppInstallAd.callToAction
                                                  forState:UIControlStateNormal];

  // Other assets are not, however, and should be checked first.
  if (nativeAppInstallAd.starRating) {
    ((UIImageView *)appInstallAdView.starRatingView).image =
        [self imageForStars:nativeAppInstallAd.starRating];
    appInstallAdView.starRatingView.hidden = NO;
  } else {
    appInstallAdView.starRatingView.hidden = YES;
  }

  if (nativeAppInstallAd.store) {
    ((UILabel *)appInstallAdView.storeView).text = nativeAppInstallAd.store;
    appInstallAdView.storeView.hidden = NO;
  } else {
    appInstallAdView.storeView.hidden = YES;
  }

  if (nativeAppInstallAd.price) {
    ((UILabel *)appInstallAdView.priceView).text = nativeAppInstallAd.price;
    appInstallAdView.priceView.hidden = NO;
  } else {
    appInstallAdView.priceView.hidden = YES;
  }

  // In order for the SDK to process touch events properly, user interaction should be disabled.
  appInstallAdView.callToActionView.userInteractionEnabled = NO;
}

/// Gets an image representing the number of stars. Returns nil if rating is less than 3.5 stars.
- (UIImage *)imageForStars:(NSDecimalNumber *)numberOfStars {
  double starRating = [numberOfStars doubleValue];
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

#pragma mark GADNativeContentAdLoaderDelegate implementation

- (void)adLoader:(GADAdLoader *)adLoader
    didReceiveNativeContentAd:(GADNativeContentAd *)nativeContentAd {
  NSLog(@"Received native content ad: %@", nativeContentAd);
  self.refreshButton.enabled = YES;

  // Create and place ad in view hierarchy.
  GADNativeContentAdView *contentAdView =
      [[[NSBundle mainBundle] loadNibNamed:@"NativeContentAdView"
                                     owner:nil
                                   options:nil] firstObject];
  [self setAdView:contentAdView];

  // Associate the content ad view with the content ad object. This is required to make the ad
  // clickable.
  contentAdView.nativeContentAd = nativeContentAd;

  // Populate the content ad view with the content ad assets.
  // Some assets are guaranteed to be present in every content ad.
  ((UILabel *)contentAdView.headlineView).text = nativeContentAd.headline;
  ((UILabel *)contentAdView.bodyView).text = nativeContentAd.body;
  ((UIImageView *)contentAdView.imageView).image =
      ((GADNativeAdImage *)[nativeContentAd.images firstObject]).image;
  ((UILabel *)contentAdView.advertiserView).text = nativeContentAd.advertiser;
  [((UIButton *)contentAdView.callToActionView)setTitle:nativeContentAd.callToAction
                                               forState:UIControlStateNormal];

  // Other assets are not, however, and should be checked first.
  if (nativeContentAd.logo && nativeContentAd.logo.image) {
    ((UIImageView *)contentAdView.logoView).image = nativeContentAd.logo.image;
    contentAdView.logoView.hidden = NO;
  } else {
    contentAdView.logoView.hidden = YES;
  }

  // In order for the SDK to process touch events properly, user interaction should be disabled.
  contentAdView.callToActionView.userInteractionEnabled = NO;
}

#pragma mark GADNativeCustomTemplateAdLoaderDelegate implementation

- (void)adLoader:(GADAdLoader *)adLoader
    didReceiveNativeCustomTemplateAd:(GADNativeCustomTemplateAd *)nativeCustomTemplateAd {
  NSLog(@"Received custom native ad: %@", nativeCustomTemplateAd);
  self.refreshButton.enabled = YES;

  // Create and place ad in view hierarchy.
  MySimpleNativeAdView *mySimpleNativeAdView =
      [[[NSBundle mainBundle] loadNibNamed:@"SimpleCustomNativeAdView"
                                     owner:nil
                                   options:nil] firstObject];
  [self setAdView:mySimpleNativeAdView];

  // Populate the custom native ad view with its assets.
  [mySimpleNativeAdView populateWithCustomNativeAd:nativeCustomTemplateAd];
}

- (NSArray *)nativeCustomTemplateIDsForAdLoader:(GADAdLoader *)adLoader {
  return @[ @"10063170" ];
}

@end
