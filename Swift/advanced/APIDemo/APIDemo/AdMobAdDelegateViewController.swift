//
//  Copyright (C) 2016 Google, Inc.
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
import UIKit

/// AdMob - Ad Delegate
/// Demonstrates handling GADBannerViewDelegate ad request status and ad click lifecycle messages.
/// This is an AdMob example, so it uses a GADBannerView to show an AdMob ad. GADBannerViewDelegate
/// also works with DFPBannerView objects, so publishers displaying ads from
/// DoubleClick For Publishers (DFP) can also use it with their banners. To see this in action,
/// use the DFPBannerView class instead of GADBannerView.
class AdMobAdDelegateViewController: UIViewController, GADBannerViewDelegate {

  @IBOutlet weak var bannerView: GADBannerView!

  override func viewDidLoad() {
    super.viewDidLoad()
    bannerView.delegate = self
    bannerView.adUnitID = Constants.AdMobAdUnitID
    bannerView.rootViewController = self
    bannerView.loadRequest(GADRequest())
  }

  // MARK: - GADBannerViewDelegate

  // Called when an ad request loaded an ad.
  func adViewDidReceiveAd(bannerView: GADBannerView!) {
    print(#function)
  }

  // Called when an ad request failed.
  func adView(bannerView: GADBannerView!, didFailToReceiveAdWithError error: GADRequestError!) {
    print("\(#function): \(error.localizedDescription)")
  }

  // Called just before presenting the user a full screen view, such as a browser, in response to
  // clicking on an ad.
  func adViewWillPresentScreen(bannerView: GADBannerView!) {
    print(#function)
  }

  // Called just before dismissing a full screen view.
  func adViewWillDismissScreen(bannerView: GADBannerView!) {
    print(#function)
  }

  // Called just after dismissing a full screen view.
  func adViewDidDismissScreen(bannerView: GADBannerView!) {
    print(#function)
  }

  // Called just before the application will background or terminate because the user clicked on an
  // ad that will launch another application (such as the App Store).
  func adViewWillLeaveApplication(bannerView: GADBannerView!) {
    print(#function)
  }

}
