//  Copyright (c) 2015 Google. All rights reserved.

#import "ViewController.h"

static NSString *const TestAdUnit = @"/6499/example/native";
static NSString *const TestNativeCustomTemplateID = @"10104090";

@interface ViewController () <GADNativeAppInstallAdLoaderDelegate, GADNativeContentAdLoaderDelegate,
                              GADNativeCustomTemplateAdLoaderDelegate, GADVideoControllerDelegate>

/// You must keep a strong reference to the GADAdLoader during the ad loading process.
@property(nonatomic, strong) GADAdLoader *adLoader;

/// The native ad view that is being presented.
@property(nonatomic, strong) UIView *nativeAdView;

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

  GADVideoOptions *videoOptions = [[GADVideoOptions alloc] init];
  videoOptions.startMuted = self.startMutedSwitch.on;

  self.refreshButton.enabled = NO;
  self.adLoader = [[GADAdLoader alloc] initWithAdUnitID:TestAdUnit
                                     rootViewController:self
                                                adTypes:adTypes
                                                options:@[ videoOptions ]];
  self.adLoader.delegate = self;
  [self.adLoader loadRequest:[GADRequest request]];
  self.videoStatusLabel.text = @"";
}

- (void)setAdView:(UIView *)view {
  // Remove previous ad view.
  [self.nativeAdView removeFromSuperview];
  self.nativeAdView = view;

  // Add new ad view and set constraints to fill its container.
  [self.nativeAdPlaceholder addSubview:view];
  [self.nativeAdView setTranslatesAutoresizingMaskIntoConstraints:NO];

  NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_nativeAdView);
  [self.nativeAdPlaceholder
      addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_nativeAdView]|"
                                                             options:0
                                                             metrics:nil
                                                               views:viewDictionary]];
  [self.nativeAdPlaceholder
      addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_nativeAdView]|"
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
      [[NSBundle mainBundle] loadNibNamed:@"NativeAppInstallAdView" owner:nil options:nil]
          .firstObject;
  [self setAdView:appInstallAdView];

  // Associate the app install ad view with the app install ad object. This is required to make the
  // ad clickable.
  appInstallAdView.nativeAppInstallAd = nativeAppInstallAd;

  // Populate the app install ad view with the app install ad assets.
  // Some assets are guaranteed to be present in every app install ad.
  ((UILabel *)appInstallAdView.headlineView).text = nativeAppInstallAd.headline;
  ((UIImageView *)appInstallAdView.iconView).image = nativeAppInstallAd.icon.image;
  ((UILabel *)appInstallAdView.bodyView).text = nativeAppInstallAd.body;
  [((UIButton *)appInstallAdView.callToActionView)setTitle:nativeAppInstallAd.callToAction
                                                  forState:UIControlStateNormal];

  // Some app install ads will include a video asset, while others do not. Apps can use the
  // GADVideoController's hasVideoContent property to determine if one is present, and adjust their
  // UI accordingly.

  // The UI for this controller constrains the image view's height to match the media view's
  // height, so by changing the one here, the height of both views are being adjusted.
  if (nativeAppInstallAd.videoController.hasVideoContent) {
    // The video controller has content. Show the media view.
    appInstallAdView.mediaView.hidden = NO;
    appInstallAdView.imageView.hidden = YES;

    // This app uses a fixed width for the GADMediaView and changes its height to match the aspect
    // ratio of the video it displays.
    NSLayoutConstraint *heightConstraint =
    [NSLayoutConstraint constraintWithItem:appInstallAdView.mediaView
                                 attribute:NSLayoutAttributeHeight
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:appInstallAdView.mediaView
                                 attribute:NSLayoutAttributeWidth
                                multiplier:(1 / nativeAppInstallAd.videoController.aspectRatio)
                                  constant:0];
    heightConstraint.active = YES;

    // By acting as the delegate to the GADVideoController, this ViewController receives messages
    // about events in the video lifecycle.
    nativeAppInstallAd.videoController.delegate = self;

    self.videoStatusLabel.text = @"Ad contains a video asset.";
  } else {
    // If the ad doesn't contain a video asset, the first image asset is shown in the
    // image view. The existing lower priority height constraint is used.
    appInstallAdView.mediaView.hidden = YES;
    appInstallAdView.imageView.hidden = NO;

    GADNativeAdImage *firstImage = nativeAppInstallAd.images.firstObject;
    ((UIImageView *)appInstallAdView.imageView).image = firstImage.image;

    self.videoStatusLabel.text = @"Ad does not contain a video.";
  }

  // These assets are not guaranteed to be present, and should be checked first.
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

  contentAdView.translatesAutoresizingMaskIntoConstraints = NO;
  [self setAdView:contentAdView];

  // Associate the content ad view with the content ad object. This is required to make the ad
  // clickable.
  contentAdView.nativeContentAd = nativeContentAd;

  // Populate the content ad view with the content ad assets.
  // Some assets are guaranteed to be present in every content ad.
  ((UILabel *)contentAdView.headlineView).text = nativeContentAd.headline;
  ((UILabel *)contentAdView.bodyView).text = nativeContentAd.body;
  ((UILabel *)contentAdView.advertiserView).text = nativeContentAd.advertiser;
  [((UIButton *)contentAdView.callToActionView)setTitle:nativeContentAd.callToAction
                                               forState:UIControlStateNormal];

  // Some content ads will include a video asset, while others do not. Apps can use the
  // GADVideoController's hasVideoContent property to determine if one is present, and adjust their
  // UI accordingly.
  if (nativeContentAd.videoController.hasVideoContent) {
    // By acting as the delegate to the GADVideoController, this ViewController receives messages
    // about events in the video lifecycle.
    nativeContentAd.videoController.delegate = self;

    self.videoStatusLabel.text = @"Ad contains a video asset.";
  } else {
    self.videoStatusLabel.text = @"Ad does not contain a video.";
  }

  // These assets are not guaranteed to be present, and should be checked first.
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
      [[NSBundle mainBundle] loadNibNamed:@"SimpleCustomNativeAdView" owner:nil options:nil]
          .firstObject;
  [self setAdView:mySimpleNativeAdView];

  // Populate the custom native ad view with its assets.
  [mySimpleNativeAdView populateWithCustomNativeAd:nativeCustomTemplateAd];

  if (nativeCustomTemplateAd.videoController.hasVideoContent) {
    // By acting as the delegate to the GADVideoController, this ViewController receives messages
    // about events in the video lifecycle.
    nativeCustomTemplateAd.videoController.delegate = self;

    self.videoStatusLabel.text = @"Ad contains a video asset.";
  } else {
    self.videoStatusLabel.text = @"Ad does not contain a video.";
  }
}

- (NSArray *)nativeCustomTemplateIDsForAdLoader:(GADAdLoader *)adLoader {
  return @[ TestNativeCustomTemplateID ];
}

#pragma mark GADVideoControllerDelegate implementation

- (void)videoControllerDidEndVideoPlayback:(GADVideoController *)videoController {
  self.videoStatusLabel.text = @"Video playback has ended.";
}

@end
