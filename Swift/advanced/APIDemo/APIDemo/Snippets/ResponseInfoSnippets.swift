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

private class ResponseInfoSnippets {

  // [START get_ad_source_name]
  func uniqueAdSourceName(for loadedAdNetworkResponseInfo: AdNetworkResponseInfo) -> String {
    var adSourceName: String = loadedAdNetworkResponseInfo.adSourceName ?? ""
    if adSourceName == "Custom Event" {
      if loadedAdNetworkResponseInfo.adNetworkClassName
        == "MediationExample.SampleCustomEventSwift"
      {
        adSourceName = "Sample Ad Network (Custom Event)"
      }
    }
    return adSourceName
  }
  // [END get_ad_source_name]

  private func getMediationAdapterClassNameFromAd(ad: BannerView) {
    // [START get_adapter_class_name]
    print(
      "Adapter class name: \(ad.responseInfo?.loadedAdNetworkResponseInfo?.adNetworkClassName ?? "Unknown")"
    )
    // [END get_adapter_class_name]
  }
}
