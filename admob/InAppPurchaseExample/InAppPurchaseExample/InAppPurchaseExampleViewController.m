// Copyright (c) 2014 Google. All rights reserved.

#import "InAppPurchaseExampleViewController.h"

#import "GADInAppPurchase.h"
#import "GADInterstitial.h"
#import "GADInterstitialDelegate.h"
#import "InAppPurchaseExampleAppDelegate.h"

@implementation InAppPurchaseExampleViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.showInterstitialButton.enabled = NO;
}

- (void)dealloc {
  // Make sure to nil out all delegates set on the interstitial.
  _interstitial.delegate = nil;
  _interstitial.inAppPurchaseDelegate = nil;
}

#pragma mark GADInterstitialDelegate implementation

- (void)interstitialDidReceiveAd:(GADInterstitial *)interstitial {
  [self.loadingSpinner stopAnimating];
  self.showInterstitialButton.enabled = YES;
}

- (void)interstitial:(GADInterstitial *)interstitial
    didFailToReceiveAdWithError:(GADRequestError *)error {
  [self.loadingSpinner stopAnimating];
  // Alert the error.
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"GADRequestError"
                                                  message:[error localizedDescription]
                                                 delegate:nil
                                        cancelButtonTitle:@"Drat"
                                        otherButtonTitles:nil];
  [alert show];

  self.showInterstitialButton.enabled = NO;
}

#pragma mark Insterstitial button actions

- (IBAction)loadInterstitial:(id)sender {
  self.interstitial = [[GADInterstitial alloc] init];
  self.interstitial.delegate = self;
  // Listen for an event to trigger an in-app purchase.
  self.interstitial.inAppPurchaseDelegate =
      (id<GADInAppPurchaseDelegate>)[[UIApplication sharedApplication] delegate];

  self.interstitial.adUnitID = kSampleInAppPurchaseAdUnitID;
  [self.interstitial loadRequest:[GADRequest request]];
  [self.loadingSpinner startAnimating];

  self.showInterstitialButton.enabled = NO;
}

- (IBAction)showInterstitial:(id)sender {
  self.showInterstitialButton.enabled = NO;

  // Show the interstitial.
  [self.interstitial presentFromRootViewController:self];
}

@end
