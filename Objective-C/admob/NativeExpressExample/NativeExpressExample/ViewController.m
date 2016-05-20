// Copyright (C) 2016 Google, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "ViewController.h"

@import GoogleMobileAds;

@interface ViewController ()

/// The native express ad view in which the ad is displayed.
@property(nonatomic, weak) IBOutlet GADNativeExpressAdView *nativeExpressAdView;

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  // This is a test ad unit, which serves test ads automatically.
  self.nativeExpressAdView.adUnitID = @"ca-app-pub-3940256099942544/2562852117";
  self.nativeExpressAdView.rootViewController = self;

  GADRequest *request = [GADRequest request];
  [self.nativeExpressAdView loadRequest:request];
}

@end
