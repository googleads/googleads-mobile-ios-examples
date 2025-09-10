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
    // Replace REQUEST_TYPE with your request type.
    let signalRequest = NativeSignalRequest(signalType: "REQUEST_TYPE")
    signalRequest.requestAgent = "request_agent"
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
    // Replace REQUEST_TYPE with your request type.
    let signalRequest = BannerSignalRequest(signalType: "REQUEST_TYPE")
    signalRequest.requestAgent = "request_agent"
    signalRequest.adUnitID = adUnitID
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

  func loadNativePlusBanner(adUnitID: String) {
    // [START signal_request_native_plus_banner]
    // Create a signal request for an ad.
    // Replace REQUEST_TYPE with your request type.
    let signalRequest = NativeSignalRequest(signalType: "REQUEST_TYPE")
    signalRequest.requestAgent = "request_agent"
    signalRequest.adUnitID = adUnitID
    signalRequest.adLoaderAdTypes = [AdLoaderAdType.native, AdLoaderAdType.adManagerBanner]
    signalRequest.adSizes = [nsValue(for: portraitInlineAdaptiveBanner(width: 320))]

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
    // [END signal_request_native_plus_banner]
  }
}
