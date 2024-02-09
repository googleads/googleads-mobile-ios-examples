import GoogleMobileAds
import SwiftUI

struct RewardedInterstitialContentView: View {
  @StateObject private var countdownTimer = CountdownTimer(10)
  @State private var coins: Int = 0
  @State private var showAdDialog = false
  @State private var showAd = false
  private let coordinator = RewardedAdCoordinator()
  let navigationTitle: String

  var body: some View {
    ZStack {
      rewardedInterstitialBody

      AdDialogContentView(isPresenting: $showAdDialog, showAd: $showAd)
        .opacity(showAdDialog ? 1 : 0)
    }
  }

  var rewardedInterstitialBody: some View {
    VStack(spacing: 20) {
      Text("The Impossible Game")
        .font(.largeTitle)

      Spacer()

      Text(countdownTimer.isComplete ? "Game over!" : "\(countdownTimer.timeLeft)")
        .font(.title2)

      Button("Play Again") {
        startNewGame()
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
        showAdDialog = true
        coins += 1
      }
    }
    .onChange(
      of: showAd,
      perform: { newValue in
        if newValue {
          coordinator.showAd { rewardAmount in
            coins += rewardAmount
          }
        }
      }
    )
    .navigationTitle(navigationTitle)
  }

  private func startNewGame() {
    coordinator.loadAd()

    countdownTimer.start()
  }
}

struct RewardedIntersititalContentView_Previews: PreviewProvider {
  static var previews: some View {
    RewardedInterstitialContentView(navigationTitle: "Rewarded Interstitial")
  }
}

private class RewardedAdCoordinator: NSObject, GADFullScreenContentDelegate {
  var rewardedInterstitialAd: GADRewardedInterstitialAd?

  func loadAd() {
    GADRewardedInterstitialAd.load(
      withAdUnitID: "ca-app-pub-3940256099942544/6978759866", request: GADRequest()
    ) { ad, error in
      self.rewardedInterstitialAd = ad
      self.rewardedInterstitialAd?.fullScreenContentDelegate = self
    }
  }

  func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
    rewardedInterstitialAd = nil
  }

  func showAd(userDidEarnRewardHandler completion: @escaping (Int) -> Void) {
    guard let rewarded = rewardedInterstitialAd else {
      return print("Ad wasn't ready")
    }

    rewarded.present(fromRootViewController: nil) {
      let reward = rewarded.adReward
      print("Reward amount: \(reward.amount)")
      completion(reward.amount.intValue)
    }
  }
}
