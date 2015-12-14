//
//  Copyright (C) 2015 Google, Inc.
//
//  DFPCategoryExclusionsViewController.m
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

#import "DFPCategoryExclusionsViewController.h"

#import "Constants.h"

/// The constants for category exclusions.
static NSString *const kCategoryExclusionDogs = @"apidemo_exclude_dogs";
static NSString *const kCategoryExclusionCats = @"apidemo_exclude_cats";

/// DFP - Category Exclusions
/// Demonstrates using category exclusions with DFPRequests to exclude specified categories in ad
/// results.
@interface DFPCategoryExclusionsViewController ()

/// The no exclusions banner view.
@property(nonatomic, weak) IBOutlet DFPBannerView *noExclusionsBannerView;

/// The exclude dogs banner view.
@property(nonatomic, weak) IBOutlet DFPBannerView *excludeDogsBannerView;

/// The exclude cats banner view.
@property(nonatomic, weak) IBOutlet DFPBannerView *excludeCatsBannerView;

@end

@implementation DFPCategoryExclusionsViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.noExclusionsBannerView.adUnitID = kDFPCategoryExclusionsAdUnitID;
  self.noExclusionsBannerView.rootViewController = self;

  DFPRequest *noExclusionsRequest = [DFPRequest request];
  [self.noExclusionsBannerView loadRequest:noExclusionsRequest];

  self.excludeDogsBannerView.adUnitID = kDFPCategoryExclusionsAdUnitID;
  self.excludeDogsBannerView.rootViewController = self;

  DFPRequest *excludeDogsRequest = [DFPRequest request];
  excludeDogsRequest.categoryExclusions = @[ kCategoryExclusionDogs ];
  [self.excludeDogsBannerView loadRequest:excludeDogsRequest];

  self.excludeCatsBannerView.adUnitID = kDFPCategoryExclusionsAdUnitID;
  self.excludeCatsBannerView.rootViewController = self;

  DFPRequest *excludeCatsRequest = [DFPRequest request];
  excludeCatsRequest.categoryExclusions = @[ kCategoryExclusionCats ];
  [self.excludeCatsBannerView loadRequest:excludeCatsRequest];
}

@end
