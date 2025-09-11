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

class AdmobSCARSnippets: NSObject {

  func loadNative(adUnitID: String) {
    // [START signal_request_native]
    // Create a signal request for an ad.
    // Contact your account manager for your assigned signal type.
    let signalRequest = NativeSignalRequest(signalType: "SIGNAL_TYPE")
    signalRequest.requestAgent = "REQUEST_AGENT"
    signalRequest.adUnitID = adUnitID

    MobileAds.generateSignal(signalRequest) { [weak self] signal, error in
      guard self != nil else { return }

      if let error = error {
        print("Error getting ad info: \(error.localizedDescription)")
        return
      }

      guard let signal = signal else {
        print("Unexpected error - signal info is nil.")
        return
      }

      print("Signal string: \(signal.signal)")
      // TODO: Fetch the ad response using your generated signal.
    }
    // [END signal_request_native]
  }

  func loadBanner(adUnitID: String) {
    // [START signal_request_banner]
    // Create a signal request for an ad.
    // Contact your account manager for your assigned signal type.
    let signalRequest = BannerSignalRequest(signalType: "SIGNAL_TYPE")
    signalRequest.requestAgent = "REQUEST_AGENT"
    signalRequest.adUnitID = adUnitID
    // Refer to the AdSize class for available ad sizes.
    signalRequest.adSize = portraitInlineAdaptiveBanner(width: 320)

    MobileAds.generateSignal(signalRequest) { [weak self] signal, error in
      guard self != nil else { return }

      if let error = error {
        print("Error getting ad info: \(error.localizedDescription)")
        return
      }

      guard let signal = signal else {
        print("Unexpected error - signal info is nil.")
        return
      }

      print("Signal string: \(signal.signal)")
      // TODO: Fetch the ad response using your generated signal.
    }
    // [END signal_request_banner]
  }

}
