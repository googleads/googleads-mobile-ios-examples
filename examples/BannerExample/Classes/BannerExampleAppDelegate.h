//
//  BannerExampleAppDelegate.h
//  BannerExample
//
//  Copyright 2011 Google Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BannerExampleViewController;

@interface BannerExampleAppDelegate : NSObject <UIApplicationDelegate> {
  UIWindow *window_;
  BannerExampleViewController *viewController_;
}

@property(nonatomic, retain) IBOutlet UIWindow *window;
@property(nonatomic, retain) IBOutlet BannerExampleViewController
  *viewController;

@end
