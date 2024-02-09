import GoogleMobileAds
import SwiftUI

struct RewardedContentView: View {
  @StateObject private var countdownTimer = CountdownTimer(10)
  @State private var coins: Int = 0
  @State private var showWatchVideoButton = false
  private let coordinator = RewardedAdCoordinator()
  let navigationTitle: String

  var body: some View {
    VStack(spacing: 20) {
      Text("The Impossible Game")
        .font(.largeTitle)

      Spacer()

      Text(countdownTimer.isComplete ? "Game over!" : "\(countdownTimer.timeLeft)")
        .font(.title2)

      VStack(spacing: 20) {
        Button("Play Again") {
          startNewGame()
        }

        Button("Watch video for additional 10 coins") {
          coordinator.showAd { rewardAmount in
            coins += rewardAmount
          }
          showWatchVideoButton = false
        }
        .opacity(showWatchVideoButton ? 1 : 0)
      }
      .font(.title2)
      .opacity(countdownTimer.isComplete ? 1 : 0)

      Spacer()

      HStack {
        Text("Coins: \(coins)")
        Spacer()
      }
      .padding()
    }
    .onAppear {
      if !countdownTimer.isComplete {
        startNewGame()
      }
    }
    .onDisappear {
      countdownTimer.pause()
    }
    .onChange(of: countdownTimer.isComplete) { newValue in
      if newValue {
        coins += 1
        showWatchVideoButton = true
      }
    }
    .navigationTitle(navigationTitle)
  }

  private func startNewGame() {
    coordinator.loadAd()

    countdownTimer.start()
  }
}

struct RewardedContentView_Previews: PreviewProvider {
  static var previews: some View {
    RewardedContentView(navigationTitle: "Rewarded")
  }
}

private class RewardedAdCoordinator: NSObject, GADFullScreenContentDelegate {
  var rewardedAd: GADRewardedAd?

  func loadAd() {
    GADRewardedAd.load(
      withAdUnitID: "ca-app-pub-3940256099942544/1712485313",
      request: GADRequest()
    ) { ad, error in
      self.rewardedAd = ad
      self.rewardedAd?.fullScreenContentDelegate = self
    }
  }

  func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
    rewardedAd = nil
  }

  func showAd(userDidEarnRewardHandler completion: @escaping (Int) -> Void) {
    guard let rewardedAd = rewardedAd else {
      return print("Ad wasn't ready")
    }

    rewardedAd.present(fromRootViewController: nil) {
      let reward = rewardedAd.adReward
      print("Reward amount: \(reward.amount)")
      completion(reward.amount.intValue)
    }
  }
}
