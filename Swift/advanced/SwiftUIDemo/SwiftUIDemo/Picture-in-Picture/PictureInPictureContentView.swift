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

import GoogleMobileAds
import GoogleMobileAds_Private
import SwiftUI

struct PictureInPictureContentView: View {
  @StateObject private var viewModel = PictureInPictureViewModel()
  let navigationTitle: String

  private let presentationScopes: [PresentationScopeOption] = [
    PresentationScopeOption(id: .screen, title: "Screen"),
    PresentationScopeOption(id: .application, title: "Application"),
  ]

  private let positions: [PositionOption] = [
    PositionOption(id: .default, title: "Default"),
    PositionOption(id: .topLeft, title: "Top Left"),
    PositionOption(id: .topRight, title: "Top Right"),
    PositionOption(id: .bottomLeft, title: "Bottom Left"),
    PositionOption(id: .bottomRight, title: "Bottom Right"),
  ]

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 20) {
        Text(
          "Picture-in-Picture ads display as a draggable floating window that snaps to screen corners and can persist across screens."
        )
        .font(.subheadline)

        optionsCard

        HStack(spacing: 8) {
          Button("Load ad") {
            Task {
              await viewModel.loadAd()
            }
          }
          .frame(maxWidth: .infinity)
          .disabled(viewModel.isLoading)

          Button("Show ad") {
            viewModel.showAd()
          }
          .frame(maxWidth: .infinity)
          .disabled(!viewModel.isAdAvailable || viewModel.isAdShowing || viewModel.isLoading)

          Button("Hide ad") {
            viewModel.hideAd()
          }
          .frame(maxWidth: .infinity)
          .disabled(!viewModel.isAdShowing || viewModel.isLoading)
        }
        .buttonStyle(.bordered)

        if !viewModel.statusMessage.isEmpty {
          Text(viewModel.statusMessage)
            .font(.footnote)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
        }
      }
      .padding(16)
    }
    .navigationTitle(navigationTitle)
    .onAppear {
      viewModel.onAppear()
    }
    .onDisappear {
      viewModel.onDisappear()
    }
  }

  private var optionsCard: some View {
    VStack(alignment: .leading, spacing: 16) {
      VStack(alignment: .leading, spacing: 4) {
        Text("PictureInPictureAdOptions")
          .font(.headline)
        Text("Applied when showing the ad.")
          .font(.footnote)
          .foregroundColor(.secondary)
      }

      VStack(alignment: .leading, spacing: 8) {
        Text("Presentation scope")
          .font(.subheadline)
        Picker("Presentation scope", selection: $viewModel.selectedScope) {
          ForEach(presentationScopes) { option in
            Text(option.title).tag(option.id)
          }
        }
        .pickerStyle(.segmented)
      }

      HStack {
        Text("Position")
          .font(.subheadline)
        Spacer()
        Picker("Position", selection: $viewModel.selectedPosition) {
          ForEach(positions) { option in
            Text(option.title).tag(option.id)
          }
        }
        .pickerStyle(.menu)
      }
      .padding(.horizontal, 12)
      .padding(.vertical, 6)
      .background(Color(UIColor.systemBackground))
      .cornerRadius(8)
    }
    .padding(16)
    .background(Color(UIColor.secondarySystemBackground))
    .cornerRadius(8)
  }
}

private struct PresentationScopeOption: Identifiable {
  let id: PictureInPictureAdPresentationScope
  let title: String
}

private struct PositionOption: Identifiable {
  let id: PictureInPictureAdPosition
  let title: String
}

struct PictureInPictureContentView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      PictureInPictureContentView(navigationTitle: "Picture-in-Picture")
    }
  }
}
