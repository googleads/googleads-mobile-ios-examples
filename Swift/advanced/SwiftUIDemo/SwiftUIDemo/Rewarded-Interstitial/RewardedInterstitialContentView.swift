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

struct RewardedInterstitialContentView: View {
  @StateObject private var viewModel = RewardedInterstitialViewModel()
  @StateObject private var countdownTimer = CountdownTimer(10)
  @State private var showAdDialog = false
  @State private var showAd = false
  let navigationTitle: String

  var body: some View {
    ZStack {
      rewardedInterstitialBody

      AdDialogContentView(isPresenting: $showAdDialog, countdownComplete: $showAd)
        .opacity(showAdDialog ? 1 : 0)
    }
  }

  // [START show_ad]
  var rewardedInterstitialBody: some View {
    // [START_EXCLUDE] Hide from developer docs code snippet
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
      // [END_EXCLUDE]
    }
    .onChange(
      of: showAd,
      perform: { newValue in
        if newValue {
          viewModel.showAd()
        }
      }
    )
    // [END show_ad]
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
