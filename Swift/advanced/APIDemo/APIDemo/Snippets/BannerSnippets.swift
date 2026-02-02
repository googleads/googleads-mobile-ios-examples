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

private class BannerSnippets: UIViewController, BannerViewDelegate {

  let testAdUnitID = "ca-app-pub-3940256099942544/2435281174"
  var bannerView: BannerView!

  override func viewDidLoad() {
    super.viewDidLoad()
    createBannerViewProgrammatically()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    loadLargeAnchoredAdaptiveBanner()
  }

  // [START handle_orientation_changes]
  override func viewWillTransition(
    to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator
  ) {
    coordinator.animate(alongsideTransition: { _ in
      // Load a new ad for the new orientation.
    })
  }
  // [END handle_orientation_changes]

  private func createBannerViewProgrammatically() {
    // [START create_admob_banner_view]
    // Initialize the banner view.
    bannerView = BannerView()
    // [START set_delegate]
    bannerView.delegate = self
    // [END set_delegate]

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
    // [END create_admob_banner_view]
  }

  private func loadLargeAnchoredAdaptiveBanner() {
    // [START get_width]
    let totalWidth = view.bounds.width
    // Make sure the ad fits inside the readable area.
    let insets = view.safeAreaInsets
    let adWidth = totalWidth - insets.left - insets.right
    // [END get_width]

    // View is not laid out yet, return early.
    guard adWidth > 0 else { return }

    // [START set_adaptive_ad_size]
    let adSize = largeLandscapeAnchoredAdaptiveBanner(width: adWidth)
    bannerView.adSize = adSize
    // [END set_adaptive_ad_size]

    // Test ad unit ID for inline adaptive banners.
    bannerView.adUnitID = testAdUnitID
    bannerView.load(Request())
  }

  func createCustomAdSize(bannerView: BannerView) {
    // [START create_custom_ad_size]
    bannerView.adSize = adSizeFor(cgSize: CGSize(width: 250, height: 250))
    // [END create_custom_ad_size]
  }

  // [START create_ad_view]
  func createAdView(adViewContainer: UIView, rootViewController: UIViewController) {
    let bannerView = BannerView(adSize: AdSizeBanner)
    bannerView.adUnitID = testAdUnitID
    bannerView.rootViewController = rootViewController
    adViewContainer.addSubview(bannerView)
  }
  // [END create_ad_view]

  // [START load_ad]
  func loadBannerAd(bannerView: BannerView) {
    // Request a large anchored adaptive banner with a width of 375.
    // [START ad_size]
    bannerView.adSize = largeLandscapeAnchoredAdaptiveBanner(width: 375)
    // [END ad_size]
    bannerView.load(Request())
  }
  // [END load_ad]

  // [START ad_events]
  // MARK: - BannerViewDelegate methods
  func bannerViewDidReceiveAd(_ bannerView: BannerView) {
    print("Banner ad loaded.")
  }

  func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
    print("Banner ad failed to load: \(error.localizedDescription)")
  }

  func bannerViewDidRecordImpression(_ bannerView: BannerView) {
    print("Banner ad recorded an impression.")
  }

  func bannerViewDidRecordClick(_ bannerView: BannerView) {
    print("Banner ad recorded a click.")
  }

  func bannerViewWillPresentScreen(_ bannerView: BannerView) {
    print("Banner ad will present screen.")
  }

  func bannerViewWillDismissScreen(_ bannerView: BannerView) {
    print("Banner ad will dismiss screen.")
  }

  func bannerViewDidDismissScreen(_ bannerView: BannerView) {
    print("Banner ad did dismiss screen.")
  }
  // [END ad_events]
}
