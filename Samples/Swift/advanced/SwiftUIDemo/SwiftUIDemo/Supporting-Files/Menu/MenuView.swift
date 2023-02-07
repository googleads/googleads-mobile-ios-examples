import SwiftUI

struct MenuView: View {
  private let items: [MenuItem] = [
    .banner,
    .interstitial,
    .native,
    .rewarded,
    .rewardedInterstitial,
  ]

  var body: some View {
    NavigationView {
      List(items) { item in
        NavigationLink(destination: item.contentView) {
          Text(item.rawValue)
        }
      }
      .navigationTitle("Menu")
    }
  }
}

struct MenuView_Previews: PreviewProvider {
  static var previews: some View {
    MenuView()
  }
}
