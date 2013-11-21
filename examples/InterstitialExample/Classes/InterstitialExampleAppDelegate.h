//
//  InterstitialExampleAppDelegate.h
//  InterstitialExample
//
//  Copyright 2011 Google Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MainController;

@interface InterstitialExampleAppDelegate : NSObject<UIApplicationDelegate>

@property(nonatomic, weak) IBOutlet UIWindow *window;
@property(nonatomic, weak) IBOutlet MainController *mainController;

@end
