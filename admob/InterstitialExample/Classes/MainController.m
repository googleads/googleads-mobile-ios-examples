//
//  MainController.m
//  InterstitialExample
//
//  Copyright 2011 Google Inc. All rights reserved.
//

#import "MainController.h"
#import "GADInterstitial.h"
#import "GADInterstitialDelegate.h"
#import "InterstitialExampleAppDelegate.h"
#import "SampleConstants.h"

@implementation MainController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.showInterstitialButton.enabled = NO;
  [self.showInterstitialButton setTitle:@"Interstitial Not Ready" forState:UIControlStateDisabled];
  [self.showInterstitialButton setTitle:@"Show Interstitial" forState:UIControlStateNormal];
}

- (void)dealloc {
  _interstitial.delegate = nil;
}

- (void)viewWillLayoutSubviews {
  [super viewWillLayoutSubviews];
  self.loadingSpinner.center = CGPointMake(CGRectGetWidth(self.view.bounds) / 2,
                                           self.loadingSpinner.center.y);
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

#pragma mark GADRequest implementation

- (GADRequest *)request {
  GADRequest *request = [GADRequest request];

  // Make the request for a test ad. Put in an identifier for the simulator as well as any devices
  // you want to receive test ads.
  request.testDevices = @[
    // TODO: Add your device/simulator test identifiers here. Your device identifier is printed to
    // the console when the app is launched.
    GAD_SIMULATOR_ID
  ];
  return request;
}

#pragma mark Insterstitial button actions

- (IBAction)loadInterstitial:(id)sender {
  // Create a new GADInterstitial each time.  A GADInterstitial will only show one request in its
  // lifetime. The property will release the old one and set the new one.
  self.interstitial = [[GADInterstitial alloc] init];
  self.interstitial.delegate = self;

  // Note: Edit SampleConstants.h to update kSampleAdUnitId with your interstitial ad unit id.
  self.interstitial.adUnitID = kSampleAdUnitID;
  [self.interstitial loadRequest:[self request]];
  [self.loadingSpinner startAnimating];

  self.showInterstitialButton.enabled = NO;
}

- (IBAction)showInterstitial:(id)sender {
  self.showInterstitialButton.enabled = NO;

  // Show the interstitial.
  [self.interstitial presentFromRootViewController:self];
}

@end
