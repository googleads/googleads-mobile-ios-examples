#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BannerSnippets : NSObject <GADBannerViewDelegate>

- (void)createCustomAdSizeWithBannerView:(GADBannerView *)bannerView;

- (void)createAdViewWithAdViewContainer:(UIView *)adViewContainer
                     rootViewController:(UIViewController *)rootViewController;

- (void)loadBannerAdWithBannerView:(GADBannerView *)bannerView;

@end

NS_ASSUME_NONNULL_END
