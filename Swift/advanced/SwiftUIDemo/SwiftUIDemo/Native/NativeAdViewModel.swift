import GoogleMobileAds

class NativeAdViewModel: NSObject, ObservableObject, GADNativeAdLoaderDelegate {
  @Published var nativeAd: GADNativeAd?
  private var adLoader: GADAdLoader!

  func refreshAd() {
    adLoader = GADAdLoader(
      adUnitID:
        "ca-app-pub-3940256099942544/3986624511",
      rootViewController: nil,
      adTypes: [.native], options: nil)
    adLoader.delegate = self
    adLoader.load(GADRequest())
  }

  func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
    self.nativeAd = nativeAd
    nativeAd.delegate = self
  }

  func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
    print("\(adLoader) failed with error: \(error.localizedDescription)")
  }
}

// MARK: - GADNativeAdDelegate implementation
extension NativeAdViewModel: GADNativeAdDelegate {
  func nativeAdDidRecordClick(_ nativeAd: GADNativeAd) {
    print("\(#function) called")
  }

  func nativeAdDidRecordImpression(_ nativeAd: GADNativeAd) {
    print("\(#function) called")
  }

  func nativeAdWillPresentScreen(_ nativeAd: GADNativeAd) {
    print("\(#function) called")
  }

  func nativeAdWillDismissScreen(_ nativeAd: GADNativeAd) {
    print("\(#function) called")
  }

  func nativeAdDidDismissScreen(_ nativeAd: GADNativeAd) {
    print("\(#function) called")
  }
}
