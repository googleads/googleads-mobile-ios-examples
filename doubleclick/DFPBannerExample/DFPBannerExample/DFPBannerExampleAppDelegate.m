// DFPBannerExampleAppDelegate.m
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

#import "DFPBannerExampleAppDelegate.h"
#import "DFPBannerExampleViewController.h"

@implementation DFPBannerExampleAppDelegate

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
  self.viewController = [[[DFPBannerExampleViewController alloc]
                          initWithNibName:@"DFPBannerExampleViewController"
                                   bundle:nil] autorelease];
  self.window.rootViewController = self.viewController;
  [self.window makeKeyAndVisible];
  return YES;
}

@end
