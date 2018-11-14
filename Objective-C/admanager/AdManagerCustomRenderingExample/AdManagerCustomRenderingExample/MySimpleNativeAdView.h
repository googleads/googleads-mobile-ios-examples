//  Copyright (c) 2015 Google. All rights reserved.

@import UIKit;
@import GoogleMobileAds;

/// View representing a custom native ad format with template ID 10063170.
@interface MySimpleNativeAdView : UIView

// Weak references to this ad's asset views.
@property(nonatomic, weak) IBOutlet UILabel *headlineView;
@property(nonatomic, weak) IBOutlet UIView *mainPlaceholder;
@property(nonatomic, weak) IBOutlet UILabel *captionView;

/// Populates the ad view with the custom native ad object.
- (void)populateWithCustomNativeAd:(GADNativeCustomTemplateAd *)customNativeAd;

@end
