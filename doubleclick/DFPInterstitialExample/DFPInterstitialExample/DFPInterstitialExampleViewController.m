// DFPInterstitialExampleViewController.m
// Copyright 2012 Google Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "DFPInterstitialExampleViewController.h"
#import "SampleContants.h"

@implementation DFPInterstitialExampleViewController

@synthesize loadInterstitialButton = loadInterstitialButton_;
@synthesize showInterstitialButton = showInterstitialButton_;
@synthesize dfpInterstitial = dfpInterstitial_;

#pragma mark - View lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];

  // Disable the show button until an interstitial is loaded.
  self.showInterstitialButton.enabled = NO;
}

- (void)dealloc {
  dfpInterstitial_.delegate = nil;
  [dfpInterstitial_ release];
  [loadInterstitialButton_ release];
  [showInterstitialButton_ release];
  [super dealloc];
}

# pragma mark - Button actions

- (IBAction)loadInterstitial:(id)sender {
  // Create a new DFPInterstitial each time.  A DFPInterstitial will only show
  // one request in its lifetime. The property will release the old one and set
  // the new one.
  self.dfpInterstitial = [[[GADInterstitial alloc] init] autorelease];
  self.dfpInterstitial.delegate = self;

  // Note: Edit SampleConstants.h to update kSampleAdUnitID with your
  // interstitial ad unit id.
  self.dfpInterstitial.adUnitID = kSampleAdUnitID;

  // Load the interstitial with an ad request.
  [self.dfpInterstitial loadRequest:[GADRequest request]];

  // Set the status of the show button to loading interstitial.
  [self.showInterstitialButton setTitle:@"Loading Interstitial..."
                               forState:UIControlStateDisabled];
}

- (IBAction)showInterstitial:(id)sender {
  [self.dfpInterstitial presentFromRootViewController:self];

  // Disable the show button until another interstitial is loaded.
  self.showInterstitialButton.enabled = NO;
  [self.showInterstitialButton setTitle:@"Intersitial Not Ready"
                               forState:UIControlStateDisabled];
}

#pragma mark - GADBannerViewDelegate implementation

// Sent when an interstitial ad request completed successfully. The interstitial
// is ready to be presented at an appropriate time in your app.
- (void)interstitialDidReceiveAd:(DFPInterstitial *)ad {
  NSLog(@"Received ad successfully");

  // Enable the show button.
  self.showInterstitialButton.enabled = YES;
  [self.showInterstitialButton setTitle:@"Show Interstitial"
                               forState:UIControlStateNormal];
}

// Sent when an interstitial ad request completed without an interstitial to
// show.
- (void)interstitial:(DFPInterstitial *)ad
    didFailToReceiveAdWithError:(GADRequestError *)error {
  NSLog(@"Failed to receive ad with error: %@", [error localizedFailureReason]);

  // Disable the show button.
  self.showInterstitialButton.enabled = NO;
  [self.showInterstitialButton setTitle:@"Failed to Receive Ad"
                               forState:UIControlStateDisabled];
}

@end
