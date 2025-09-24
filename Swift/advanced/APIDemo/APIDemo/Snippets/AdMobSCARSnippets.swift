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
import UIKit

class AdMobSCARSnippets: NSObject {

  // [START signal_request_native]
  func loadNative(adUnitID: String) async {
    // Create a signal request for an ad.
    let signalRequest = NativeSignalRequest(signalType: "SIGNAL_TYPE")
    signalRequest.requestAgent = "REQUEST_AGENT"
    signalRequest.adUnitID = adUnitID

    do {
      let signal = try await MobileAds.generateSignal(signalRequest)
      print("Signal string: \(signal.signal)")
      // TODO: Fetch the ad response using your generated signal.
    } catch {
      print("Error getting ad info: \(error.localizedDescription)")
    }
  }
  // [END signal_request_native]

  // [START signal_request_banner]
  func loadBanner(adUnitID: String) async {
    // Create a signal request for an ad.
    let signalRequest = BannerSignalRequest(signalType: "SIGNAL_TYPE")
    signalRequest.requestAgent = "REQUEST_AGENT"
    signalRequest.adUnitID = adUnitID
    // Refer to the AdSize class for available ad sizes.
    signalRequest.adSize = currentOrientationInlineAdaptiveBanner(width: 375)

    do {
      let signal = try await MobileAds.generateSignal(signalRequest)
      print("Signal string: \(signal.signal)")
      // TODO: Fetch the ad response using your generated signal.
    } catch {
      print("Error getting ad info: \(error.localizedDescription)")
    }
  }
  // [END signal_request_banner]

}
