//
//  Copyright 2026 Google LLC
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

import SwiftUI

@available(iOS 17.0, *)
struct ContentSlideView: View {
  @ObservedObject var viewModel: SwipeableFeedViewModel

  var body: some View {
    VStack(spacing: 20) {
      Text("Swipe up to see ad")
        .font(.system(size: 24, weight: .bold))
        .foregroundColor(.white)

      Text("Requested screen hold duration")
      Picker("", selection: $viewModel.requestedMaxScreenHoldDuration) {
        ForEach([0.0, 5.0], id: \.self) { seconds in
          Text("\(Int(seconds))s").tag(seconds)
        }
      }
      .pickerStyle(.segmented)
      .colorScheme(.dark)
      .padding(.horizontal, 40)
      .onChange(of: viewModel.requestedMaxScreenHoldDuration) { _, _ in
        viewModel.reloadAd()
      }

      Text(
        viewModel.swipeableInterstitialAd.map {
          "Loaded hold time: \(Int($0.minScreenHoldDuration))s"
        } ?? " "
      )
      .font(.system(size: 16, weight: .medium))
      .foregroundColor(.white)

      Text(viewModel.adLoadState.statusText)
        .font(.system(size: 16, weight: .bold))
        .foregroundColor(viewModel.adLoadState.statusColor)
    }
  }
}
