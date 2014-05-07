// Copyright (c) 2014 Google. All rights reserved.

#import <UIKit/UIKit.h>

#import "GADInAppPurchaseDelegate.h"

@class GADInAppPurchase;

@interface InAppPurchaseExampleAppDelegate
    : UIResponder<UIApplicationDelegate, GADInAppPurchaseDelegate>

@property(nonatomic, strong) UIWindow *window;
@property(nonatomic, strong) GADInAppPurchase *purchase;

@end
