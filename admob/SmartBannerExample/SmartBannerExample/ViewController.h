//
//  ViewController.h
//  SmartBannerExample
//
//  Copyright 2012 Google Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADBannerViewDelegate.h"

@class GADBannerView, GADRequest;

@interface ViewController : UIViewController <GADBannerViewDelegate>

@property(strong, nonatomic) GADBannerView *adBanner;

- (GADRequest *)createRequest;

@end
