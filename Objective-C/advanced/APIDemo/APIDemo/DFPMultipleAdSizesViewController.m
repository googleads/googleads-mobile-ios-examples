//
//  Copyright (C) 2015 Google, Inc.
//
//  DFPMultipleAdSizesViewController.m
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

#import "DFPMultipleAdSizesViewController.h"

#import "Constants.h"

/// DFP - Multiple Ad Sizes
/// Demonstrates setting valid ad sizes for a DFPRequest.
@interface DFPMultipleAdSizesViewController () <GADAdSizeDelegate>

/// The custom banner size (120x20) switch.
@property(nonatomic, weak) IBOutlet UISwitch *GADAdSizeCustomBannerSwitch;

/// The banner size (320x50) switch.
@property(nonatomic, weak) IBOutlet UISwitch *GADAdSizeBannerSwitch;

/// The medium rectangle size (300x250) switch.
@property(nonatomic, weak) IBOutlet UISwitch *GADAdSizeMediumRectangleSwitch;

/// Loads an ad.
- (IBAction)loadAd:(id)sender;

/// The DFP banner view.
@property(nonatomic, strong) DFPBannerView *bannerView;

@end

@implementation DFPMultipleAdSizesViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.bannerView = [[DFPBannerView alloc] initWithAdSize:kGADAdSizeBanner];
  self.bannerView.adUnitID = kDFPAdSizesAdUnitID;
  self.bannerView.rootViewController = self;
  self.bannerView.adSizeDelegate = self;

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

#pragma mark - Actions

- (IBAction)loadAd:(id)sender {
  BOOL atLeastOneAdSizeSelected = self.GADAdSizeCustomBannerSwitch.isOn ||
                                  self.GADAdSizeBannerSwitch.isOn ||
                                  self.GADAdSizeMediumRectangleSwitch.isOn;

  if (!atLeastOneAdSizeSelected) {
    UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:@"Load Ad Error"
                                   message:@"Failed to load ad. Please select at least one ad size."
                                  delegate:nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
    [alert show];
    return;
  }

  NSMutableArray *adSizes = [[NSMutableArray alloc] init];

  if (self.GADAdSizeCustomBannerSwitch.isOn) {
    GADAdSize customGADAdSize = GADAdSizeFromCGSize(CGSizeMake(120, 20));
    [adSizes addObject:NSValueFromGADAdSize(customGADAdSize)];
  }
  if (self.GADAdSizeBannerSwitch.isOn) {
    [adSizes addObject:NSValueFromGADAdSize(kGADAdSizeBanner)];
  }
  if (self.GADAdSizeMediumRectangleSwitch.isOn) {
    [adSizes addObject:NSValueFromGADAdSize(kGADAdSizeMediumRectangle)];
  }

  self.bannerView.validAdSizes = adSizes;
  DFPRequest *request = [DFPRequest request];
  [self.bannerView loadRequest:request];
}

#pragma mark - GADAdSizeDelegate

/// Called before the ad view changes to the new size.
- (void)adView:(GADBannerView *)bannerView willChangeAdSizeTo:(GADAdSize)size {
  // bannerView calls this method on its adSizeDelegate object before the banner updates it size,
  // allowing the application to adjust any views that may be affected by the new ad size.
  NSLog(@"Make your app layout changes here, if necessary. New banner ad size will be %@.",
        NSStringFromGADAdSize(size));
}

@end
