//
//  Copyright 2022 Google LLC
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import GoogleMobileAds
import SwiftUI

struct InterstitialContentView: View {
  @StateObject private var countdownTimer = CountdownTimer()
  @State private var showGameOverAlert = false
  private let viewModel = InterstitialViewModel()
  let navigationTitle: String

  // [START show_ad]
  var body: some View {
    // [START_EXCLUDE] Hide from developer docs code snippet
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
      // [END_EXCLUDE]
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
      // [END show_ad]
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
