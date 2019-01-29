//
//  Copyright (C) 2014 Google, Inc.
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

#import <GoogleMobileAds/GoogleMobileAds.h>

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  // Replace this ad unit ID with your own ad unit ID.
  self.bannerView.adUnitID = @"ca-app-pub-3940256099942544/2934735716";
  self.bannerView.rootViewController = self;
  GADRequest *request = [GADRequest request];
  // Requests test ads on devices you specify. Your test device ID is printed to the console when
  // an ad request is made. GADBannerView automatically returns test ads when running on a
  // simulator.
  request.testDevices = @[ kGADSimulatorID ];
  [self.bannerView loadRequest:request];
}

@end
