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

// [START add_view_model_to_view]
struct NativeContentView: View {
  // Single source of truth for the native ad data.
  @StateObject private var nativeViewModel = NativeAdViewModel()
  // [START_EXCLUDE silent]
  let navigationTitle: String
  // [END_EXCLUDE]

  var body: some View {
    ScrollView {
      VStack(spacing: 20) {
        // Updates when the native ad data changes.
        NativeAdViewContainer(nativeViewModel: nativeViewModel)
          .frame(minHeight: 300)  // minHeight determined from xib.
        // [END add_view_model_to_view]

        Text(
          nativeViewModel.nativeAd?.mediaContent.hasVideoContent == true
            ? "Ad contains a video asset." : "Ad does not contain a video."
        )
        .frame(maxWidth: .infinity)
        .foregroundColor(.gray)
        .opacity(nativeViewModel.nativeAd == nil ? 0 : 1)

        Button("Refresh Ad") {
          refreshAd()
        }

        Text(
          "SDK Version:"
            + "\(string(for: MobileAds.shared.versionNumber))")
      }
      .padding()
    }
    .onAppear {
      refreshAd()
    }
    .navigationTitle(navigationTitle)
  }

  private func refreshAd() {
    nativeViewModel.refreshAd()
  }
}

struct NativeContentView_Previews: PreviewProvider {
  static var previews: some View {
    NativeContentView(navigationTitle: "Native")
  }
}

// [START create_native_ad_view]
private struct NativeAdViewContainer: UIViewRepresentable {
  typealias UIViewType = NativeAdView

  // Observer to update the UIView when the native ad value changes.
  @ObservedObject var nativeViewModel: NativeAdViewModel

  func makeUIView(context: Context) -> NativeAdView {
    return
      Bundle.main.loadNibNamed(
        "NativeAdView",
        owner: nil,
        options: nil)?.first as! NativeAdView
  }

  func updateUIView(_ nativeAdView: NativeAdView, context: Context) {
    guard let nativeAd = nativeViewModel.nativeAd else { return }

    // Each UI property is configurable using your native ad.
    (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline

    nativeAdView.mediaView?.mediaContent = nativeAd.mediaContent

    (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body

    (nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image

    (nativeAdView.starRatingView as? UIImageView)?.image = imageOfStars(from: nativeAd.starRating)

    (nativeAdView.storeView as? UILabel)?.text = nativeAd.store

    (nativeAdView.priceView as? UILabel)?.text = nativeAd.price

    (nativeAdView.advertiserView as? UILabel)?.text = nativeAd.advertiser

    (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)

    // For the SDK to process touch events properly, user interaction should be disabled.
    nativeAdView.callToActionView?.isUserInteractionEnabled = false

    // Associate the native ad view with the native ad object. This is required to make the ad
    // clickable.
    // Note: this should always be done after populating the ad views.
    nativeAdView.nativeAd = nativeAd
  }
  // [END create_native_ad_view]

  private func imageOfStars(from starRating: NSDecimalNumber?) -> UIImage? {
    guard let rating = starRating?.doubleValue else {
      return nil
    }
    if rating >= 5 {
      return UIImage(named: "stars_5")
    } else if rating >= 4.5 {
      return UIImage(named: "stars_4_5")
    } else if rating >= 4 {
      return UIImage(named: "stars_4")
    } else if rating >= 3.5 {
      return UIImage(named: "stars_3_5")
    } else {
      return nil
    }
  }
}
