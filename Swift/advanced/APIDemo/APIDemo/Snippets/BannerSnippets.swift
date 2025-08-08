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

  var bannerView: BannerView!

  override func viewDidLoad() {
    super.viewDidLoad()
    createBannerViewProgrammatically()
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
    // [START create_banner_view]
    // Initialize the BannerView.
    bannerView = BannerView()

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
    // [END create_banner_view]
  }
}
