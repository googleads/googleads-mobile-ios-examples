import SwiftUI

struct MenuView: View {
  private let items: [MenuItem] = [
    .banner,
    .interstitial,
    .native,
    .rewarded,
    .rewardedInterstitial,
  ]

  @State private var isMenuItemDisabled = true
  @State private var isPrivacyOptionsButtonDisabled = true
  @State private var showPrivacyOptionsAlert = false
  @State private var formErrorDescription: String?

  var body: some View {
    NavigationView {
      List(items) { item in
        NavigationLink(destination: item.contentView) {
          Text(item.rawValue)
        }
        .disabled(isMenuItemDisabled)
      }
      .navigationTitle("Menu")
      .toolbar {
        Button("Privacy Settings") {
          Task {
            do {
              try await GoogleMobileAdsConsentManager.shared.presentPrivacyOptionsForm()
            } catch {
              formErrorDescription = error.localizedDescription
              showPrivacyOptionsAlert = true
            }
          }
        }
        .disabled(isPrivacyOptionsButtonDisabled)
      }
      .alert(isPresented: $showPrivacyOptionsAlert) {
        Alert(
          title: Text(formErrorDescription ?? "Error"),
          message: Text("Please try again later."))
      }
    }
    .onAppear {
      GoogleMobileAdsConsentManager.shared.gatherConsent { consentError in
        if let consentError {
          // Consent gathering failed.
          print("Error: \(consentError.localizedDescription)")
        }

        // Check if you can request ads in `startGoogleMobileAdsSDK` before initializing the
        // Google Mobile Ads SDK.
        GoogleMobileAdsConsentManager.shared.startGoogleMobileAdsSDK()
        // Update the state of the menu items and privacy options button.
        isMenuItemDisabled = !GoogleMobileAdsConsentManager.shared.canRequestAds
        isPrivacyOptionsButtonDisabled = !GoogleMobileAdsConsentManager.shared
          .isPrivacyOptionsRequired
      }

      // This sample attempts to load ads using consent obtained in the previous session.
      GoogleMobileAdsConsentManager.shared.startGoogleMobileAdsSDK()
    }
  }
}

struct MenuView_Previews: PreviewProvider {
  static var previews: some View {
    MenuView()
  }
}
