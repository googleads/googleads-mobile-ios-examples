//
//  AppDelegate.m
//  SmartBannerExample
//
//  Copyright 2012 Google Inc. All rights reserved.
//

#import <AdSupport/ASIdentifierManager.h>

#import "AppDelegate.h"
#import "ViewController.h"

@implementation AppDelegate

@synthesize window = window_;
@synthesize viewController = viewController_;

- (void)dealloc {
  [window_ release];
  [viewController_ release];
  [super dealloc];
}

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

  self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]]
                 autorelease];

  // Override point for customization after application launch.
  self.viewController = [[[ViewController alloc]
                          initWithNibName:@"ViewController"
                                   bundle:nil] autorelease];
  self.window.rootViewController = self.viewController;
  [self.window makeKeyAndVisible];
  return YES;
}

@end
