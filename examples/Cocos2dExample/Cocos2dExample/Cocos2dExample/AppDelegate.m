// AppDelegate.m
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

#import <AdSupport/ASIdentifierManager.h>

#import "cocos2d.h"

#import "AppDelegate.h"
#import "GameConfig.h"
#import "HelloWorldLayer.h"
#import "RootViewController.h"

@implementation AppDelegate

@synthesize window = window_;

- (void)applicationDidFinishLaunching:(UIApplication*)application {
  // Print IDFA (from AdSupport Framework) for iOS 6 and UDID for iOS < 6.
  if (NSClassFromString(@"ASIdentifierManager")) {
    NSLog(@"GoogleAdMobAdsSDK ID for testing: %@" ,
              [[[ASIdentifierManager sharedManager]
                  advertisingIdentifier] UUIDString]);
  } else {
    NSLog(@"GoogleAdMobAdsSDK ID for testing: %@" ,
              [[UIDevice currentDevice] uniqueIdentifier]);
  }

  // Init the window.
  window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  // Try to use CADisplayLink director.
  // If it fails (SDK < 3.1) use the default director.
  if(![CCDirector setDirectorType:kCCDirectorTypeDisplayLink]) {
    [CCDirector setDirectorType:kCCDirectorTypeDefault];
  }

  CCDirector *director = [CCDirector sharedDirector];

  // Init the View Controller.
  viewController_ = [[RootViewController alloc] initWithNibName:nil bundle:nil];
  viewController_.wantsFullScreenLayout = YES;

  // Create the EAGLView manually.
  // 1. Create a RGB565 format. Alternative: RGBA8.
  // 2. Depth format of 0 bit. Use 16 or 24 bit for 3d effects, like
  //    CCPageTurnTransition.
  EAGLView *glView =
      [EAGLView viewWithFrame:[window_ bounds]
                  pixelFormat:kEAGLColorFormatRGB565 // kEAGLColorFormatRGBA8
                    depthFormat:0 // GL_DEPTH_COMPONENT16_OES
       ];

  // Attach the openglView to the director.
  [director setOpenGLView:glView];

  // If the rotation is going to be controlled by a UIViewController
  // then the device orientation should be "Portrait".
#if GAME_AUTOROTATION == kGameAutorotationUIViewController
  [director setDeviceOrientation:kCCDeviceOrientationPortrait];
#else
  [director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
#endif

  [director setAnimationInterval:1.0/60];
  [director setDisplayFPS:YES];

#if GAME_AUTOROTATION == kGameAutorotationUIViewController
  // Makes the OpenGLView a child of the view controller and puts an ad banner
  // into the view hierarchy.
  [viewController_.view addSubview:glView];
  [viewController_ initGADBannerWithAdPositionAtTop:false];
#else
  [viewController_ setView:glView];
#endif

  // Make the View Controller a child of the main window.
  [window_ addSubview: viewController_.view];
  [window_ makeKeyAndVisible];

  // Default texture format for PNG/BMP/TIFF/JPEG/GIF images.
  // It can be RGBA8888, RGBA4444, RGB5_A1, RGB565. You can change anytime.
  [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

  // Run the intro scene.
  [[CCDirector sharedDirector] runWithScene:[HelloWorldLayer scene]];
}

- (void)applicationWillResignActive:(UIApplication *)application {
  [[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  [[CCDirector sharedDirector] resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
  [[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationDidEnterBackground:(UIApplication*)application {
  [[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
  [[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
  CCDirector *director = [CCDirector sharedDirector];
  [[director openGLView] removeFromSuperview];
  [director end];
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
  [[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)dealloc {
  [[CCDirector sharedDirector] end];
  [viewController_ release];
  [window_ release];
  [super dealloc];
}

@end
