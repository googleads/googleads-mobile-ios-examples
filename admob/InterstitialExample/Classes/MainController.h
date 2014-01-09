//
//  MainController.h
//  InterstitialExample
//
//  Copyright 2011 Google Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADInterstitialDelegate.h"

@class GADInterstitial;
@class GADRequest;

@interface MainController : UIViewController<GADInterstitialDelegate>

@property(nonatomic, strong) GADInterstitial *interstitial;
@property(nonatomic, weak) IBOutlet UIActivityIndicatorView *loadingSpinner;
@property(nonatomic, weak) IBOutlet UIButton *loadInterstitialButton;
@property(nonatomic, weak) IBOutlet UIButton *showInterstitialButton;

- (GADRequest *)request;
- (IBAction)loadInterstitial:(id)sender;
- (IBAction)showInterstitial:(id)sender;

@end
