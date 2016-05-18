// Copyright (c) 2014 Google. All rights reserved.

#import "AppDelegate.h"

@import Firebase;

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

  // Use Firebase library to configure APIs
  [FIRApp configure];

  return YES;
}

@end
