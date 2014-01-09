// DFPInterstitialExampleAppDelegate.m
// Copyright 2012 Google Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "DFPInterstitialExampleAppDelegate.h"
#import "DFPInterstitialExampleViewController.h"
#import "SampleContants.h"

@implementation DFPInterstitialExampleAppDelegate

@synthesize window = window_;
@synthesize viewController = viewController_;

- (void)dealloc {
  [window_ release];
  [viewController_ release];
  [splashInterstitial_ release];
  [super dealloc];
}

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]]
                 autorelease];
  // Override point for customization after application launch.
  self.viewController = [[[DFPInterstitialExampleViewController alloc]
      initWithNibName:@"DFPInterstitialExampleViewController"
               bundle:nil] autorelease];
  self.window.rootViewController = self.viewController;
  [self.window makeKeyAndVisible];

  splashInterstitial_ = [[DFPInterstitial alloc] init];

  splashInterstitial_.adUnitID = kSampleAdUnitID;

  // Show a splash screen interstitial. Show the InitialImage.png image
  // while the interstitial is loading.
  [splashInterstitial_ loadAndDisplayRequest:[GADRequest request]
      usingWindow:self.window
      initialImage:[UIImage imageNamed:@"InitialImage"]];

  return YES;
}

@end
