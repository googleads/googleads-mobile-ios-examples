//  Copyright (c) 2015 Google. All rights reserved.

#import "AppDelegate.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // Override point for customization after application launch.

  // Initialize Google Mobile Ads SDK
  [GADMobileAds.sharedInstance startWithCompletionHandler:nil];
  return YES;
}

@end
