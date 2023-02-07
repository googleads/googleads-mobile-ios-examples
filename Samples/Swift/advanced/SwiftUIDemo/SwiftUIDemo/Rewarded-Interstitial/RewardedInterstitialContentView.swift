import GoogleMobileAds
import SwiftUI

struct RewardedInterstitialContentView: View {
  @StateObject private var countdownTimer = CountdownTimer(10)
  @State private var coins: Int = 0
  @State private var showAdDialog = false
  @State private var showAd = false
  private let coordinator = RewardedAdCoordinator()
  private let adViewControllerRepresentable = AdViewControllerRepresentable()
  let navigationTitle: String

  var body: some View {
    ZStack {
      rewardedInterstitialBody

      AdDialogContentView(isPresenting: $showAdDialog, showAd: $showAd)
        .opacity(showAdDialog ? 1 : 0)
    }
  }

  var adViewControllerRepresentableView: some View {
    adViewControllerRepresentable
      .frame(width: .zero, height: .zero)
  }

  var rewardedInterstitialBody: some View {
    VStack(spacing: 20) {
      Text("The Impossible Game")
        .font(.largeTitle)
        .background(adViewControllerRepresentableView)

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
          coordinator.showAd(from: adViewControllerRepresentable.viewController) { rewardAmount in
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

// MARK: - Helper to present Rewarded Interstitial Ad
private struct AdViewControllerRepresentable: UIViewControllerRepresentable {
  let viewController = UIViewController()

  func makeUIViewController(context: Context) -> some UIViewController {
    return viewController
  }

  func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
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

  func showAd(
    from viewController: UIViewController,
    userDidEarnRewardHandler completion: @escaping (Int) -> Void
  ) {
    guard let rewarded = rewardedInterstitialAd else {
      return print("Ad wasn't ready")
    }

    rewarded.present(fromRootViewController: viewController) {
      let reward = rewarded.adReward
      print("Reward amount: \(reward.amount)")
      completion(reward.amount.intValue)
    }
  }
}
