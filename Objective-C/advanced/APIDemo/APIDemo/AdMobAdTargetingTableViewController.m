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

#import "Constants.h"

/// The constants for table cell identifiers.
static NSString *const kChildDirectedCellIdentifier = @"childDirectedCell";
static NSString *const kChildDirectedPickerCellIdentifier = @"childDirectedPickerCell";

/// AdMob - Ad Targeting
/// Demonstrates AdMob ad targeting.
@interface AdMobAdTargetingTableViewController () <UIPickerViewDelegate,
                                                   UIPickerViewDataSource,
                                                   GADBannerViewDelegate>

/// The child-directed label.
@property(nonatomic, weak) IBOutlet UILabel *childDirectedLabel;

/// The child-directed picker.
@property(nonatomic, weak) IBOutlet UIPickerView *childDirectedPicker;

/// The banner view.
@property(nonatomic, weak) IBOutlet GADBannerView *bannerView;

/// Loads an ad based on user's birthdate, gender, and child-directed status.
- (IBAction)loadTargetedAd:(id)sender;

/// The child-directed options.
@property(nonatomic, copy) NSArray<NSString *> *childDirectedOptions;

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

  self.childDirectedOptions = @[ @"Yes", @"No", @"Unspecified" ];
  self.childDirectedPicker.delegate = self;
  self.childDirectedPicker.dataSource = self;
  [self.childDirectedPicker selectRow:1 inComponent:0 animated:NO];
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
  NSString *cellIdentifier = cell.reuseIdentifier;

  if ([cellIdentifier isEqual:kChildDirectedPickerCellIdentifier] &&
      self.childDirectedPicker.hidden) {
    return 0;
  }
  return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
  NSString *cellIdentifier = cell.reuseIdentifier;
  UIView *currentPickerView;

  if ([cellIdentifier isEqual:kChildDirectedCellIdentifier]) {
    currentPickerView = self.childDirectedPicker;
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
  if (pickerView == self.childDirectedPicker) {
    numberOfRows = self.childDirectedOptions.count;
  }
  return numberOfRows;
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component {
  NSString *titleForRow = @"";
  if (pickerView == self.childDirectedPicker) {
    titleForRow = self.childDirectedOptions[row];
  }
  return titleForRow;
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {
  if (pickerView == self.childDirectedPicker) {
    self.childDirectedLabel.text = self.childDirectedOptions[row];
  }
}

#pragma mark - Actions

- (IBAction)loadTargetedAd:(id)sender {
  self.bannerView.adUnitID = kAdMobAdUnitID;
  self.bannerView.rootViewController = self;
  self.bannerView.delegate = self;

  GADRequest *request = [GADRequest request];
  if ([self.childDirectedLabel.text isEqual:@"Yes"] ||
      [self.childDirectedLabel.text isEqual:@"No"]) {
    [GADMobileAds.sharedInstance.requestConfiguration
        tagForChildDirectedTreatment:self.childDirectedLabel.text.boolValue];
  }

  [self.bannerView loadRequest:request];
}

- (void)hideAllPickers {
  self.childDirectedPicker.hidden = YES;
}

#pragma mark - GADBannerViewDelegate

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
  NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error {
  NSLog(@"%s: %@", __PRETTY_FUNCTION__, error.localizedDescription);
}

@end
