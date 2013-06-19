// DFPManualImpressionsExampleViewController.m
// Copyright 2013 Google Inc.
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

#import "DFPExtras.h"
#import "DFPManualImpressionsExampleViewController.h"
#import "GADRequest.h"

// Your DFP ad unit ID.
#define kSampleManualImpressionsAdUnitID \
    @"/6253334/dfp_example_ad/manual_impressions";
#define kRefreshButtonHeight 40

@implementation DFPManualImpressionsExampleViewController

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  // Put the request ad button at the bottom of the screen now that the view
  // bounds have the correct values.
  _requestAdButton.frame =
      CGRectMake(0,
                 self.view.bounds.size.height - kRefreshButtonHeight,
                 self.view.bounds.size.width,
                 kRefreshButtonHeight);
}
- (void)viewDidLoad {
  [super viewDidLoad];
  NSLog(@"SDK Version: %@", [GADRequest sdkVersion]);

  [self addTitleLabel];
  [self addStatusLabels];
  [self addRequestAdButton];
  [self addScrollViewAndCreateBanner];
}

- (void)dealloc {
  _scrollView.delegate = nil;
  _dfpBannerView.delegate = nil;
}

#pragma mark UI Implementation

- (void)setFirstAdReceived:(BOOL)firstAdReceived {
  _firstAdReceived = firstAdReceived;
  _firstAdReceivedStatus.text =
      [NSString stringWithFormat:@"First Ad Received: %@",
          firstAdReceived ? @"YES" : @"NO"];
}

- (void)setManualImpressionFired:(BOOL)firedManualImpression {
  _firedManualImpression = firedManualImpression;
  _firedManualImpressionStatus.text =
      [NSString stringWithFormat:@"Manual Impression Fired: %@",
          firedManualImpression ? @"YES" : @"NO"];
}

- (void)addTitleLabel {
  UILabel *title =
      [[UILabel alloc]
       initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
  title.text = @"DFP Manual Impressions Sample";
  title.textAlignment = UITextAlignmentCenter;
  title.backgroundColor = [UIColor clearColor];
  [self.view addSubview:title];
}


- (void)addStatusLabels {
  _firstAdReceivedStatus =
      [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                320,
                                                self.view.frame.size.width,
                                                20)];
  [self setFirstAdReceived:NO];
  _firstAdReceivedStatus.textAlignment = UITextAlignmentCenter;
  _firstAdReceivedStatus.backgroundColor = [UIColor clearColor];
  [self.view addSubview:_firstAdReceivedStatus];

  _firedManualImpressionStatus =
      [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                340,
                                                self.view.frame.size.width,
                                                20)];
  [self setManualImpressionFired:NO];
  _firedManualImpressionStatus.textAlignment = UITextAlignmentCenter;
  _firedManualImpressionStatus.backgroundColor = [UIColor clearColor];
  [self.view addSubview:_firedManualImpressionStatus];
}

// Adds the scroll view background color pages and an empty banner view.
- (void)addScrollViewAndCreateBanner {
  _currentPage = 0;
  _scrollView =
      [[UIScrollView alloc] initWithFrame:CGRectMake(10,
                                                     50,
                                                     GAD_SIZE_300x250.width,
                                                     GAD_SIZE_300x250.height)];
  _scrollView.delegate = self;
  _scrollView.scrollEnabled = YES;
  _scrollView.pagingEnabled = YES;
  [self.view addSubview:_scrollView];

  _colors = [NSArray arrayWithObjects:
                 [UIColor blueColor],
                 [UIColor redColor],
                 [UIColor yellowColor],
                 [UIColor blueColor],
                 [UIColor greenColor],
                 [UIColor redColor],
                 nil];
  _scrollView.contentSize = CGSizeMake(GAD_SIZE_300x250.width * _colors.count,
                                       GAD_SIZE_300x250.height);
  for (int i = 0; i < _colors.count; ++i) {
    CGRect frame = CGRectMake(_scrollView.frame.size.width * i,
                              0,
                              _scrollView.frame.size.width,
                              _scrollView.frame.size.height);

    UIView *subView = [[UIView alloc] initWithFrame:frame];
    subView.backgroundColor = [_colors objectAtIndex:i];
    [_scrollView addSubview:subView];
  }

  // Create 300x250 banner and add it to the scroll view.
  _dfpBannerView =
      [[DFPBannerView alloc] initWithAdSize:kGADAdSizeMediumRectangle];
  _dfpBannerView.adUnitID = kSampleManualImpressionsAdUnitID;

  // Set the delegate to listen for GADBannerViewDelegate events.
  _dfpBannerView.delegate = self;

  // Let the runtime know which UIViewController to restore after taking
  // the user wherever the ad goes and add it to the view hierarchy.
  _dfpBannerView.rootViewController = self;
  [_scrollView addSubview:_dfpBannerView];
}

// Adds a request ad button to request an ad.
- (void)addRequestAdButton {
  _requestAdButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  _requestAdButton.frame =
      CGRectMake(0,
                 self.view.bounds.size.height - kRefreshButtonHeight,
                 self.view.bounds.size.width,
                 kRefreshButtonHeight);
  [_requestAdButton addTarget:self
                       action:@selector(requestAd)
             forControlEvents:UIControlEventTouchUpInside];
  [_requestAdButton setTitle:@"Request Ad"
                    forState:UIControlStateNormal];
  [self.view addSubview:_requestAdButton];
}

#pragma mark Ads related methods

// Loads an ad into the DFPBannerView.
- (void)requestAd {
  [_dfpBannerView loadRequest:[GADRequest request]];
}

// Records an impression if the ad is on screen an the impression has not yet
// been recorded.
- (void)recordImpressionIfAppropriate {
  if (_firstAdReceived && !_firedManualImpression && _currentPage == _adPage) {
    [_dfpBannerView recordImpression];
    [self setManualImpressionFired:YES];
    NSLog(@"Invoked recordImpression");
    _firedManualImpression = YES;
  }
}

#pragma mark UIScrollViewDelegate implementation

- (void)scrollViewDidScroll:(UIScrollView *)sender {
  _currentPage = lround(_scrollView.contentOffset.x /
                        _scrollView.frame.size.width);
  [self recordImpressionIfAppropriate];
}

#pragma mark GADBannerViewDelegate implementation

- (void)adViewDidReceiveAd:(DFPBannerView *)adView {
  NSLog(@"Received ad successfully");
  if (!_firstAdReceived) {
    // Increase the content size to make space for the ad.
    _scrollView.contentSize =
        CGSizeMake(GAD_SIZE_300x250.width * (_colors.count + 1),
                   GAD_SIZE_300x250.height);

    // Place banner on the next page.
    _adPage = _currentPage + 1;
    _dfpBannerView.frame = CGRectMake(_scrollView.frame.size.width * _adPage,
                                      0,
                                      GAD_SIZE_300x250.width,
                                      GAD_SIZE_300x250.height);

    // Shift the other colors that come after the banner over one slot.
    for (int i = _adPage; i < _colors.count; ++i) {
      UIView *view = [_scrollView subviews][i];
      view.frame = CGRectMake(_scrollView.frame.size.width * (i+1),
                              0,
                              view.frame.size.width,
                              view.frame.size.height);
    }
  }
  [self setFirstAdReceived:YES];
  [self setManualImpressionFired:NO];
  [self recordImpressionIfAppropriate];
}

- (void)adView:(DFPBannerView *)view
    didFailToReceiveAdWithError:(GADRequestError *)error {
  NSLog(@"Failed to receive ad with error: %@", [error localizedFailureReason]);
}

@end

