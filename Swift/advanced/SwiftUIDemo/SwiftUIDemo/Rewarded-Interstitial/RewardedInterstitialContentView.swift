import GoogleMobileAds
import SwiftUI

struct RewardedInterstitialContentView: View {
  @StateObject private var viewModel = RewardedInterstitialViewModel()
  @StateObject private var countdownTimer = CountdownTimer(10)
  @State private var showAdDialog = false
  @State private var showAd = false
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
        Text("Coins: \(viewModel.coins)")
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
        viewModel.addCoins(1)
      }
    }
    .onChange(
      of: showAd,
      perform: { newValue in
        if newValue {
          viewModel.showAd()
        }
      }
    )
    .navigationTitle(navigationTitle)
  }

  private func startNewGame() {
    countdownTimer.start()
    Task {
      await viewModel.loadAd()
    }
  }
}

struct RewardedIntersititalContentView_Previews: PreviewProvider {
  static var previews: some View {
    RewardedInterstitialContentView(navigationTitle: "Rewarded Interstitial")
  }
}

private class RewardedInterstitialViewModel: NSObject, ObservableObject,
  GADFullScreenContentDelegate
{
  @Published var coins = 0
  private var rewardedInterstitialAd: GADRewardedInterstitialAd?

  func loadAd() async {
    do {
      rewardedInterstitialAd = try await GADRewardedInterstitialAd.load(
        withAdUnitID: "ca-app-pub-3940256099942544/6978759866", request: GADRequest())
      rewardedInterstitialAd?.fullScreenContentDelegate = self
    } catch {
      print(
        "Failed to load rewarded interstitial ad with error: \(error.localizedDescription)")
    }
  }

  func showAd() {
    guard let rewardedInterstitialAd = rewardedInterstitialAd else {
      return print("Ad wasn't ready.")
    }

    rewardedInterstitialAd.present(fromRootViewController: nil) {
      let reward = rewardedInterstitialAd.adReward
      print("Reward amount: \(reward.amount)")
      self.addCoins(reward.amount.intValue)
    }
  }

  func addCoins(_ amount: Int) {
    coins += amount
  }

  // MARK: - GADFullScreenContentDelegate methods

  func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
    rewardedInterstitialAd = nil
  }
}
