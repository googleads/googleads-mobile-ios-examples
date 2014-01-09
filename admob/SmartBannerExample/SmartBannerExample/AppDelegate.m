//
//  AppDelegate.m
//  SmartBannerExample
//
//  Copyright 2012 Google Inc. All rights reserved.
//

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
