//
//  Copyright (C) 2018 Google, Inc.
//
//  SimpleNativeAdView.m
//  APIDemo
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "SimpleNativeAdView.h"

/// Headline asset key.
static NSString *const SimpleNativeAdViewHeadlineKey = @"Headline";

/// Main image asset key.
static NSString *const SimpleNativeAdViewMainImageKey = @"MainImage";

/// Caption asset key.
static NSString *const SimpleNativeAdViewCaptionKey = @"Caption";

@interface SimpleNativeAdView ()

/// The custom native ad that populated this view.
@property(nonatomic, strong) GADNativeCustomTemplateAd *customNativeAd;

@end

@implementation SimpleNativeAdView

- (void)awakeFromNib {
  [super awakeFromNib];

  // Enable clicks on the headline.
  [self.headlineView addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                              initWithTarget:self
                                                      action:@selector(performClickOnHeadline)]];
  self.headlineView.userInteractionEnabled = YES;
}

- (void)performClickOnHeadline {
  [self.customNativeAd performClickOnAssetWithKey:SimpleNativeAdViewHeadlineKey];
}

- (void)populateWithCustomNativeAd:(GADNativeCustomTemplateAd *)customNativeAd {
  self.customNativeAd = customNativeAd;
  // The custom click handler is an optional block which will override the normal click action
  // defined by the ad. Pass nil for the click handler to let the SDK process the default click
  // action.
  [self.customNativeAd setCustomClickHandler:^(NSString *assetID) {
    UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:@"Custom Click"
                                            message:@"You just clicked on the headline!"
                                     preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"OK"
                                                          style:UIAlertActionStyleCancel
                                                        handler:nil];
    [alert addAction:alertAction];
    [UIApplication.sharedApplication.keyWindow.rootViewController presentViewController:alert
                                                                               animated:YES
                                                                             completion:nil];
  }];

  // Populate the custom native ad assets.
  self.headlineView.text = [customNativeAd stringForKey:SimpleNativeAdViewHeadlineKey];
  self.captionView.text = [customNativeAd stringForKey:SimpleNativeAdViewCaptionKey];

  // Remove all the media placeholder's subviews.
  for (UIView *subview in self.mainPlaceholder.subviews) {
    [subview removeFromSuperview];
  }

  // This custom native ad has both a video and an image associated with it. We'll use the video
  // asset if available, and otherwise fallback to the image asset.
  UIView *mainView = nil;
  if (customNativeAd.videoController.hasVideoContent) {
    mainView = customNativeAd.mediaView;
  } else {
    UIImage *image = [customNativeAd imageForKey:SimpleNativeAdViewMainImageKey].image;
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
