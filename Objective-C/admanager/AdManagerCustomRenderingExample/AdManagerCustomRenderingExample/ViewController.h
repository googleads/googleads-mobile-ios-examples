//  Copyright (c) 2015 Google. All rights reserved.

#import <UIKit/UIKit.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

#import "MySimpleNativeAdView.h"

@interface ViewController : UIViewController

/// Container that holds the native ad.
@property(nonatomic, weak) IBOutlet UIView *nativeAdPlaceholder;

/// Displays status messages about presence of video assets.
@property(nonatomic, weak) IBOutlet UILabel *videoStatusLabel;

/// Switch to request app install ads.
@property(nonatomic, weak) IBOutlet UISwitch *unifiedNativeAdSwitch;

/// Switch to custom native ads.
@property(nonatomic, weak) IBOutlet UISwitch *customNativeAdSwitch;

/// Switch to indicate if video ads should start muted.
@property(nonatomic, weak) IBOutlet UISwitch *startMutedSwitch;

/// Refresh the native ad.
@property(nonatomic, weak) IBOutlet UIButton *refreshButton;

/// The Google Mobile Ads SDK version number label.
@property(nonatomic, weak) IBOutlet UILabel *versionLabel;

/// Refreshes the ad.
- (IBAction)refreshAd:(id)sender;

@end
