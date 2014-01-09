//
//  InterstitialExampleAppDelegate.m
//  InterstitialExample
//
//  Copyright 2011 Google Inc. All rights reserved.
//

#import "InterstitialExampleAppDelegate.h"
#import "MainController.h"

@implementation InterstitialExampleAppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [self.window setRootViewController:self.mainController];
  [self.window makeKeyAndVisible];

  return YES;
}

@end
