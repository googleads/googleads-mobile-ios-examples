//
//  Copyright 2021 Google LLC
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import GoogleMobileAds
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GADFullScreenContentDelegate {

  var window: UIWindow?
  var appOpenAd: GADAppOpenAd?
  var isLoadingAd = false
  var isShowingAd = false
  /// Keeps track of the time an app open ad is loaded to ensure you don't show an expired ad.
  var loadTime = Date()

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // Initialize Google Mobile Ads SDK
    GADMobileAds.sharedInstance().start(completionHandler: nil)
    return true
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    if let currentVC = application.keyWindow?.rootViewController {
      // Show the ad (if available) when the app moves from the inactive to active state.
      showAdIfAvailable(viewController: currentVC)
    }
  }

  func loadAd() {
    // Do not load ad if there is an unused ad or one is already loading.
    if isLoadingAd || isAdAvailable() {
      return
    }
    isLoadingAd = true
    print("Start loading ad.")
    GADAppOpenAd.load(
      withAdUnitID: "ca-app-pub-3940256099942544/5662855259",
      request: GADRequest(),
      orientation: UIInterfaceOrientation.portrait
    ) { ad, error in
      if let error = error {
        self.isLoadingAd = false
        print("App open ad failed to load with error: \(error.localizedDescription).")
        return
      }

      self.appOpenAd = ad
      self.appOpenAd?.fullScreenContentDelegate = self
      self.isLoadingAd = false
      self.loadTime = Date()
      print("Loading Succeeded.")
    }
  }

  func wasLoadTimeLessThanNHoursAgo(numHours: Int) -> Bool {
    // Check if ad was loaded more than n hours ago.
    let timeIntervalBetweenNowAndLoadTime = Date().timeIntervalSince(loadTime)
    let secondsPerHour = 3600.0
    let intervalInHours = timeIntervalBetweenNowAndLoadTime / secondsPerHour
    return intervalInHours < Double(numHours)
  }

  func isAdAvailable() -> Bool {
    // Check if ad exists and can be shown.
    // Ad references in the app open beta will time out after four hours, but this time limit
    // may change in future beta versions. For details, see:
    // https://support.google.com/admob/answer/9341964?hl=en
    return appOpenAd != nil && wasLoadTimeLessThanNHoursAgo(numHours: 4)
  }

  func showAdIfAvailable(viewController: UIViewController) {
    // If the app open ad is already showing, do not show the ad again.
    if isShowingAd {
      print("The app open ad is already showing.")
      return
    }
    // If the app open ad is not available yet, invoke the callback then load the ad.
    if !isAdAvailable() {
      print("The app open ad is not ready yet.")
      loadAd()
      return
    }
    if let ad = appOpenAd {
      print("Will show ad.")
      isShowingAd = true
      ad.present(fromRootViewController: viewController)
    }
  }

  // MARK: GADFullScreenContentDelegate
  func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
    print("App open ad presented.")
  }

  func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
    appOpenAd = nil
    isShowingAd = false
    print("App open ad dismissed.")
    loadAd()
  }

  func ad(
    _ ad: GADFullScreenPresentingAd,
    didFailToPresentFullScreenContentWithError error: Error
  ) {
    appOpenAd = nil
    isShowingAd = false
    print("App open ad failed to present with error: \(error.localizedDescription).")
    loadAd()
  }

}
