//  Copyright (c) 2015 Google. All rights reserved.

#import "MySimpleNativeAdView.h"

/// Headline asset key.
static NSString *const kMySimpleNativeAdViewHeadlineKey = @"Headline";

/// Main image asset key.
static NSString *const kMySimpleNativeAdViewMainImageKey = @"MainImage";

/// Caption asset key.
static NSString *const kMySimpleNativeAdViewCaptionKey = @"Caption";

@interface MySimpleNativeAdView ()

/// The custom native ad that populated this view.
@property(strong, nonatomic) GADNativeCustomTemplateAd *customNativeAd;

@end

@implementation MySimpleNativeAdView

- (void)awakeFromNib {
  [super awakeFromNib];

  // Enable clicks on the main image.
  [self.mainImageView addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                               initWithTarget:self
                                                       action:@selector(performClickOnMainImage)]];
  self.mainImageView.userInteractionEnabled = YES;
}

- (void)performClickOnMainImage {
  // The custom click handler is an optional block which will override the normal click action
  // defined by the ad. Pass nil for the click handler to let the SDK process the default click
  // action.
  dispatch_block_t customClickHandler = ^{
    [[[UIAlertView alloc] initWithTitle:@"Custom Click"
                                message:@"You just clicked on the image!"
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
  };
  [self.customNativeAd performClickOnAssetWithKey:kMySimpleNativeAdViewMainImageKey
                               customClickHandler:customClickHandler];
}

- (void)populateWithCustomNativeAd:(GADNativeCustomTemplateAd *)customNativeAd {
  self.customNativeAd = customNativeAd;

  // Populate the custom native ad assets.
  self.headlineView.text = [customNativeAd stringForKey:kMySimpleNativeAdViewHeadlineKey];
  self.mainImageView.image = [customNativeAd imageForKey:kMySimpleNativeAdViewMainImageKey].image;
  self.captionView.text = [customNativeAd stringForKey:kMySimpleNativeAdViewCaptionKey];
}

@end
