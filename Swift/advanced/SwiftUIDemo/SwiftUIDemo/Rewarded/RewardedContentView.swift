import GoogleMobileAds
import SwiftUI

struct RewardedContentView: View {
  @StateObject private var viewModel = RewardedViewModel()
  @StateObject private var countdownTimer = CountdownTimer(10)
  @State private var showWatchVideoButton = false
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
          viewModel.showAd()
          showWatchVideoButton = false
        }
        .opacity(showWatchVideoButton ? 1 : 0)
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
        viewModel.addCoins(1)
        showWatchVideoButton = true
      }
    }
    .navigationTitle(navigationTitle)
  }

  private func startNewGame() {
    countdownTimer.start()
    Task {
      await viewModel.loadAd()
    }
  }
}

struct RewardedContentView_Previews: PreviewProvider {
  static var previews: some View {
    RewardedContentView(navigationTitle: "Rewarded")
  }
}

private class RewardedViewModel: NSObject, ObservableObject, GADFullScreenContentDelegate {
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
