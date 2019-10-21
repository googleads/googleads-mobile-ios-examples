//
//  Copyright (C) 2019 Google, Inc.
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

#import "AppDelegate.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // Requests test ads on devices you specify. Your test device ID is printed to the console when
  // an ad request is made. GADBannerView automatically returns test ads when running on a
  // simulator.
  GADMobileAds.sharedInstance.requestConfiguration.testDeviceIdentifiers = @[ kGADSimulatorID ];

  // Initialize Google Mobile Ads SDK
  [[GADMobileAds sharedInstance] startWithCompletionHandler:nil];
  return YES;
}

@end
