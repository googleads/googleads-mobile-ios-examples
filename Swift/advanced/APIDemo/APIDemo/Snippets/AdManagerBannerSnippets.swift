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

private class AdManagerBannerSnippets: UIViewController, AppEventDelegate, BannerViewDelegate {

  let testAdUnitID = "/21775744923/example/adaptive-banner"
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
    // [END create_admanager_banner_view]
  }

  private func loadInlineAdaptiveBanner() {
    // [START set_inline_adaptive_ad_size]
    // Make sure the ad fits inside the readable area.
    let adWidth = view.bounds.inset(by: view.safeAreaInsets).width
    bannerView.adSize = currentOrientationInlineAdaptiveBanner(width: adWidth)
    // [END set_inline_adaptive_ad_size]

    // Test ad unit ID for inline adaptive banners.
    bannerView.adUnitID = testAdUnitID
    bannerView.load(AdManagerRequest())
  }

  private func enableManualImpressionCountingForBannerView() {
    // [START enable_manual_impression_counting]
    bannerView.enableManualImpressions = true
    // [END enable_manual_impression_counting]
  }

  private func recordManualImpression() {
    // [START record_manual_impression]
    bannerView.recordImpression()
    // [END record_manual_impression]
  }

  private func setAppEventListener() {
    // [START set_app_event_listener]
    // Set this property before making the request for an ad.
    bannerView.appEventDelegate = self
    // [END set_app_event_listener]
  }

  // [START app_events]
  func bannerView(
    _ banner: AdManagerBannerView, didReceiveAppEvent name: String, withInfo info: String?
  ) {
    if name == "color" {
      if info == "green" {
        // Set background color to green.
        view.backgroundColor = UIColor.green
      } else if info == "blue" {
        // Set background color to blue.
        view.backgroundColor = UIColor.blue
      } else {
        // Set background color to black.
        view.backgroundColor = UIColor.black
      }
    }
  }
  // [END app_events]

  // [START load_ad]
  func loadBannerAd(bannerView: AdManagerBannerView) {
    // [START ad_size]
    // Request a large anchored adaptive banner with a width of 375.
    bannerView.adSize = largeAnchoredAdaptiveBanner(width: 375)
    // [END ad_size]
    bannerView.load(AdManagerRequest())
  }
  // [END load_ad]

  // [START ad_events]
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
