//
//  Copyright (C) 2015 Google, Inc.
//
//  GAMFluidAdSizeViewController.m
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
//

#import "GAMFluidAdSizeViewController.h"

#import "Constants.h"

/// GAM - Fluid Ad Size
/// Demonstrates using the Fluid ad size - an ad size that spans the full width of its container,
/// with a height dynamically determined by the ad.
@interface GAMFluidAdSizeViewController ()

/// The DFP banner view.
@property(nonatomic, weak) IBOutlet DFPBannerView *bannerView;

/// The banner view's width constraint.
@property(nonatomic, weak) IBOutlet NSLayoutConstraint *bannerViewWidthConstraint;

/// Current banner width.
@property(nonatomic, weak) IBOutlet UILabel *bannerWidthLabel;

/// An array of banner widths.
@property(nonatomic, strong) NSArray<NSNumber *> *bannerWidths;

/// Current array index.
@property(nonatomic, assign) NSInteger currentIndex;

@end

@implementation GAMFluidAdSizeViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.bannerWidths = @[ @200, @250, @320 ];
  self.currentIndex = 0;

  self.bannerView.adUnitID = kAdManagerFluidAdSizeAdUnitID;
  self.bannerView.rootViewController = self;
  self.bannerView.adSize = kGADAdSizeFluid;
  [self.bannerView loadRequest:[DFPRequest request]];
}

/// Handles the user tapping on the "Change Banner Width" button.
- (IBAction)changeBannerWidth:(id)sender {
  CGFloat newWidth = self.bannerWidths[self.currentIndex % self.bannerWidths.count].floatValue;
  self.currentIndex += 1;
  self.bannerViewWidthConstraint.constant = newWidth;
  self.bannerWidthLabel.text = [[NSString alloc] initWithFormat:@"%.0f points", newWidth];
}

@end
