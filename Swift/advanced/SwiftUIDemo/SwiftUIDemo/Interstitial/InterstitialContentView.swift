import GoogleMobileAds
import SwiftUI

struct InterstitialContentView: View {
  @StateObject private var countdownTimer = CountdownTimer()
  @State private var showGameOverAlert = false
  private let viewModel = InterstitialViewModel()
  let navigationTitle: String

  var body: some View {
    VStack(spacing: 20) {
      Text("The Impossible Game")
        .font(.largeTitle)

      Spacer()

      Text(countdownTimer.isComplete ? "You lose!" : "\(countdownTimer.timeLeft)")
        .font(.title2)

      Button("Play Again") {
        startNewGame()
      }
      .font(.title2)
      .opacity(countdownTimer.isComplete ? 1 : 0)

      Spacer()
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
      showGameOverAlert = newValue
    }
    .alert(isPresented: $showGameOverAlert) {
      Alert(
        title: Text("Game Over"),
        message: Text("You lasted \(countdownTimer.countdownTime) seconds"),
        dismissButton: .cancel(
          Text("OK"),
          action: {
            viewModel.showAd()
          }))
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

struct InterstitialContentView_Previews: PreviewProvider {
  static var previews: some View {
    InterstitialContentView(navigationTitle: "Interstitial")
  }
}
