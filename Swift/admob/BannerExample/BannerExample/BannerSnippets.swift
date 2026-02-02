import GoogleMobileAds
import UIKit

class BannerSnippets: NSObject, GADBannerViewDelegate {

  let testAdUnit = "ca-app-pub-3940256099942544/2435281174"

  func createCustomAdSize(bannerView: GADBannerView) {
    // [START create_custom_ad_size]
    bannerView.adSize = GADAdSizeFromCGSize(CGSize(width: 250, height: 250))
    // [END create_custom_ad_size]
  }

  // [START create_ad_view]
  func createAdView(adViewContainer: UIView, rootViewController: UIViewController) {
    let bannerView = GADBannerView(adSize: GADAdSizeBanner)
    bannerView.adUnitID = testAdUnit
    bannerView.rootViewController = rootViewController
    adViewContainer.addSubview(bannerView)
  }
  // [END create_ad_view]

  // [START load_ad]
  func loadBannerAd(bannerView: GADBannerView) {
    // Request a large anchored adaptive banner with a width of 375.
    bannerView.adSize = largeAnchoredAdaptiveBanner(width: 375)
    bannerView.load(GADRequest())
  }
  // [END load_ad]

  // [START ad_events]
  // MARK: - GADBannerViewDelegate methods
  func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
    print("Banner ad loaded.")
  }

  func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
    print("Banner ad failed to load: \(error.localizedDescription)")
  }

  func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
    print("Banner ad recorded an impression.")
  }

  func bannerViewDidRecordClick(_ bannerView: GADBannerView) {
    print("Banner ad recorded a click.")
  }

  func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
    print("Banner ad will present screen.")
  }

  func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
    print("Banner ad will dismiss screen.")
  }

  func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
    print("Banner ad did dismiss screen.")
  }
  // [END ad_events]
}
