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
import SwiftUI

struct InlineAdaptiveBannerContentView: View {
  @StateObject private var viewModel = InlineAdaptiveBannerViewModel()
  let navigationTitle: String
  private let horizontalPadding: CGFloat = 16

  var body: some View {
    GeometryReader { geometry in
      let contentWidth = max(0, geometry.size.width - (horizontalPadding * 2))
      ScrollView {
        LazyVStack(spacing: 10) {
          ForEach(viewModel.listItems) { item in
            switch item {
            case .menuItem(let menuItem):
              RestaurantMenuItemRow(item: menuItem)
            case .ad(let bannerView):
              let adSize = viewModel.size(for: bannerView)
              if adSize.height > 0 {
                InlineBannerViewContainer(bannerView: bannerView)
                  .frame(width: adSize.width, height: adSize.height)
              }
            }
          }
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, 10)
      }
      .background(Color(UIColor.systemGroupedBackground))
      .onAppear {
        viewModel.loadItems(width: contentWidth)
      }
      .onChange(of: geometry.size.width) { newWidth in
        viewModel.loadItems(width: max(0, newWidth - (horizontalPadding * 2)))
      }
    }
    .navigationTitle(navigationTitle)
  }
}

struct InlineAdaptiveBannerContentView_Previews: PreviewProvider {
  static var previews: some View {
    InlineAdaptiveBannerContentView(navigationTitle: "Inline Adaptive Banner")
  }
}

private struct RestaurantMenuItemRow: View {
  let item: RestaurantMenuItem

  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      Image(item.photo)
        .resizable()
        .scaledToFill()
        .frame(width: 80, height: 80)
        .clipped()
        .cornerRadius(8)

      VStack(alignment: .leading, spacing: 6) {
        Text(item.name)
          .font(.headline)

        HStack(spacing: 16) {
          Text(item.price)
            .font(.subheadline)
            .fontWeight(.semibold)
          Text(item.category)
            .font(.caption)
            .foregroundColor(.secondary)
        }

        Text(item.description)
          .font(.caption)
          .foregroundColor(.secondary)
          .fixedSize(horizontal: false, vertical: true)
      }

      Spacer(minLength: 0)
    }
    .padding(10)
    .background(Color(UIColor.secondarySystemGroupedBackground))
    .cornerRadius(10)
  }
}

private struct InlineBannerViewContainer: UIViewRepresentable {
  let bannerView: AdManagerBannerView

  func makeUIView(context: Context) -> UIView {
    return UIView()
  }

  func updateUIView(_ uiView: UIView, context: Context) {
    guard bannerView.superview !== uiView else { return }

    uiView.subviews.forEach { $0.removeFromSuperview() }
    bannerView.removeFromSuperview()
    bannerView.translatesAutoresizingMaskIntoConstraints = false
    uiView.addSubview(bannerView)

    NSLayoutConstraint.activate([
      bannerView.centerXAnchor.constraint(equalTo: uiView.centerXAnchor),
      bannerView.centerYAnchor.constraint(equalTo: uiView.centerYAnchor),
      bannerView.widthAnchor.constraint(equalTo: uiView.widthAnchor),
      bannerView.heightAnchor.constraint(equalTo: uiView.heightAnchor),
    ])
  }
}
