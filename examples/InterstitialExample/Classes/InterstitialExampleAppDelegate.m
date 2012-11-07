//
//  InterstitialExampleAppDelegate.m
//  InterstitialExample
//
//  Copyright 2011 Google Inc. All rights reserved.
//

#import <AdSupport/ASIdentifierManager.h>

#import "InterstitialExampleAppDelegate.h"

#define INTERSTITIAL_AD_UNIT_ID @"MY_INTERSTITIAL_AD_UNIT_ID"

@implementation InterstitialExampleAppDelegate

@synthesize mainController = mainController_;
@synthesize window = window_;

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

  // Print IDFA (from AdSupport Framework) for iOS 6 and UDID for iOS < 6.
  if (NSClassFromString(@"ASIdentifierManager")) {
    NSLog(@"GoogleAdMobAdsSDK ID for testing: %@" ,
              [[[ASIdentifierManager sharedManager]
                  advertisingIdentifier] UUIDString]);
  } else {
    NSLog(@"GoogleAdMobAdsSDK ID for testing: %@" ,
              [[UIDevice currentDevice] uniqueIdentifier]);
  }

  [self.window setRootViewController:mainController_];
  [self.window makeKeyAndVisible];

  splashInterstitial_ = [[GADInterstitial alloc] init];

  splashInterstitial_.adUnitID = self.interstitialAdUnitID;
  splashInterstitial_.delegate = self;

  [splashInterstitial_ loadAndDisplayRequest:[self createRequest]
                       usingWindow:self.window
                       initialImage:[UIImage imageNamed:@"InitialImage"]];
  return YES;
}

- (void)dealloc {
  splashInterstitial_.delegate = nil;

  [splashInterstitial_ release];
  [window_ release];
  [mainController_ release];

  [super dealloc];
}

// Returns the interstitial ad unit ID. In a real-world app each intersitial
// placement would have a distinct unit ID.
- (NSString *)interstitialAdUnitID {
  return INTERSTITIAL_AD_UNIT_ID;
}

#pragma mark GADRequest generation

// Here we're creating a simple GADRequest and whitelisting the application
// for test ads. You should request test ads during development to avoid
// generating invalid impressions and clicks.
- (GADRequest *)createRequest {
  GADRequest *request = [GADRequest request];

  // Make the request for a test ad. Put in an identifier for the simulator as
  // well as any devices you want to receive test ads.
  request.testDevices =
      [NSArray arrayWithObjects:
          // TODO: Add your device/simulator test identifiers here. They are
          // printed to the console when the app is launched.
          nil];
  return request;
}

@end
