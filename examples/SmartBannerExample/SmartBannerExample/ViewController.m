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

  // Initialize the banner docked to the bottom of the screen.
  CGPoint origin = CGPointMake(0.0,
                               self.view.frame.size.height -
                               CGSizeFromGADAdSize(
                                   kGADAdSizeSmartBannerPortrait).height);

  self.adBanner = [[[GADBannerView alloc]
                    initWithAdSize:kGADAdSizeSmartBannerPortrait
                            origin:origin] autorelease];


  // Note: Edit SampleConstants.h to provide a definition for kSampleAdUnitID
  // before compiling.
  self.adBanner.adUnitID = kSampleAdUnitID;
  self.adBanner.delegate = self;
  [self.adBanner setRootViewController:self];
  [self.view addSubview:self.adBanner];
  [self.adBanner loadRequest:[self createRequest]];
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

  // Make the request for a test ad. Remember to turn this flag off when you
  // want to receive real ads.
  request.testing = YES;

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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orient {
  // Return YES for supported orientations
  return YES;
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInt
                                        duration:(NSTimeInterval)duration {
  // The updated y value for the origin
  CGFloat yLocation;

  // Set a new frame to update the origin on orientation change. Remember to set
  // adSize first before you update the frame.
  if (UIInterfaceOrientationIsLandscape(toInt)) {
    self.adBanner.adSize = kGADAdSizeSmartBannerLandscape;
    yLocation = self.view.frame.size.width -
                CGSizeFromGADAdSize(kGADAdSizeSmartBannerLandscape).height;
  } else {
    self.adBanner.adSize = kGADAdSizeSmartBannerPortrait;
    yLocation = self.view.frame.size.height -
                CGSizeFromGADAdSize(kGADAdSizeSmartBannerPortrait).height;
  }

  CGRect frame = self.adBanner.frame;
  frame.origin = CGPointMake(0.0, yLocation);
  self.adBanner.frame = frame;
}
@end
