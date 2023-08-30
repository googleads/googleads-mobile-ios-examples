//
//  Copyright 2021 Google LLC
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary<NSString *, __kindof NSObject *> *)launchOptions {
  return YES;
}

- (void) applicationDidBecomeActive:(UIApplication *)application {
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.isKeyWindow == YES"];
  UIWindow *keyWindow = [[application.windows filteredArrayUsingPredicate:predicate] firstObject];
  UIViewController *rootViewController = keyWindow.rootViewController;
  // Do not show app open ad if the current view controller is SplashViewController.
  if (!rootViewController ||
      [rootViewController isKindOfClass:[SplashViewController class]]) {
    return;
  }
  [AppOpenAdManager.sharedInstance showAdIfAvailable:rootViewController];
}

@end
