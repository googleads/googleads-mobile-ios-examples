//
//  Copyright (C) 2015 Google, Inc.
//
//  DFPAppEventsViewController.m
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

#import "DFPAppEventsViewController.h"

#import "Constants.h"

/// DFP - App Events
/// Demonstrates handling GADAppEventDelegate app event messages sent by the DFP banner.
@interface DFPAppEventsViewController () <GADAppEventDelegate>

/// The DFP banner view.
@property(nonatomic, weak) IBOutlet DFPBannerView *bannerView;

@end

@implementation DFPAppEventsViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.bannerView.adUnitID = kDFPAppEventsAdUnitID;
  self.bannerView.rootViewController = self;
  self.bannerView.appEventDelegate = self;

  DFPRequest *request = [DFPRequest request];
  [self.bannerView loadRequest:request];
}

#pragma mark - GADAppEventDelegate

/// Called when the banner receives an app event.
- (void)adView:(GADBannerView *)banner
    didReceiveAppEvent:(NSString *)name
              withInfo:(NSString *)info {
  // The DFP banner sends app event messages to its app event delegate, this view controller. The
  // GADAppEventDelegate will be notified when the SDK receives an app event message from the
  // banner. In this demo, the GADAppEventDelegate method sets the background of this view
  // controller to match the data that comes in. The banner will send "red" when it loads, "blue"
  // five seconds later, and "green" if the user taps the banner.
  //
  // This is just a demonstration, of course. Your apps can do much more interesting things with app
  // events.

  if ([name isEqual:@"color"]) {
    if ([info isEqual:@"blue"]) {
      self.view.backgroundColor = [UIColor blueColor];
    } else if ([info isEqual:@"red"]) {
      self.view.backgroundColor = [UIColor redColor];
    } else if ([info isEqual:@"green"]) {
      self.view.backgroundColor = [UIColor greenColor];
    }
  }
}

@end
