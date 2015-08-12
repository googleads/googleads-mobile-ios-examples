//  Copyright (c) 2015 Google. All rights reserved.

@import UIKit;
@import GoogleMobileAds;

#import "MySimpleNativeAdView.h"

@interface ViewController : UIViewController

/// Container that holds the native ad.
@property(weak, nonatomic) IBOutlet UIView *nativeAdPlaceholder;

/// Switch to request app install ads.
@property(weak, nonatomic) IBOutlet UISwitch *appInstallAdSwitch;

/// Switch to request content ads.
@property(weak, nonatomic) IBOutlet UISwitch *contentAdSwitch;

/// Switch to custom native ads.
@property(weak, nonatomic) IBOutlet UISwitch *customNativeAdSwitch;

/// Refresh the native ad.
@property(weak, nonatomic) IBOutlet UIButton *refreshButton;

/// Refreshes the ad.
- (IBAction)refreshAd:(id)sender;

@end
