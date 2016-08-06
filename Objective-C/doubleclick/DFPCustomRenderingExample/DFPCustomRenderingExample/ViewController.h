//  Copyright (c) 2015 Google. All rights reserved.

@import UIKit;
@import GoogleMobileAds;

#import "MySimpleNativeAdView.h"

@interface ViewController : UIViewController

/// Container that holds the native ad.
@property(nonatomic, weak) IBOutlet UIView *nativeAdPlaceholder;

/// Switch to request app install ads.
@property(nonatomic, weak) IBOutlet UISwitch *appInstallAdSwitch;

/// Switch to request content ads.
@property(nonatomic, weak) IBOutlet UISwitch *contentAdSwitch;

/// Switch to custom native ads.
@property(nonatomic, weak) IBOutlet UISwitch *customNativeAdSwitch;

/// Refresh the native ad.
@property(nonatomic, weak) IBOutlet UIButton *refreshButton;

/// The Google Mobile Ads SDK version number label.
@property(nonatomic, weak) IBOutlet UILabel *versionLabel;

/// Refreshes the ad.
- (IBAction)refreshAd:(id)sender;

@end
