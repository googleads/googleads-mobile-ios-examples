//
//  Copyright (C) 2015 Google, Inc.
//
//  GAMCategoryExclusionsViewController.m
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

#import "GAMCategoryExclusionsViewController.h"

#import "Constants.h"

/// The constants for category exclusions.
static NSString *const kCategoryExclusionDogs = @"apidemo_exclude_dogs";
static NSString *const kCategoryExclusionCats = @"apidemo_exclude_cats";

/// GAM - Category Exclusions
/// Demonstrates using category exclusions with GAMRequests to exclude specified categories in ad
/// results.
@interface GAMCategoryExclusionsViewController ()

/// The no exclusions banner view.
@property(nonatomic, weak) IBOutlet GAMBannerView *noExclusionsBannerView;

/// The exclude dogs banner view.
@property(nonatomic, weak) IBOutlet GAMBannerView *excludeDogsBannerView;

/// The exclude cats banner view.
@property(nonatomic, weak) IBOutlet GAMBannerView *excludeCatsBannerView;

@end

@implementation GAMCategoryExclusionsViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.noExclusionsBannerView.adUnitID = kAdManagerCategoryExclusionsAdUnitID;
  self.noExclusionsBannerView.rootViewController = self;

  GAMRequest *noExclusionsRequest = [GAMRequest request];
  [self.noExclusionsBannerView loadRequest:noExclusionsRequest];

  self.excludeDogsBannerView.adUnitID = kAdManagerCategoryExclusionsAdUnitID;
  self.excludeDogsBannerView.rootViewController = self;

  GAMRequest *excludeDogsRequest = [GAMRequest request];
  excludeDogsRequest.categoryExclusions = @[ kCategoryExclusionDogs ];
  [self.excludeDogsBannerView loadRequest:excludeDogsRequest];

  self.excludeCatsBannerView.adUnitID = kAdManagerCategoryExclusionsAdUnitID;
  self.excludeCatsBannerView.rootViewController = self;

  GAMRequest *excludeCatsRequest = [GAMRequest request];
  excludeCatsRequest.categoryExclusions = @[ kCategoryExclusionCats ];
  [self.excludeCatsBannerView loadRequest:excludeCatsRequest];
}

@end
