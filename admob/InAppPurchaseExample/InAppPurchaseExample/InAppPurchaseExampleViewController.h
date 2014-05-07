// Copyright (c) 2014 Google. All rights reserved.

#import <UIKit/UIKit.h>

#import "GADInterstitialDelegate.h"

#error You must insert your own ad unit ID.
#define kSampleInAppPurchaseAdUnitID @"INSERT_YOUR_AD_UNIT_ID_HERE";

@class GADInterstitial, GADRequest;

@interface InAppPurchaseExampleViewController : UIViewController<GADInterstitialDelegate>

@property(nonatomic, strong) GADInterstitial *interstitial;
@property(nonatomic, weak) IBOutlet UIActivityIndicatorView *loadingSpinner;
@property(nonatomic, weak) IBOutlet UIButton *loadInterstitialButton;
@property(nonatomic, weak) IBOutlet UIButton *showInterstitialButton;

- (IBAction)loadInterstitial:(id)sender;
- (IBAction)showInterstitial:(id)sender;

@end
