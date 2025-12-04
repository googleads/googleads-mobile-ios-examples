//
//  Copyright (C) 2025 Google, Inc.
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

private class BannerSnippets: UIViewController {

  var bannerView: AdManagerBannerView!

  override func viewDidLoad() {
    super.viewDidLoad()
    createBannerViewProgrammatically()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    loadInlineAdaptiveBanner()
  }

  private func createBannerViewProgrammatically() {
    // [START create_admanager_banner_view]
    // Initialize the banner view.
    bannerView = AdManagerBannerView()

    bannerView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(bannerView)

    // This example doesn't give width or height constraints, as the ad size gives the banner an
    // intrinsic content size to size the view.
    NSLayoutConstraint.activate([
      // Align the banner's bottom edge with the safe area's bottom edge
      bannerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      // Center the banner horizontally in the view
      bannerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
    ])
    // [END create_admanager_banner_view]
  }

  private func loadInlineAdaptiveBanner() {
    // [START get_width]
    let totalWidth = view.bounds.width
    // Make sure the ad fits inside the readable area.
    let insets = view.safeAreaInsets
    let adWidth = totalWidth - insets.left - insets.right
    // [END get_width]

    // View is not laid out yet, return early.
    guard adWidth > 0 else { return }

    // [START set_adaptive_ad_size]
    let adSize = currentOrientationInlineAdaptiveBanner(width: adWidth)
    bannerView.adSize = adSize

    // For Ad Manager, the `adSize` property is used for the adaptive banner ad
    // size. The `validAdSizes` property is used as normal for the supported
    // reservation sizes for the ad placement.
    let validAdSize = currentOrientationAnchoredAdaptiveBanner(width: adWidth)
    bannerView.validAdSizes = [nsValue(for: validAdSize)]
    // [END set_adaptive_ad_size]

    // Test ad unit ID for inline adaptive banners.
    bannerView.adUnitID = "/21775744923/example/adaptive-banner"
    bannerView.load(AdManagerRequest())
  }
}
