import Foundation
import GoogleMobileAds
import UserMessagingPlatform

class GoogleMobileAdsConsentManager: NSObject {
  static let shared = GoogleMobileAdsConsentManager()

  // The UMP SDK consent form.
  private var form: UMPConsentForm?

  var canRequestAds: Bool {
    return UMPConsentInformation.sharedInstance.consentStatus == .notRequired
      || UMPConsentInformation.sharedInstance.consentStatus == .obtained
  }

  func gatherConsent(
    from consentFormPresentationviewController: UIViewController,
    consentGatheringComplete: @escaping (Error?) -> Void
  ) {
    // The Google Mobile Ads SDK provides the User Messaging Platform (Google's
    // IAB Certified consent management platform) as one solution to capture
    // consent for users in GDPR impacted countries. This is an example and
    // you can choose another consent management platform to capture consent.

    let parameters = UMPRequestParameters()
    // For testing purposes, you can force a UMPDebugGeography of EEA or notEEA.
    // let debugSettings = UMPDebugSettings()
    // debugSettings.geography = UMPDebugGeography.EEA
    // parameters.debugSettings = debugSettings

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
        guard loadAndPresentError == nil else {
          return consentGatheringComplete(loadAndPresentError)
        }

        // Consent has been gathered.
        consentGatheringComplete(nil)

        // Your app needs to allow the user to change their consent status at any time. Load
        // another form and store it so it's ready to be displayed immediately after the user
        // clicks your app's privacy settings button.
        self.loadRevocationFormIfRequired()
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

  private func loadRevocationFormIfRequired() {
    // No revocation form needed if consent form is not available.
    guard UMPConsentInformation.sharedInstance.formStatus == .available else { return }

    UMPConsentForm.load { [weak self] form, loadError in
      guard let self else { return }
      guard loadError == nil else {
        // See UMPFormErrorCode for more info.
        return print("Error: \(loadError!.localizedDescription)")
      }

      self.form = form
    }
  }

  func presentRevocationForm(
    from viewController: UIViewController, completionHandler: @escaping (Error?) -> Void
  ) {
    defer {
      // Your app needs to allow the user to change their consent status at any time. Load
      // another form and store it so it's ready to be displayed immediately after the user
      // clicks your app's privacy settings button.
      loadRevocationFormIfRequired()
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
