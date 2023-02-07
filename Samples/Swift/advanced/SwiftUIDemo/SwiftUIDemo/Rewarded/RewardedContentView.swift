import GoogleMobileAds
import SwiftUI

struct RewardedContentView: View {
  @StateObject private var countdownTimer = CountdownTimer(10)
  @State private var coins: Int = 0
  @State private var showWatchVideoButton = false
  private let coordinator = RewardedAdCoordinator()
  private let adViewControllerRepresentable = AdViewControllerRepresentable()
  let navigationTitle: String

  var adViewControllerRepresentableView: some View {
    adViewControllerRepresentable
      .frame(width: .zero, height: .zero)
  }

  var body: some View {
    VStack(spacing: 20) {
      Text("The Impossible Game")
        .font(.largeTitle)
        .background(adViewControllerRepresentableView)

      Spacer()

      Text(countdownTimer.isComplete ? "Game over!" : "\(countdownTimer.timeLeft)")
        .font(.title2)

      VStack(spacing: 20) {
        Button("Play Again") {
          startNewGame()
        }

        Button("Watch video for additional 10 coins") {
          coordinator.showAd(from: adViewControllerRepresentable.viewController) { rewardAmount in
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

// MARK: - Helper to present Rewarded Ad
private struct AdViewControllerRepresentable: UIViewControllerRepresentable {
  let viewController = UIViewController()

  func makeUIViewController(context: Context) -> some UIViewController {
    return viewController
  }

  func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
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

  func showAd(
    from viewController: UIViewController,
    userDidEarnRewardHandler completion: @escaping (Int) -> Void
  ) {
    guard let rewardedAd = rewardedAd else {
      return print("Ad wasn't ready")
    }

    rewardedAd.present(fromRootViewController: viewController) {
      let reward = rewardedAd.adReward
      print("Reward amount: \(reward.amount)")
      completion(reward.amount.intValue)
    }
  }
}
