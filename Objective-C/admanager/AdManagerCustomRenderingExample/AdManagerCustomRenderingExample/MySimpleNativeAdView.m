//  Copyright (c) 2015 Google. All rights reserved.

#import "MySimpleNativeAdView.h"

/// Headline asset key.
static NSString *const MySimpleNativeAdViewHeadlineKey = @"Headline";

/// Main image asset key.
static NSString *const MySimpleNativeAdViewMainImageKey = @"MainImage";

/// Caption asset key.
static NSString *const MySimpleNativeAdViewCaptionKey = @"Caption";

@interface MySimpleNativeAdView ()

/// The custom native ad that populated this view.
@property(nonatomic, strong) GADNativeCustomTemplateAd *customNativeAd;

@end

@implementation MySimpleNativeAdView

- (void)awakeFromNib {
  [super awakeFromNib];

  // Enable clicks on the headline.
  [self.headlineView addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                              initWithTarget:self
                                                      action:@selector(performClickOnHeadline)]];
  self.headlineView.userInteractionEnabled = YES;
}

- (void)performClickOnHeadline {
  [self.customNativeAd performClickOnAssetWithKey:MySimpleNativeAdViewHeadlineKey];
}

- (void)populateWithCustomNativeAd:(GADNativeCustomTemplateAd *)customNativeAd {
  self.customNativeAd = customNativeAd;
  // The custom click handler is an optional block which will override the normal click action
  // defined by the ad. Pass nil for the click handler to let the SDK process the default click
  // action.
  __weak typeof(self) weakSelf = self;
  [self.customNativeAd setCustomClickHandler:^(NSString *assetID) {
    [[[UIAlertView alloc] initWithTitle:@"Custom Click"
                                message:@"You just clicked on the headline!"
                               delegate:weakSelf
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
  }];

  // Populate the custom native ad assets.
  self.headlineView.text = [customNativeAd stringForKey:MySimpleNativeAdViewHeadlineKey];
  self.captionView.text = [customNativeAd stringForKey:MySimpleNativeAdViewCaptionKey];

  // Remove all the media placeholder's subviews.
  for (UIView *subview in self.mainPlaceholder.subviews) {
    [subview removeFromSuperview];
  }

  // This custom native ad also has a both a video and image associated with it. We'll use the video
  // asset if available, and otherwise fallback to the image asset.
  UIView *mainView = nil;
  if (customNativeAd.videoController.hasVideoContent) {
    mainView = customNativeAd.mediaView;
  } else {
    UIImage *image = [customNativeAd imageForKey:MySimpleNativeAdViewMainImageKey].image;
    mainView = [[UIImageView alloc] initWithImage:image];
  }
  [self.mainPlaceholder addSubview:mainView];

  // Size the media view to fill our container size.
  [mainView setTranslatesAutoresizingMaskIntoConstraints:NO];
  NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(mainView);
  [self.mainPlaceholder
      addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mainView]|"
                                                             options:0
                                                             metrics:nil
                                                               views:viewDictionary]];
  [self.mainPlaceholder
      addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[mainView]|"
                                                             options:0
                                                             metrics:nil
                                                               views:viewDictionary]];
}

@end
