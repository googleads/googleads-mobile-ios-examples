//
//  BannerExampleViewController.m
//  BannerExample
//
//  Copyright 2011 Google Inc. All rights reserved.
//

#import "BannerExampleViewController.h"
#import "GADBannerView.h"
#import "GADRequest.h"
#import "SampleConstants.h"

@implementation BannerExampleViewController

@synthesize adBanner = adBanner_;

#pragma mark init/dealloc

// Implement viewDidLoad to do additional setup after loading the view,
// typically from a nib.
- (void)viewDidLoad {
  [super viewDidLoad];

  // Initialize the banner at the bottom of the screen.
  CGPoint origin = CGPointMake(0.0,
                               self.view.frame.size.height -
                               CGSizeFromGADAdSize(kGADAdSizeBanner).height);

  // Use predefined GADAdSize constants to define the GADBannerView.
  self.adBanner = [[[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner
                                                  origin:origin]
                    autorelease];

  // Note: Edit SampleConstants.h to provide a definition for kSampleAdUnitID
  // before compiling.
  self.adBanner.adUnitID = kSampleAdUnitID;
  self.adBanner.delegate = self;
  [self.adBanner setRootViewController:self];
  [self.view addSubview:self.adBanner];
  self.adBanner.center =
      CGPointMake(self.view.center.x, self.adBanner.center.y);
  [self.adBanner loadRequest:[self createRequest]];
}

- (void)dealloc {
  adBanner_.delegate = nil;
  [adBanner_ release];
  [super dealloc];
}

- (NSUInteger)supportedInterfaceOrientations {
  return UIInterfaceOrientationMaskPortrait;
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

#pragma mark GADBannerViewDelegate impl

// We've received an ad successfully.
- (void)adViewDidReceiveAd:(GADBannerView *)adView {
  NSLog(@"Received ad successfully");
}

- (void)adView:(GADBannerView *)view
    didFailToReceiveAdWithError:(GADRequestError *)error {
  NSLog(@"Failed to receive ad with error: %@", [error localizedFailureReason]);
}

@end
