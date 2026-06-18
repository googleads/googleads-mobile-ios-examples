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
struct SwipeableFeedView: View {
  @StateObject private var viewModel = SwipeableFeedViewModel()
  var onBack: () -> Void = {}

  var body: some View {
    ScrollView(.vertical) {
      LazyVStack(spacing: 0) {
        // In this simulated swipeable vertical feed, even positions represent
        // organic content slides and odd positions represent ad slots.
        ForEach(0..<100, id: \.self) { index in
          ZStack {
            if index.isMultiple(of: 2) {
              ContentSlideView(viewModel: viewModel)
            } else {
              ZStack {
                Color.black
                if let ad = viewModel.swipeableInterstitialAd {
                  AdViewRepresentable(adView: ad.adView)
                }
              }
            }
          }
          .containerRelativeFrame([.horizontal, .vertical])
          .id(index)
        }
      }
      .scrollTargetLayout()
    }
    .scrollTargetBehavior(.paging)
    .scrollPosition(id: $viewModel.scrolledID)
    .scrollDisabled(viewModel.isScrollDisabled)
    .ignoresSafeArea()
    .background(Color(red: 0.13, green: 0.13, blue: 0.13))
    .colorScheme(.dark)
    .onChange(of: viewModel.scrolledID) { _, _ in
      viewModel.handleSlideSettled()
    }
    .onAppear {
      viewModel.reloadAd()
    }
    .overlay(alignment: .topLeading) {
      if (viewModel.scrolledID ?? 0).isMultiple(of: 2) {
        Button(action: {
          onBack()
        }) {
          HStack(spacing: 4) {
            Image(systemName: "chevron.left")
            Text("Back")
          }
          .font(.system(size: 17, weight: .semibold))
          .foregroundColor(.white)
          .padding(.leading, 20)
        }
      }
    }
  }
}
