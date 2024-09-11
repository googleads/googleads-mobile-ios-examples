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
          GoogleMobileAdsConsentManager.shared.presentPrivacyOptionsForm { formError in
            guard let formError else { return }

            formErrorDescription = formError.localizedDescription
            showPrivacyOptionsAlert = true
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

        isMenuItemDisabled = !GoogleMobileAdsConsentManager.shared.canRequestAds
        isPrivacyOptionsButtonDisabled = !GoogleMobileAdsConsentManager.shared
          .isPrivacyOptionsRequired

        GoogleMobileAdsConsentManager.shared.startGoogleMobileAdsSDK()
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
