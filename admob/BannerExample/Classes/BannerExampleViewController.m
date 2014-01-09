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

#pragma mark init/dealloc

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
  [super viewDidLoad];

  // Initialize the banner at the bottom of the screen.
  CGPoint origin = CGPointMake(0.0,
                               self.view.frame.size.height -
                               CGSizeFromGADAdSize(kGADAdSizeBanner).height);

  // Use predefined GADAdSize constants to define the GADBannerView.
  self.adBanner = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner origin:origin];

  // Note: Edit SampleConstants.h to provide a definition for kSampleAdUnitID before compiling.
  self.adBanner.adUnitID = kSampleAdUnitID;
  self.adBanner.delegate = self;
  self.adBanner.rootViewController = self;
  [self.view addSubview:self.adBanner];
  [self.adBanner loadRequest:[self request]];
}

- (void)dealloc {
  _adBanner.delegate = nil;
}

- (NSUInteger)supportedInterfaceOrientations {
  return UIInterfaceOrientationMaskPortrait;
}

#pragma mark GADRequest generation

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

#pragma mark GADBannerViewDelegate implementation

// We've received an ad successfully.
- (void)adViewDidReceiveAd:(GADBannerView *)adView {
  NSLog(@"Received ad successfully");
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
  NSLog(@"Failed to receive ad with error: %@", [error localizedFailureReason]);
}

@end
