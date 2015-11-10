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

@import CoreLocation;

#import "AdMobAdTargetingTableViewController.h"

#import "Constants.h"

/// The constants for table cell identifiers.
static NSString *const kBirthdateCellIdentifier = @"birthdateCell";
static NSString *const kBirthdatePickerCellIdentifier = @"birthdatePickerCell";
static NSString *const kGenderCellIdentifier = @"genderCell";
static NSString *const kGenderPickerCellIdentifier = @"genderPickerCell";
static NSString *const kChildDirectedCellIdentifier = @"childDirectedCell";
static NSString *const kChildDirectedPickerCellIdentifier = @"childDirectedPickerCell";

/// AdMob - Ad Targeting
/// Demonstrates AdMob ad targeting.
@interface AdMobAdTargetingTableViewController () <UIPickerViewDelegate, UIPickerViewDataSource,
                                                   CLLocationManagerDelegate>

/// The current location label.
@property(nonatomic, weak) IBOutlet UILabel *locationLabel;

/// The birthdate label.
@property(nonatomic, weak) IBOutlet UILabel *birthdateLabel;

/// The gender label.
@property(nonatomic, weak) IBOutlet UILabel *genderLabel;

/// The child-directed label.
@property(nonatomic, weak) IBOutlet UILabel *childDirectedLabel;

/// The birthdate picker.
@property(nonatomic, weak) IBOutlet UIDatePicker *birthdatePicker;

/// The gender picker.
@property(nonatomic, weak) IBOutlet UIPickerView *genderPicker;

/// The child-directed picker.
@property(nonatomic, weak) IBOutlet UIPickerView *childDirectedPicker;

/// The banner view.
@property(nonatomic, weak) IBOutlet GADBannerView *bannerView;

/// Loads an ad based on user's location, birthdate, gender and child-directed status.
- (IBAction)loadTargetedAd:(id)sender;

/// Sets the birthdate label to birthdate selected in picker.
- (IBAction)chooseBirthdate:(id)sender;

/// The location manager.
@property(nonatomic, strong) CLLocationManager *locationManager;

/// The user's current location.
@property(nonatomic, strong) CLLocation *currentLocation;

/// The birthdate formatter, ex: Jan 31, 1980.
@property(nonatomic, strong) NSDateFormatter *dateFormatter;

/// The gender options.
@property(nonatomic, copy) NSArray *genderOptions;

/// The child-directed options.
@property(nonatomic, copy) NSArray *childDirectedOptions;

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

  self.dateFormatter = [[NSDateFormatter alloc] init];
  self.dateFormatter.dateStyle = NSDateFormatterMediumStyle;

  self.genderOptions = @[ @"Male", @"Female", @"Unknown" ];
  self.genderPicker.delegate = self;
  self.genderPicker.dataSource = self;
  [self.genderPicker selectRow:1 inComponent:0 animated:NO];

  self.childDirectedOptions = @[ @"Yes", @"No", @"Unspecified" ];
  self.childDirectedPicker.delegate = self;
  self.childDirectedPicker.dataSource = self;
  [self.childDirectedPicker selectRow:1 inComponent:0 animated:NO];

  // CLLocationManager setup.
  self.locationManager = [[CLLocationManager alloc] init];
  self.locationManager.delegate = self;
  self.locationManager.distanceFilter = kCLDistanceFilterNone;
  self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
  if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
    [self.locationManager requestWhenInUseAuthorization];
  }
  [self.locationManager startUpdatingLocation];
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
  NSString *cellIdentifier = cell.reuseIdentifier;

  if ([cellIdentifier isEqual:kBirthdatePickerCellIdentifier] && self.birthdatePicker.hidden) {
    return 0;
  } else if ([cellIdentifier isEqual:kGenderPickerCellIdentifier] && self.genderPicker.hidden) {
    return 0;
  } else if ([cellIdentifier isEqual:kChildDirectedPickerCellIdentifier] &&
             self.childDirectedPicker.hidden) {
    return 0;
  }
  return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
  UIView *currentPickerView = nil;
  NSString *cellIdentifier = cell.reuseIdentifier;

  if ([cellIdentifier isEqual:kBirthdateCellIdentifier]) {
    currentPickerView = self.birthdatePicker;
  } else if ([cellIdentifier isEqual:kGenderCellIdentifier]) {
    currentPickerView = self.genderPicker;
  } else if ([cellIdentifier isEqual:kChildDirectedCellIdentifier]) {
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

// Returns the number of columns to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
  return 1;
}

// Returns the number of rows in each component.
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
  NSInteger numberOfRows = 0;
  if (pickerView == self.genderPicker) {
    numberOfRows = self.genderOptions.count;
  } else if (pickerView == self.childDirectedPicker) {
    numberOfRows = self.childDirectedOptions.count;
  }
  return numberOfRows;
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component {
  NSString *titleForRow = @"";
  if (pickerView == self.genderPicker) {
    titleForRow = self.genderOptions[row];
  } else if (pickerView == self.childDirectedPicker) {
    titleForRow = self.childDirectedOptions[row];
  }
  return titleForRow;
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {
  if (pickerView == self.genderPicker) {
    self.genderLabel.text = self.genderOptions[row];
  } else {
    self.childDirectedLabel.text = self.childDirectedOptions[row];
  }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
  self.currentLocation = locations.lastObject;
  self.locationLabel.text =
      [NSString stringWithFormat:@"%.3f, %.3f", self.currentLocation.coordinate.latitude,
                                 self.currentLocation.coordinate.longitude];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
  NSLog(@"%s: %@", __PRETTY_FUNCTION__, error.localizedDescription);
}

#pragma mark - Actions

- (IBAction)loadTargetedAd:(id)sender {
  self.bannerView.adUnitID = kAdMobAdUnitID;
  self.bannerView.rootViewController = self;

  GADRequest *request = [GADRequest request];

  if (self.currentLocation) {
    [request setLocationWithLatitude:self.currentLocation.coordinate.latitude
                           longitude:self.currentLocation.coordinate.longitude
                            accuracy:kCLLocationAccuracyBest];
  }
  if (![self.birthdateLabel.text isEqual:@"Birthdate"]) {
    request.birthday = self.birthdatePicker.date;
  }
  if ([self.genderLabel.text isEqual:@"Male"]) {
    request.gender = kGADGenderMale;
  } else if ([self.genderLabel.text isEqual:@"Female"]) {
    request.gender = kGADGenderFemale;
  } else if ([self.genderLabel.text isEqual:@"Unknown"]) {
    request.gender = kGADGenderUnknown;
  }
  if ([self.childDirectedLabel.text isEqual:@"Yes"] ||
      [self.childDirectedLabel.text isEqual:@"No"]) {
    [request tagForChildDirectedTreatment:self.childDirectedLabel.text.boolValue];
  }

  [self.bannerView loadRequest:request];
}

- (IBAction)chooseBirthdate:(id)sender {
  self.birthdateLabel.text = [self.dateFormatter stringFromDate:self.birthdatePicker.date];
}

- (void)hideAllPickers {
  self.birthdatePicker.hidden = YES;
  self.genderPicker.hidden = YES;
  self.childDirectedPicker.hidden = YES;
}

@end
