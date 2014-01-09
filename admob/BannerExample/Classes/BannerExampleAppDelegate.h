//
//  BannerExampleAppDelegate.h
//  BannerExample
//
//  Copyright 2011 Google Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BannerExampleViewController;

@interface BannerExampleAppDelegate : NSObject<UIApplicationDelegate>

@property(nonatomic, weak) IBOutlet UIWindow *window;
@property(nonatomic, weak) IBOutlet BannerExampleViewController *viewController;

@end
