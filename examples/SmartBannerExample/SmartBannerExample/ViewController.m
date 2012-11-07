//
//  ViewController.m
//  SmartBannerExample
//
//  Copyright 2012 Google Inc. All rights reserved.
//

#import "ViewController.h"
#import "GADBannerView.h"
#import "GADRequest.h"
#import "SampleConstants.h"

@implementation ViewController

@synthesize adBanner = adBanner_;

#pragma mark init/dealloc

// Implement viewDidLoad to do additional setup after loading the view,
// typically from a nib.
- (void)viewDidLoad {
  [super viewDidLoad];

  self.adBanner = [[[GADBannerView alloc]
                    initWithAdSize:kGADAdSizeSmartBannerPortrait] autorelease];

  // Need to set this to no since we're creating this custom view.
  self.adBanner.translatesAutoresizingMaskIntoConstraints = NO;

  // Note: Edit SampleConstants.h to provide a definition for kSampleAdUnitID
  // before compiling.
  self.adBanner.adUnitID = kSampleAdUnitID;
  self.adBanner.delegate = self;
  [self.adBanner setRootViewController:self];
  [self.view addSubview:self.adBanner];
  [self.adBanner loadRequest:[self createRequest]];

  [self.view addConstraint:
     [NSLayoutConstraint constraintWithItem:self.adBanner
                                  attribute:NSLayoutAttributeBottom
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:self.view
                                  attribute:NSLayoutAttributeBottom
                                 multiplier:1.0
                                   constant:0]];
  [self.view addConstraint:
     [NSLayoutConstraint constraintWithItem:self.adBanner
                                  attribute:NSLayoutAttributeCenterX
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:self.view
                                  attribute:NSLayoutAttributeCenterX
                                 multiplier:1.0
                                   constant:0]];
}

- (void)dealloc {
  adBanner_.delegate = nil;
  [adBanner_ release];
  [super dealloc];
}

#pragma mark GADRequest generation

// Here we're creating a simple GADRequest and whitelisting the application
// for test ads. You should request test ads during development to avoid
// generating invalid impressions and clicks.
- (GADRequest *)createRequest {
  GADRequest *request = [GADRequest request];

  // Make the request for a test ad. Put in an identifier for the simulator as
  // well as any devices you want to receive test ads.
  request.testDevices =
      [NSArray arrayWithObjects:
          // TODO: Add your device/simulator test identifiers here. They are
          // printed to the console when the app is launched.
          nil];
  return request;
}

#pragma mark GADBannerViewDelegate callbacks

// We've received an ad successfully.
- (void)adViewDidReceiveAd:(GADBannerView *)adView {
  NSLog(@"Received ad successfully");
}

- (void)adView:(GADBannerView *)view
    didFailToReceiveAdWithError:(GADRequestError *)error {
  NSLog(@"Failed to receive ad with error: %@", [error localizedFailureReason]);
}

#pragma mark Smart Banner implementation

- (NSUInteger)supportedInterfaceOrientations {
  return UIInterfaceOrientationMaskAll;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInt
                               duration:(NSTimeInterval)duration {
  if (UIInterfaceOrientationIsLandscape(toInt)) {
    self.adBanner.adSize = kGADAdSizeSmartBannerLandscape;
  } else {
    self.adBanner.adSize = kGADAdSizeSmartBannerPortrait;
  }
}
@end
