import Foundation
import SwiftUI

enum MenuItem: String, Identifiable {
  var id: Self { self }

  case banner = "Banner"
  case interstitial = "Interstitial"
  case native = "Native"
  case rewarded = "Rewarded"
  case rewardedInterstitial = "Rewarded Interstitial"

  var contentView: some View {
    return viewForType()
  }
}

extension MenuItem {
  @ViewBuilder
  private func viewForType() -> some View {
    switch self {
    case .banner:
      BannerContentView(navigationTitle: self.rawValue)
    case .interstitial:
      InterstitialContentView(navigationTitle: self.rawValue)
    case .native:
      NativeContentView(navigationTitle: self.rawValue)
    case .rewarded:
      RewardedContentView(navigationTitle: self.rawValue)
    case .rewardedInterstitial:
      RewardedInterstitialContentView(navigationTitle: self.rawValue)
    }
  }
}
