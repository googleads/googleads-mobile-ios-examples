//
//  BannerExampleViewController.h
//  BannerExample
//
//  Copyright 2011 Google Inc. All rights reserved.
//

#import "GADBannerViewDelegate.h"

@class GADBannerView;
@class GADRequest;

@interface BannerExampleViewController : UIViewController<GADBannerViewDelegate>

@property(nonatomic, strong) GADBannerView *adBanner;

- (GADRequest *)request;

@end
