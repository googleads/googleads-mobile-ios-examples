//
//  Copyright 2015 Google LLC
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
//

#import "MySimpleNativeAdView.h"

/// Headline asset key.
static NSString *const MySimpleNativeAdViewHeadlineKey = @"Headline";

/// Main image asset key.
static NSString *const MySimpleNativeAdViewMainImageKey = @"MainImage";

/// Caption asset key.
static NSString *const MySimpleNativeAdViewCaptionKey = @"Caption";

@interface MySimpleNativeAdView ()

/// The custom native ad that populated this view.
@property(nonatomic) GADCustomNativeAd *customNativeAd;

@end

@implementation MySimpleNativeAdView

- (void)awakeFromNib {
  [super awakeFromNib];

  // Enable clicks on the headline.
  [self.headlineView addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                              initWithTarget:self
                                              action:@selector(performClickOnHeadline:)]];
  self.headlineView.userInteractionEnabled = YES;

  // Enable clicks on AdChoices.
  [self.adChoicesView addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                                initWithTarget:self
                                                action:@selector(performClickOnAdChoices:)]];
  self.adChoicesView.userInteractionEnabled = YES;
}

- (void)performClickOnHeadline:(UITapGestureRecognizer *)sender {
  [self.customNativeAd performClickOnAssetWithKey:MySimpleNativeAdViewHeadlineKey];
}

- (void)performClickOnAdChoices:(UITapGestureRecognizer *)sender {
  [self.customNativeAd performClickOnAssetWithKey:GADNativeAdChoicesViewAsset];
}

- (void)populateWithCustomNativeAd:(GADCustomNativeAd *)customNativeAd {
  self.customNativeAd = customNativeAd;

   // Render the AdChoices image.
  GADNativeAdImage *adChoicesAsset = [customNativeAd imageForKey:GADNativeAdChoicesViewAsset];
  if (adChoicesAsset) {
    self.adChoicesView.image = adChoicesAsset.image;
  }
  self.adChoicesView.hidden = (adChoicesAsset == nil);

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
  self.headlineView.text = [customNativeAd stringForKey:MySimpleNativeAdViewHeadlineKey];
  self.captionView.text = [customNativeAd stringForKey:MySimpleNativeAdViewCaptionKey];

  // Remove all the media placeholder's subviews.
  for (UIView *subview in self.mainPlaceholder.subviews) {
    [subview removeFromSuperview];
  }

  // This custom native ad also has a both a video and image associated with it. We'll use the video
  // asset if available, and otherwise fallback to the image asset.
  UIView *mainView = nil;
  if (customNativeAd.mediaContent.hasVideoContent) {
    GADMediaView *mediaView = [[GADMediaView alloc] init];
    mediaView.mediaContent = customNativeAd.mediaContent;
    mainView = mediaView;
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
