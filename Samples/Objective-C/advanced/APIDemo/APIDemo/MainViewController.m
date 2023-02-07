//
//  Copyright (C) 2015 Google, Inc.
//
//  MainViewController.m
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

#import "MainViewController.h"

#import "AdMobAdDelegateViewController.h"
#import "AdMobAdTargetingTableViewController.h"
#import "AdMobBannerSizesViewController.h"
#import "GAMAppEventsViewController.h"
#import "GAMCategoryExclusionsViewController.h"
#import "GAMCustomTargetingViewController.h"
#import "GAMFluidAdSizeViewController.h"
#import "GAMMultipleAdSizesViewController.h"
#import "GAMPPIDViewController.h"

@interface MainViewController ()

/// API demo names.
@property(nonatomic, copy) NSArray *APIDemoNames;

/// Segue identifiers.
@property(nonatomic, copy) NSArray *identifiers;

@end

@implementation MainViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.APIDemoNames = @[
    @"Google AdMob - Ad Delegate", @"Google AdMob - Ad Targeting", @"Google AdMob - Banner Sizes",
    @"Google AdMob - Native Custom Mute This Ad", @"Google Ad Manager - PPID",
    @"Google Ad Manager - Custom Targeting", @"Google Ad Manager - Category Exclusions",
    @"Google Ad Manager - Multiple Ad Sizes", @"Google Ad Manager - App Events",
    @"Google Ad Manager - Fluid Ad Size", @"Google Ad Manager - Custom Video Controls"
  ];

  self.identifiers = @[
    @"adDelegateSegue", @"adTargetingSegue", @"bannerSizesSegue", @"customMuteSegue", @"PPIDSegue",
    @"customTargetingSegue", @"categoryExclusionsSegue", @"multipleAdSizesSegue", @"appEventsSegue",
    @"fluidAdSizeSegue", @"customControlsSegue"
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
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"
                                                          forIndexPath:indexPath];

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
