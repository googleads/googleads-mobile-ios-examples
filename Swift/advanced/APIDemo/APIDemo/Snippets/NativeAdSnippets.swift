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

class NativeAdSnippets: UIViewController {

  private let nativeAdUnitID = "ca-app-pub-3940256099942544/3986624511"
  private var adLoader: AdLoader!

  override func viewDidLoad() {
    super.viewDidLoad()
    setNativeAdLoader()
  }

  private func setNativeAdLoader() {
    // [START set_ad_loader]
    adLoader = AdLoader(
      adUnitID: nativeAdUnitID,
      // The UIViewController parameter is optional.
      rootViewController: self,
      // To receive native ads, the ad loader's delegate must
      // conform to the NativeAdLoaderDelegate protocol.
      adTypes: [.native],
      // Use nil for default options.
      options: nil)
    // Set the delegate before making an ad request.
    adLoader.delegate = self
    // [END set_ad_loader]
  }

  /// Loads an AdMob native ad.
  private func loadAdMobNativeAd() {
    // [START load_ad]
    adLoader.load(Request())
    // [END load_ad]
  }

  /// Loads an Ad Manager native ad.
  private func loadAdManagerNativeAd() {
    // [START load_admanager_ad]
    adLoader.load(AdManagerRequest())
    // [END load_admanager_ad]
  }

  private func loadMultipleNativeAds() {
    // [START load_multiple_ads]
    let multipleAdOptions = MultipleAdsAdLoaderOptions()
    multipleAdOptions.numberOfAds = 5
    adLoader = AdLoader(
      adUnitID: nativeAdUnitID,
      // The UIViewController parameter is optional.
      rootViewController: self,
      adTypes: [.native],
      options: [multipleAdOptions])
    // [END load_multiple_ads]
  }

  private func setContentMode(_ nativeAdView: NativeAdView, for ad: NativeAd) {
    // [START set_content_mode]
    nativeAdView.mediaView?.contentMode = .scaleAspectFit
    // [END set_content_mode]
  }
}

extension NativeAdSnippets: NativeAdLoaderDelegate {
  // [START ad_loader_did_receive_ad]
  func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
    // Set the delegate to receive notifications for interactions with the native ad.
    // [START set_native_ad_delegate]
    nativeAd.delegate = self
    // [END set_native_ad_delegate]

    // TODO: Display the native ad.
  }
  // [END ad_loader_did_receive_ad]

  // [START ad_loader_did_finish_loading]
  func adLoaderDidFinishLoading(_ adLoader: AdLoader) {
    // The adLoader has finished loading ads.
  }
  // [END ad_loader_did_finish_loading]

  // [START ad_loader_failed]
  func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: any Error) {
    // The adLoader failed to receive an ad.
  }
  // [END ad_loader_failed]
}

extension NativeAdSnippets: CustomNativeAdLoaderDelegate {

  // [START ad_loader_did_receive_custom_ad]
  func adLoader(_ adLoader: AdLoader, didReceive customNativeAd: CustomNativeAd) {
    // To be notified of events related to the custom native ad interactions, set the delegate
    // property of the native ad
    customNativeAd.delegate = self

    // TODO: Display the custom native ad.
  }
  // [END ad_loader_did_receive_custom_ad]

  func customNativeAdFormatIDs(for adLoader: AdLoader) -> [String] {
    // Your list of custom native ad format IDs for the ad loader.
    return []
  }
}

extension NativeAdSnippets: NativeAdDelegate {

  // [START native_ad_delegate_methods]
  func nativeAdDidRecordImpression(_ nativeAd: NativeAd) {
    // The native ad was shown.
  }

  func nativeAdDidRecordClick(_ nativeAd: NativeAd) {
    // The native ad was clicked on.
  }

  func nativeAdWillPresentScreen(_ nativeAd: NativeAd) {
    // The native ad will present a full screen view.
  }

  func nativeAdWillDismissScreen(_ nativeAd: NativeAd) {
    // The native ad will dismiss a full screen view.
  }

  func nativeAdDidDismissScreen(_ nativeAd: NativeAd) {
    // The native ad did dismiss a full screen view.
  }

  func nativeAdWillLeaveApplication(_ nativeAd: NativeAd) {
    // The native ad will cause the app to become inactive and
    // open a new app.
  }
  // [END native_ad_delegate_methods]
}

extension NativeAdSnippets: CustomNativeAdDelegate {
  func customNativeAdDidRecordImpression(_ nativeAd: CustomNativeAd) {
    // The custom native ad was shown.
  }

  func customNativeAdDidRecordClick(_ nativeAd: CustomNativeAd) {
    // The custom native ad was clicked on.
  }

  func customNativeAdWillDismissScreen(_ nativeAd: CustomNativeAd) {
    // The custom native ad will dismiss a full screen view.
  }

  func customNativeAdDidDismissScreen(_ nativeAd: CustomNativeAd) {
    // The custom native ad did dismiss a full screen view.
  }

  func customNativeAdWillPresentScreen(_ nativeAd: CustomNativeAd) {
    // The custom native ad will cause the app to become inactive and
    // open a new app.
  }
}
