//
//  Copyright (C) 2015 Google, Inc.
//
//  AdMobBannerSizesViewController.m
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

#import "AdMobBannerSizesViewController.h"

#import "Constants.h"

/// AdMob - Banner Sizes
/// Demonstrates setting a desired banner size prior to loading an ad.
@interface AdMobBannerSizesViewController () <UIPickerViewDelegate, UIPickerViewDataSource>

/// The banner sizes picker.
@property(nonatomic, weak) IBOutlet UIPickerView *bannerSizesPicker;

/// Loads an ad based on banner size selected by user.
- (IBAction)loadAd:(id)sender;

/// The banner sizes.
@property(nonatomic, copy) NSArray *bannerSizes;

/// The banner sizes mapped to GADAdSize constants.
@property(nonatomic, copy) NSDictionary *ads;

/// The banner view.
@property(nonatomic, strong) GADBannerView *bannerView;

@end

@implementation AdMobBannerSizesViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.bannerSizesPicker.delegate = self;
  self.bannerSizesPicker.dataSource = self;

  switch ([UIDevice currentDevice].userInterfaceIdiom) {
    case UIUserInterfaceIdiomPhone:
      self.bannerSizes = @[ @"Large Banner", @"Banner", @"Smart Banner" ];
      [self.bannerSizesPicker selectRow:1 inComponent:0 animated:NO];
      break;
    case UIUserInterfaceIdiomPad:
      self.bannerSizes = @[
        @"Smart Banner",
        @"Large Banner",
        @"Banner",
        @"Full Banner",
        @"Medium Rectangle",
        @"Leaderboard"
      ];
      [self.bannerSizesPicker selectRow:2 inComponent:0 animated:NO];
      break;
    case UIUserInterfaceIdiomUnspecified:
      self.bannerSizes = @[ @"Large Banner", @"Banner", @"Smart Banner" ];
      [self.bannerSizesPicker selectRow:1 inComponent:0 animated:NO];
      break;
    default:
      break;
  }

  self.ads = @{
    @"Banner" : NSValueFromGADAdSize(kGADAdSizeBanner),
    @"Large Banner" : NSValueFromGADAdSize(kGADAdSizeLargeBanner),
    @"Smart Banner Portrait" : NSValueFromGADAdSize(kGADAdSizeSmartBannerPortrait),
    @"Smart Banner Landscape" : NSValueFromGADAdSize(kGADAdSizeSmartBannerLandscape),
    @"Full Banner" : NSValueFromGADAdSize(kGADAdSizeFullBanner),
    @"Medium Rectangle" : NSValueFromGADAdSize(kGADAdSizeMediumRectangle),
    @"Leaderboard" : NSValueFromGADAdSize(kGADAdSizeLeaderboard)
  };
}

#pragma mark - UIPickerViewDataSource

// Returns the number of columns to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
  return 1;
}

// Returns the number of rows in each component.
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
  return self.bannerSizes.count;
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component {
  return self.bannerSizes[row];
}

#pragma mark - Actions

- (IBAction)loadAd:(id)sender {
  if (!self.bannerView) {
    self.bannerView = [[GADBannerView alloc] init];
    self.bannerView.adUnitID = kAdMobAdUnitID;
    self.bannerView.rootViewController = self;

    [self.view addSubview:self.bannerView];
    self.bannerView.translatesAutoresizingMaskIntoConstraints = NO;

    // Layout constraints that align the banner view to the bottom center of the screen.
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.bannerView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.bannerView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1
                                                           constant:0]];
  }

  NSString *bannerSizeString = self.bannerSizes[[self.bannerSizesPicker selectedRowInComponent:0]];

  if ([bannerSizeString isEqual:@"Smart Banner"]) {
    if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)) {
      bannerSizeString = @"Smart Banner Portrait";
    } else {
      bannerSizeString = @"Smart Banner Landscape";
    }
  }

  self.bannerView.adSize = GADAdSizeFromNSValue(self.ads[bannerSizeString]);
  GADRequest *request = [GADRequest request];
  [self.bannerView loadRequest:request];
}

@end
