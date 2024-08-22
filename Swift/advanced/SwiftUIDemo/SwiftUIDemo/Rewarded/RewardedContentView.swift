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

struct RewardedContentView: View {
  @StateObject private var viewModel = RewardedViewModel()
  @StateObject private var countdownTimer = CountdownTimer(10)
  @State private var showWatchVideoButton = false
  let navigationTitle: String

  // [START show_ad]
  var body: some View {
    VStack(spacing: 20) {
      // [START_EXCLUDE silent] Hide from developer docs code snippet
      Text("The Impossible Game")
        .font(.largeTitle)

      Spacer()

      Text(countdownTimer.isComplete ? "Game over!" : "\(countdownTimer.timeLeft)")
        .font(.title2)

      VStack(spacing: 20) {
        Button("Play Again") {
          startNewGame()
        }
        // [END_EXCLUDE]
        Button("Watch video for additional 10 coins") {
          viewModel.showAd()
          showWatchVideoButton = false
        }
        // [END show_ad]
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
