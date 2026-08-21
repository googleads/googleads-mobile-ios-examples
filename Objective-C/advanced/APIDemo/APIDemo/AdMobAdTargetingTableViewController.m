//
//  Copyright (C) 2015 Google, Inc.
//
//  AdMobAdTargetingTableViewController.m
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

#import "AdMobAdTargetingTableViewController.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

#import "Constants.h"

/// The constants for table cell identifiers.
static NSString *const kAgeRestrictedCellIdentifier = @"ageRestrictedCell";
static NSString *const kAgeRestrictedPickerCellIdentifier = @"ageRestrictedPickerCell";

/// AdMob - Ad Targeting
/// Demonstrates AdMob ad targeting.
@interface AdMobAdTargetingTableViewController () <UIPickerViewDelegate,
                                                   UIPickerViewDataSource,
                                                   GADBannerViewDelegate>

/// The age-restricted treatment label.
@property(nonatomic, weak) IBOutlet UILabel *ageRestrictedLabel;

/// The age-restricted treatment picker.
@property(nonatomic, weak) IBOutlet UIPickerView *ageRestrictedPicker;

/// The banner view.
@property(nonatomic, weak) IBOutlet GADBannerView *bannerView;

/// Loads an ad based on age-restricted treatment.
- (IBAction)loadTargetedAd:(id)sender;

/// The age-restricted treatment options.
@property(nonatomic, copy) NSArray<NSString *> *ageRestrictedOptions;

@end

@implementation AdMobAdTargetingTableViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  // Collapse table view footer view, display default section color for table view background.
  // Styling for larger screen sizes.
  self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
  UIColor *backgroundColor =
      [UIColor colorWithRed:247 / 255.0 green:247 / 255.0 blue:247 / 255.0 alpha:1.0];
  self.tableView.backgroundColor = backgroundColor;

  self.ageRestrictedOptions = @[ @"Child", @"Teen", @"Unspecified" ];
  self.ageRestrictedPicker.delegate = self;
  self.ageRestrictedPicker.dataSource = self;
  [self.ageRestrictedPicker selectRow:0 inComponent:0 animated:NO];
  self.ageRestrictedLabel.text = self.ageRestrictedOptions[0];
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
  NSString *cellIdentifier = cell.reuseIdentifier;

  if ([cellIdentifier isEqual:kAgeRestrictedPickerCellIdentifier] &&
      self.ageRestrictedPicker.hidden) {
    return 0;
  }
  return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
  NSString *cellIdentifier = cell.reuseIdentifier;
  UIView *currentPickerView;

  if ([cellIdentifier isEqual:kAgeRestrictedCellIdentifier]) {
    currentPickerView = self.ageRestrictedPicker;
  }

  BOOL isPickerHidden = currentPickerView.hidden;
  [self hideAllPickers];
  currentPickerView.hidden = !isPickerHidden;
  [tableView reloadData];
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView
    willDisplayHeaderView:(UIView *)view
               forSection:(NSInteger)section {
  view.tintColor = [UIColor clearColor];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
  return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
  NSInteger numberOfRows = 0;
  if (pickerView == self.ageRestrictedPicker) {
    numberOfRows = self.ageRestrictedOptions.count;
  }
  return numberOfRows;
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component {
  NSString *titleForRow = @"";
  if (pickerView == self.ageRestrictedPicker) {
    titleForRow = self.ageRestrictedOptions[row];
  }
  return titleForRow;
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {
  if (pickerView == self.ageRestrictedPicker) {
    self.ageRestrictedLabel.text = self.ageRestrictedOptions[row];
  }
}

#pragma mark - Actions

- (IBAction)loadTargetedAd:(id)sender {
  self.bannerView.adUnitID = AdUnitIDBanner;
  self.bannerView.rootViewController = self;
  self.bannerView.delegate = self;

  GADRequest *request = [GADRequest request];
  if ([self.ageRestrictedLabel.text isEqual:@"Child"]) {
    GADMobileAds.sharedInstance.requestConfiguration.ageRestrictedTreatment =
        GADAgeRestrictedTreatmentChild;
  } else if ([self.ageRestrictedLabel.text isEqual:@"Teen"]) {
    GADMobileAds.sharedInstance.requestConfiguration.ageRestrictedTreatment =
        GADAgeRestrictedTreatmentTeen;
  } else {
    GADMobileAds.sharedInstance.requestConfiguration.ageRestrictedTreatment =
        GADAgeRestrictedTreatmentUnspecified;
  }

  [self.bannerView loadRequest:request];
}

- (void)hideAllPickers {
  self.ageRestrictedPicker.hidden = YES;
}

#pragma mark - GADBannerViewDelegate

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
  NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error {
  NSLog(@"%s: %@", __PRETTY_FUNCTION__, error.localizedDescription);
}

@end
