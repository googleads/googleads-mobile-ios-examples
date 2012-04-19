//
//  BannerExampleViewController.h
//  BannerExample
//
//  Copyright 2011 Google Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADBannerViewDelegate.h"

@class GADBannerView, GADRequest;

@interface BannerExampleViewController : UIViewController
    <GADBannerViewDelegate> {
  GADBannerView *adBanner_;
}

@property (nonatomic, retain) GADBannerView *adBanner;

- (GADRequest *)createRequest;

@end
