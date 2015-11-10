//
//  Copyright (C) 2015 Google, Inc.
//
//  MasterViewController.m
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

#import "MasterViewController.h"

#import "AdMobAdDelegateViewController.h"
#import "AdMobAdTargetingTableViewController.h"
#import "AdMobBannerSizesViewController.h"
#import "DFPAppEventsViewController.h"
#import "DFPCategoryExclusionsViewController.h"
#import "DFPCustomTargetingViewController.h"
#import "DFPFluidAdSizeViewController.h"
#import "DFPMultipleAdSizesViewController.h"
#import "DFPPPIDViewController.h"

@interface MasterViewController ()

/// API demo names.
@property(nonatomic, copy) NSArray *APIDemoNames;

/// Segue identifiers.
@property(nonatomic, copy) NSArray *identifiers;

@end

@implementation MasterViewController

- (void)awakeFromNib {
  [super awakeFromNib];
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.APIDemoNames = @[
    @"AdMob - Ad Delegate",
    @"AdMob - Ad Targeting",
    @"AdMob - Banner Sizes",
    @"DFP - PPID",
    @"DFP - Custom Targeting",
    @"DFP - Category Exclusions",
    @"DFP - Multiple Ad Sizes",
    @"DFP - App Events",
    @"DFP - Fluid Ad Size"
  ];

  self.identifiers = @[
    @"adDelegateSegue",
    @"adTargetingSegue",
    @"bannerSizesSegue",
    @"PPIDSegue",
    @"customTargetingSegue",
    @"categoryExclusionsSegue",
    @"multipleAdSizesSegue",
    @"appEventsSegue",
    @"fluidAdSizeSegue"
  ];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow]
                                animated:animated];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.APIDemoNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell =
      [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

  cell.textLabel.text = self.APIDemoNames[indexPath.row];

  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  NSInteger row = indexPath.row;
  if (row < self.identifiers.count) {
    [self performSegueWithIdentifier:self.identifiers[row] sender:self];
  }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  return NO;
}

@end
