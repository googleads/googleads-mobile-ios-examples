// RootViewController.m
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

#import "cocos2d.h"
#import "RootViewController.h"
#import "GameConfig.h"
#import "GADBannerView.h"
#import "GADRequest.h"

@implementation RootViewController

- (void)initGADBannerWithAdPositionAtTop:(BOOL)isAdPositionAtTop {
  isAdPositionAtTop_ = isAdPositionAtTop;

  // NOTE:
  // Add your publisher ID here and fill in the GADAdSize constant for the ad
  // you would like to request.
  bannerView_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
  bannerView_.adUnitID = @"PUBLISHER_ID_HERE";
  bannerView_.delegate = self;
  [bannerView_ setRootViewController:self];

  [self.view addSubview:bannerView_];
  [bannerView_ loadRequest:[self createRequest]];
  // Use the status bar orientation since we haven't signed up for orientation
  // change notifications for this class.
  [self resizeViewsForOrientation:
      [[UIApplication sharedApplication] statusBarOrientation]];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:
    (UIInterfaceOrientation)interfaceOrientation {
  // There are 2 ways to support auto-rotation:
  // 1. The OpenGL / cocos2d way
  //    - Faster, but doesn't rotate the UIKit objects.
  // 2. The ViewController way
  //    - A bit slower, but the UIKit objects are placed in the right place.

#if GAME_AUTOROTATION==kGameAutorotationNone
  // EAGLView won't be autorotated. Since this method should return YES in at
  // least 1 orientation, we return YES only in the Portrait orientation.
  return (interfaceOrientation == UIInterfaceOrientationPortrait);

#elif GAME_AUTOROTATION==kGameAutorotationCCDirector
  // EAGLView will be rotated by cocos2d. This sample will autorotate only in
  // landscape mode.
  if( interfaceOrientation == UIInterfaceOrientationLandscapeLeft ) {
    [[CCDirector sharedDirector]
        setDeviceOrientation: kCCDeviceOrientationLandscapeRight];
  } else if( interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
    [[CCDirector sharedDirector]
        setDeviceOrientation: kCCDeviceOrientationLandscapeLeft];
  }
  // Since this method should return YES in at least 1 orientation,
  // we return YES only in the Portrait orientation.
  return ( interfaceOrientation == UIInterfaceOrientationPortrait );

#elif GAME_AUTOROTATION == kGameAutorotationUIViewController
  // EAGLView will be rotated by the UIViewController. This sample will
  // autorotate for all orientations.

  return YES;

#else
#error Unknown value in GAME_AUTOROTATION

#endif // GAME_AUTOROTATION
  // Sholud not happen, means we hit an error somewhere.
  return NO;
}

// This callback only will be called when
// GAME_AUTOROTATION == kGameAutorotationUIViewController.
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInt
                               duration:(NSTimeInterval)duration {
  // Assuming that the main window has the size of the screen.
  CGRect screenRect = [[UIScreen mainScreen] bounds];
  CGRect rect = CGRectZero;

  if(toInt == UIInterfaceOrientationPortrait ||
     toInt == UIInterfaceOrientationPortraitUpsideDown) {
    rect = screenRect;
  } else if(toInt == UIInterfaceOrientationLandscapeLeft ||
            toInt == UIInterfaceOrientationLandscapeRight) {
    rect.size = CGSizeMake(screenRect.size.height, screenRect.size.width);
  }

  CCDirector *director = [CCDirector sharedDirector];
  EAGLView *glView = [director openGLView];
  float contentScaleFactor = [director contentScaleFactor];
  if( contentScaleFactor != 1 ) {
    rect.size.width *= contentScaleFactor;
    rect.size.height *= contentScaleFactor;
  }
  glView.frame = rect;
  // Need to account for the ad on every orientation change.
  [self resizeViewsForOrientation:toInt];
}

- (void)dealloc {
  bannerView_.delegate = nil;
  [bannerView_ release];
  [super dealloc];
}

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

- (void)resizeViewsForOrientation:(UIInterfaceOrientation)toInt {
  // If the banner hasn't been created yet, no need for resizing views.
  if (!bannerView_) {
    return;
  }

  BOOL adIsShowing = [self.view.subviews containsObject:bannerView_];
  if (!adIsShowing) {
    return;
  }

  // Frame of the main RootViewController which we call the root view.
  CGRect rootViewFrame = self.view.frame;
  // Frame of the main RootViewController view that holds the Cocos2D view.
  CGRect glViewFrame = [[CCDirector sharedDirector] openGLView].frame;
  CGRect bannerViewFrame = bannerView_.frame;
  CGRect frame = bannerViewFrame;
  // The updated x and y coordinates for the origin of the banner.
  CGFloat yLocation = 0.0;
  CGFloat xLocation = 0.0;

  if (isAdPositionAtTop_) {
    // Move the root view underneath the ad banner.
    glViewFrame.origin.y = bannerViewFrame.size.height;
    // Center the banner using the value of the origin.
    if (UIInterfaceOrientationIsLandscape(toInt)) {
      // The superView has not had its width and height updated yet so use those
      // values for the x and y of the new origin respectively.
      xLocation = (rootViewFrame.size.height -
                      bannerViewFrame.size.width) / 2.0;
    } else {
      xLocation = (rootViewFrame.size.width -
                      bannerViewFrame.size.width) / 2.0;
    }
  } else {
    // Move the root view to the top of the screen.
    glViewFrame.origin.y = 0;
    // Need to center the banner both horizontally and vertically.
    if (UIInterfaceOrientationIsLandscape(toInt)) {
      yLocation = rootViewFrame.size.width -
                      bannerViewFrame.size.height;
      xLocation = (rootViewFrame.size.height -
                      bannerViewFrame.size.width) / 2.0;
    } else {
      yLocation = rootViewFrame.size.height -
                      bannerViewFrame.size.height;
      xLocation = (rootViewFrame.size.width -
                      bannerViewFrame.size.width) / 2.0;
    }
  }
  frame.origin = CGPointMake(xLocation, yLocation);
  bannerView_.frame = frame;

  if (UIInterfaceOrientationIsLandscape(toInt)) {
    // The super view's frame hasn't been updated so use its width
    // as the height.
    glViewFrame.size.height = rootViewFrame.size.width -
                                    bannerViewFrame.size.height;
    glViewFrame.size.width = rootViewFrame.size.height;
  } else {
    glViewFrame.size.height = rootViewFrame.size.height -
                                    bannerViewFrame.size.height;
  }
  [[CCDirector sharedDirector] openGLView].frame = glViewFrame;

}

#pragma mark GADBannerViewDelegate impl

- (void)adViewDidReceiveAd:(GADBannerView *)adView {
  NSLog(@"Received ad");
}

- (void)adView:(GADBannerView *)view
    didFailToReceiveAdWithError:(GADRequestError *)error {
  NSLog(@"Failed to receive ad with error: %@", [error localizedFailureReason]);
}

@end
