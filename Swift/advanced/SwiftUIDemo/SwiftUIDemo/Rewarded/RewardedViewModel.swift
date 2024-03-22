import GoogleMobileAds

class RewardedViewModel: NSObject, ObservableObject, GADFullScreenContentDelegate {
  @Published var coins = 0
  private var rewardedAd: GADRewardedAd?

  func loadAd() async {
    do {
      rewardedAd = try await GADRewardedAd.load(
        withAdUnitID: "ca-app-pub-3940256099942544/1712485313", request: GADRequest())
      rewardedAd?.fullScreenContentDelegate = self
    } catch {
      print("Failed to load rewarded ad with error: \(error.localizedDescription)")
    }
  }

  func showAd() {
    guard let rewardedAd = rewardedAd else {
      return print("Ad wasn't ready.")
    }

    rewardedAd.present(fromRootViewController: nil) {
      let reward = rewardedAd.adReward
      print("Reward amount: \(reward.amount)")
      self.addCoins(reward.amount.intValue)
    }
  }

  func addCoins(_ amount: Int) {
    coins += amount
  }

  // MARK: - GADFullScreenContentDelegate methods

  func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
    rewardedAd = nil
  }
}
