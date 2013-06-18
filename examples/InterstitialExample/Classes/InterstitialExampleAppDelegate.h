//
//  InterstitialExampleAppDelegate.h
//  InterstitialExample
//
//  Copyright 2011 Google Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADInterstitial.h"
#import "MainController.h"

// The delegate simply (0) manages presentation of the splash interstitial (if
// any), (1) loads the MainController and (2) provides the rest of the app with
// an ad unit ID and appropriately configured GADRequest. The former will be
// nil if shouldFail is YES.
@interface InterstitialExampleAppDelegate : NSObject
    <UIApplicationDelegate, GADInterstitialDelegate> {
  UIWindow *window_;
  MainController *mainController_;
  GADInterstitial *splashInterstitial_;
}

@property(nonatomic, retain) IBOutlet UIWindow *window;
@property(nonatomic, retain) IBOutlet MainController *mainController;

@property(nonatomic, readonly) NSString *interstitialAdUnitID;

- (GADRequest *)createRequest;

@end
