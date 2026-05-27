//
//  Copyright 2023 Google LLC
//
//  Licensed under the Apache License, Version 2.0 (the "License")
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
import UIKit

/// AdMob - Collapsible banner ads.
class CollapsibleBannerViewController: UIViewController, BannerViewDelegate {

  /// The collapsible banner ad view.
  let bannerView = BannerView()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(bannerView)
    bannerView.translatesAutoresizingMaskIntoConstraints = false
    // Layout constraints that align the banner view to the bottom center of the screen.
    NSLayoutConstraint.activate([
      bannerView.bottomAnchor.constraint(
        equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      bannerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
    ])

    bannerView.adUnitID = Constants.collapsibleBannerAdUnitID
    bannerView.rootViewController = self
    bannerView.delegate = self
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    // Here safe area is taken into account, hence the view frame is used after the
    // view has been laid out.
    let frame = { () -> CGRect in
      return view.frame.inset(by: view.safeAreaInsets)
    }()
    let viewWidth = frame.size.width
    bannerView.adSize = currentOrientationAnchoredAdaptiveBanner(width: viewWidth)

    loadAd()
  }

  @IBAction func refreshAdTapped(_ sender: AnyObject) {
    loadAd()
  }

  private func loadAd() {
    let request = Request()
    let extras = Extras()

    // Aligns the bottom edge of the overlay with the bottom edge of the collapsed ad.
    extras.additionalParameters = ["collapsible": "bottom"]
    request.register(extras)

    bannerView.load(request)
  }

  func bannerViewDidReceiveAd(_ bannerView: BannerView) {
    print("The last loaded banner is \(bannerView.isCollapsible ? "" : "not") collapsible.")
  }
}
