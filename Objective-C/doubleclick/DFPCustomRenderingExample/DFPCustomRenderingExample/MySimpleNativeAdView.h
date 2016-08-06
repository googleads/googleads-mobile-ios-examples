//  Copyright (c) 2015 Google. All rights reserved.

@import UIKit;
@import GoogleMobileAds;

/// View representing a custom native ad format with template ID 10063170.
@interface MySimpleNativeAdView : UIView

// Weak references to this ad's asset views.
@property(weak, nonatomic) IBOutlet UILabel *headlineView;
@property(weak, nonatomic) IBOutlet UIImageView *mainImageView;
@property(weak, nonatomic) IBOutlet UILabel *captionView;

/// Populates the ad view with the custom native ad object.
- (void)populateWithCustomNativeAd:(GADNativeCustomTemplateAd *)customNativeAd;

@end
