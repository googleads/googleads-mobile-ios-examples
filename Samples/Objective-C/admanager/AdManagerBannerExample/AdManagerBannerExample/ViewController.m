//  Copyright (c) 2014 Google. All rights reserved.

#import <GoogleMobileAds/GoogleMobileAds.h>

#import "ViewController.h"

@interface ViewController () <GADBannerViewDelegate>
@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  // Replace this ad unit ID with your own ad unit ID.
  self.bannerView.adUnitID = @"/6499/example/banner";
  self.bannerView.rootViewController = self;
  self.bannerView.delegate = self;
  [self.bannerView loadRequest:[GAMRequest request]];
}

#pragma mark GADBannerViewDelegate implementation

- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView {
  NSLog(@"bannerViewDidReceiveAd");
}

- (void)bannerView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error {
  NSLog(@"bannerView:didFailToReceiveAdWithError: %@", [error localizedDescription]);
}

- (void)bannerViewDidRecordImpression:(GADBannerView *)bannerView {
  NSLog(@"bannerViewDidRecordImpression");
}

- (void)bannerViewWillPresentScreen:(GADBannerView *)bannerView {
  NSLog(@"bannerViewWillPresentScreen");
}

- (void)bannerViewWillDismissScreen:(GADBannerView *)bannerView {
  NSLog(@"bannerViewWillDismissScreen");
}

- (void)bannerViewDidDismissScreen:(GADBannerView *)bannerView {
  NSLog(@"bannerViewDidDismissScreen");
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
