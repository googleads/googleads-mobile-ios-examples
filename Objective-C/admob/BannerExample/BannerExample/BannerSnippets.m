#import "BannerSnippets.h"

@implementation BannerSnippets

static NSString *const TestAdUnit = @"ca-app-pub-3940256099942544/2435281174";

- (void)createCustomAdSizeWithBannerView:(GADBannerView *)bannerView {
  // [START create_custom_ad_size]
  bannerView.adSize = GADAdSizeFromCGSize(CGSizeMake(250, 250));
  // [END create_custom_ad_size]
}

// [START create_ad_view]
- (void)createAdViewWithAdViewContainer:(UIView *)adViewContainer
                     rootViewController:(UIViewController *)rootViewController {
  GADBannerView *bannerView = [[GADBannerView alloc] initWithAdSize:GADAdSizeBanner];
  bannerView.adUnitID = TestAdUnit;
  bannerView.rootViewController = rootViewController;
  [adViewContainer addSubview:bannerView];
}
// [END create_ad_view]

// [START load_ad]
- (void)loadBannerAdWithBannerView:(GADBannerView *)bannerView {
  // Request a large anchored adaptive banner with a width of 375.
  bannerView.adSize = GADLargeAnchoredAdaptiveBannerAdSizeWithWidth(this, 375);
  [bannerView loadRequest:[GADRequest request]];
}
// [END load_ad]

// [START ad_events]
#pragma mark - GADBannerViewDelegate

- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView {
  NSLog(@"Banner ad loaded.");
}

- (void)bannerView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error {
  NSLog(@"Banner ad failed to load: %@", error.localizedDescription);
}

- (void)bannerViewDidRecordImpression:(GADBannerView *)bannerView {
  NSLog(@"Banner ad recorded an impression.");
}

- (void)bannerViewDidRecordClick:(GADBannerView *)bannerView {
  NSLog(@"Banner ad recorded a click.");
}

- (void)bannerViewWillPresentScreen:(GADBannerView *)bannerView {
  NSLog(@"Banner ad will present screen.");
}

- (void)bannerViewWillDismissScreen:(GADBannerView *)bannerView {
  NSLog(@"Banner ad will dismiss screen.");
}

- (void)bannerViewDidDismissScreen:(GADBannerView *)bannerView {
  NSLog(@"Banner ad did dismiss screen.");
}
// [END ad_events]

@end
