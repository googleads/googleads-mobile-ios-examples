//
//  Copyright (C) 2015 Google LLC
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

  // The UMP SDK consent form.
  private var form: UMPConsentForm?

  var canRequestAds: Bool {
    return UMPConsentInformation.sharedInstance.consentStatus == .notRequired
      || UMPConsentInformation.sharedInstance.consentStatus == .obtained
  }

  var isFormAvailable: Bool {
    return UMPConsentInformation.sharedInstance.formStatus == .available
  }

  /// Helper method to call the UMP SDK methods to request consent information and load/present a
  /// consent form if necessary.
  ///
  /// - Parameter viewController: The view controller to present the user consent form on screen.
  /// - Parameter completionHandler: The block to execute after consent gathering finishes.
  func gatherConsent(
    from consentFormPresentationviewController: UIViewController,
    consentGatheringComplete: @escaping (Error?) -> Void
  ) {
    let parameters = UMPRequestParameters()

    //For testing purposes, you can force a UMPDebugGeography of EEA or not EEA.
    let debugSettings = UMPDebugSettings()
    //debugSettings.geography = UMPDebugGeography.EEA
    parameters.debugSettings = debugSettings

    // Requesting an update to consent information should be called on every app launch.
    UMPConsentInformation.sharedInstance.requestConsentInfoUpdate(with: parameters) {
      [weak self] requestConsentError in
      guard let self else { return }
      guard requestConsentError == nil else {
        return consentGatheringComplete(requestConsentError)
      }

      self.loadAndPresentFormFromViewControllerIfRequired(
        from: consentFormPresentationviewController
      ) {
        [weak self] loadAndPresentError in
        guard let self else { return }

        // Consent has been gathered.
        consentGatheringComplete(loadAndPresentError)

        // Your app needs to allow the user to change their consent status at any time. Load
        // another form and store it so it's ready to be displayed immediately after the user
        // clicks your app's privacy settings button.
        self.loadPrivacyOptionsFormIfRequired()
      }
    }
  }

  private func loadAndPresentFormFromViewControllerIfRequired(
    from viewController: UIViewController, completionHandler: @escaping (Error?) -> Void
  ) {
    // Determine the consent-related action to take based on the UMPConsentStatus.
    guard
      UMPConsentInformation.sharedInstance.consentStatus == .required
        || UMPConsentInformation.sharedInstance.consentStatus == .unknown
    else {
      // Consent has already been gathered or not required.
      return completionHandler(nil)
    }

    UMPConsentForm.load { form, loadError in
      guard loadError == nil else {
        return completionHandler(loadError)
      }

      form?.present(
        from: viewController,
        completionHandler: { formError in
          completionHandler(formError)
        })
    }
  }

  private func loadPrivacyOptionsFormIfRequired() {
    // No privacy options form needed if consent form is not available.
    guard isFormAvailable else { return }

    UMPConsentForm.load { [weak self] form, loadError in
      guard let self else { return }
      guard loadError == nil else {
        // See UMPFormErrorCode for more info.
        return print("Error: \(loadError!.localizedDescription)")
      }

      self.form = form
    }
  }

  /// Helper method to call the UMP SDK method to present the privacy options form.
  ///
  /// Attempts to load a new privacy options form upon completion.
  ///
  /// - Parameter viewController: The view controller to present the privacy options form on screen.
  /// - Parameter completionHandler: The block to execute after the presentation finishes.
  func presentPrivacyOptionsForm(
    from viewController: UIViewController, completionHandler: @escaping (Error?) -> Void
  ) {
    defer {
      // Your app needs to allow the user to change their consent status at any time. Load
      // another form and store it so it's ready to be displayed immediately after the user
      // clicks your app's privacy settings button.
      loadPrivacyOptionsFormIfRequired()
    }

    guard let form = form else {
      return completionHandler(
        NSError(
          domain: "@com.google",
          code: 0,
          userInfo: [NSLocalizedDescriptionKey: "No form available."]
        )
      )
    }

    form.present(
      from: viewController,
      completionHandler: { formError in
        completionHandler(formError)
      })
  }
}
