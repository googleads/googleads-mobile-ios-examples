// DFPBannerExampleViewController.m
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

#import "DFPBannerExampleViewController.h"
#import "GADRequest.h"
#import "SampleConstants.h"

#define MARGIN 5
#define REFRESH_BUTTON_HEIGHT 40

@implementation DFPBannerExampleViewController

#pragma mark init/dealloc

- (void)viewDidLoad {
  [super viewDidLoad];

  // Create a view of the standard size at the top of the screen.
  // Available AdSize constants are explained in GADAdSize.h.
  dfpBannerView_ = [[DFPBannerView alloc] initWithAdSize:kGADAdSizeBanner];

  // This sample app comes with multiple samples. Choose the sample you wish
  // to run by changing the value of kSampleToRun in SampleConstants.h.
#if (kSampleToRun == kSampleBanner)

  dfpBannerView_.adUnitID = kSampleAdUnitID;

#elif (kSampleToRun == kSampleMultipleAdSizes)
  // Add a refresh button.
  [self addRefreshButton];

  [self setUpBannerForMultipleAdSizesExample];

#elif (kSampleToRun == kSampleAppEvents)
  // Add a refresh button.
  [self addRefreshButton];

  [self setUpBannerForAppEventsExample];

#else

#error Unknown value in SAMPLE

#endif

  // Set the delegate to listen for GADBannerViewDelegate events.
  dfpBannerView_.delegate = self;

  // Let the runtime know which UIViewController to restore after taking
  // the user wherever the ad goes and add it to the view hierarchy.
  dfpBannerView_.rootViewController = self;
  [self.view addSubview:dfpBannerView_];

  // Initiate a generic request to load it with an ad.
  [dfpBannerView_ loadRequest:[GADRequest request]];
}

- (void)dealloc {
  dfpBannerView_.delegate = nil;
  dfpBannerView_.adSizeDelegate = nil;
  dfpBannerView_.appEventDelegate = nil;
  [dfpBannerView_ release];
  [super dealloc];
}

#pragma Banner Setup methods

- (void)setUpBannerForMultipleAdSizesExample {
  dfpBannerView_.adUnitID = kSampleMultipleAdSizesAdUnitID;

  // Set the validAdSizes property with an array of valid sizes
  // for your banner.  These sizes should match the supported sizes
  // in your DFP creative.
  GADAdSize size1 = kGADAdSizeBanner;
  GADAdSize size2 = kGADAdSizeMediumRectangle;
  GADAdSize size3 = GADAdSizeFromCGSize(CGSizeMake(120, 20));
  NSMutableArray *validSizes = [NSMutableArray array];
  [validSizes addObject:[NSValue valueWithBytes:&size1
                                       objCType:@encode(GADAdSize)]];
  [validSizes addObject:[NSValue valueWithBytes:&size2
                                       objCType:@encode(GADAdSize)]];
  [validSizes addObject:[NSValue valueWithBytes:&size3
                                       objCType:@encode(GADAdSize)]];
  dfpBannerView_.validAdSizes = validSizes;

  // Set the ad size delegate to listen for changes in ad size.
  dfpBannerView_.adSizeDelegate = self;
}

- (void)setUpBannerForAppEventsExample {
  dfpBannerView_.adUnitID = kSampleAppEventsAdUnitID;

  // Set the app event delegate to listen for app events.
  dfpBannerView_.appEventDelegate = self;
}

#pragma mark Refresh Button impl

// Adds a refresh button to load a new ad.
- (void)addRefreshButton {
  UIButton *refreshButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  refreshButton.frame =
      CGRectMake(MARGIN,
                 self.view.bounds.size.height - REFRESH_BUTTON_HEIGHT - MARGIN,
                 self.view.bounds.size.width - 2 * MARGIN,
                 REFRESH_BUTTON_HEIGHT);
  [refreshButton addTarget:self
                     action:@selector(refreshBanner)
           forControlEvents:UIControlEventTouchUpInside];
  [refreshButton setTitle:@"Refresh"
                  forState:UIControlStateNormal];
  [self.view addSubview:refreshButton];
}

// Refreshes the DFPBannerView.
- (void)refreshBanner {
  [dfpBannerView_ loadRequest:[GADRequest request]];
}

#pragma mark GADBannerViewDelegate impl

- (void)adViewDidReceiveAd:(DFPBannerView *)adView {
  NSLog(@"Received ad successfully");

  // Center the banner view horizontally.
  dfpBannerView_.center = CGPointMake(self.view.center.x,
                                      dfpBannerView_.center.y);
}

- (void)adView:(DFPBannerView *)view
    didFailToReceiveAdWithError:(GADRequestError *)error {
  NSLog(@"Failed to receive ad with error: %@", [error localizedFailureReason]);
}

#pragma mark GADAdSizeDelegate impl

// This method gets invoked when a DFPBannerView is about to change size.
// Only a multiple-sized DFPBannerView should implement this method.
- (void)adView:(DFPBannerView *)view willChangeAdSizeTo:(GADAdSize)size {
  NSLog(@"Changing ad size from %@ to %@",
        NSStringFromGADAdSize(view.adSize),
        NSStringFromGADAdSize(size));
}

#pragma mark GADAppEventDelegate impl

// Called when a DFP creative invokes an app event. This method only
// needs to be implemented if your creative makes use of app events.
- (void)adView:(DFPBannerView *)banner
    didReceiveAppEvent:(NSString *)name
    withInfo:(NSString *)info {
  NSLog(@"Received app event (%@, %@)", name, info);
  // Checking for a "color" event name with information being a color.
  if ([name isEqualToString:@"color"]) {
    if ([info isEqualToString:@"red"]) {
      self.view.backgroundColor = [UIColor redColor];
    } else if ([info isEqualToString:@"green"]) {
      self.view.backgroundColor = [UIColor greenColor];
    } else if ([info isEqualToString:@"blue"]) {
      self.view.backgroundColor = [UIColor blueColor];
    }
  }
}

@end
