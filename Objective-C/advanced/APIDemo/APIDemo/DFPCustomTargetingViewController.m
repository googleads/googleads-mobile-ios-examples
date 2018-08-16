//
//  Copyright (C) 2015 Google, Inc.
//
//  DFPCustomTargetingViewController.m
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

#import "DFPCustomTargetingViewController.h"

#import "Constants.h"

/// The constant for the customTargeting dictionary sport preference key.
static NSString *const kSportPreferenceKey = @"sportpref";

/// DFP - Custom Targeting
/// Demonstrates adding custom targeting information to a DFPRequest.
@interface DFPCustomTargetingViewController () <UIPickerViewDelegate, UIPickerViewDataSource>

/// The DFP banner view.
@property(nonatomic, weak) IBOutlet DFPBannerView *bannerView;

/// The favorite sports view picker.
@property(nonatomic, weak) IBOutlet UIPickerView *favoriteSportsPicker;

/// Loads an ad.
- (IBAction)loadAd:(id)sender;

/// The favorite sports options.
@property(nonatomic, copy) NSArray *favoriteSportsOptions;

@end

@implementation DFPCustomTargetingViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.favoriteSportsOptions = @[
    @"Baseball",
    @"Basketball",
    @"Bobsled",
    @"Football",
    @"Ice Hockey",
    @"Running",
    @"Skiing",
    @"Snowboarding",
    @"Softball"
  ];
  self.favoriteSportsPicker.delegate = self;
  self.favoriteSportsPicker.dataSource = self;
  [self.favoriteSportsPicker selectRow:3 inComponent:0 animated:NO];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
  return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
  return self.favoriteSportsOptions.count;
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component {
  return self.favoriteSportsOptions[row];
}

#pragma mark - Actions

- (IBAction)loadAd:(id)sender {
  self.bannerView.adUnitID = kDFPCustomTargetingAdUnitID;
  self.bannerView.rootViewController = self;

  NSInteger row = [self.favoriteSportsPicker selectedRowInComponent:0];
  DFPRequest *request = [DFPRequest request];
  request.customTargeting = @{kSportPreferenceKey : self.favoriteSportsOptions[row]};
  [self.bannerView loadRequest:request];
}

@end
