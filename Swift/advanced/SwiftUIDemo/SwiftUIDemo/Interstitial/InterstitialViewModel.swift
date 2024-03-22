import GoogleMobileAds

class InterstitialViewModel: NSObject, GADFullScreenContentDelegate {
  private var interstitialAd: GADInterstitialAd?

  func loadAd() async {
    do {
      interstitialAd = try await GADInterstitialAd.load(
        withAdUnitID: "ca-app-pub-3940256099942544/4411468910", request: GADRequest())
      interstitialAd?.fullScreenContentDelegate = self
    } catch {
      print("Failed to load interstitial ad with error: \(error.localizedDescription)")
    }
  }

  func showAd() {
    guard let interstitialAd = interstitialAd else {
      return print("Ad wasn't ready.")
    }

    interstitialAd.present(fromRootViewController: nil)
  }

  // MARK: - GADFullScreenContentDelegate methods

  func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
    interstitialAd = nil
  }
}
