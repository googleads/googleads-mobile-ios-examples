//
//  BannerExampleAppDelegate.m
//  BannerExample
//
//  Copyright 2011 Google Inc. All rights reserved.
//

#import "BannerExampleAppDelegate.h"
#import "BannerExampleViewController.h"

@implementation BannerExampleAppDelegate

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // Add the view controller's view to the window and display.
  [self.window setRootViewController:self.viewController];
  [self.window makeKeyAndVisible];

  return YES;
}

@end
