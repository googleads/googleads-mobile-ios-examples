//
//  Copyright 2023 Google LLC
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

import Foundation
import GoogleMobileAds
import UserMessagingPlatform

/// The Google Mobile Ads SDK provides the User Messaging Platform (Google's
/// IAB Certified consent management platform) as one solution to capture
/// consent for users in GDPR impacted countries. This is an example and
/// you can choose another consent management platform to capture consent.

class GoogleMobileAdsConsentManager: NSObject {
  static let shared = GoogleMobileAdsConsentManager()

  var canRequestAds: Bool {
    return UMPConsentInformation.sharedInstance.canRequestAds
  }

  var isPrivacyOptionsRequired: Bool {
    return UMPConsentInformation.sharedInstance.privacyOptionsRequirementStatus == .required
  }

  /// Helper method to call the UMP SDK methods to request consent information and load/present a
  /// consent form if necessary.
  func gatherConsent(
    from consentFormPresentationviewController: UIViewController,
    consentGatheringComplete: @escaping (Error?) -> Void
  ) {
    let parameters = UMPRequestParameters()

    //For testing purposes, you can force a UMPDebugGeography of EEA or not EEA.
    let debugSettings = UMPDebugSettings()
    // debugSettings.geography = UMPDebugGeography.EEA
    parameters.debugSettings = debugSettings

    // Requesting an update to consent information should be called on every app launch.
    UMPConsentInformation.sharedInstance.requestConsentInfoUpdate(with: parameters) {
      requestConsentError in
      guard requestConsentError == nil else {
        return consentGatheringComplete(requestConsentError)
      }

      UMPConsentForm.loadAndPresentIfRequired(from: consentFormPresentationviewController) {
        loadAndPresentError in

        // Consent has been gathered.
        consentGatheringComplete(loadAndPresentError)
      }
    }
  }

  /// Helper method to call the UMP SDK method to present the privacy options form.
  func presentPrivacyOptionsForm(
    from viewController: UIViewController, completionHandler: @escaping (Error?) -> Void
  ) {
    UMPConsentForm.presentPrivacyOptionsForm(
      from: viewController, completionHandler: completionHandler)
  }
}
