//
//  Copyright 2026 Google LLC
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

/// An item displayed in the inline adaptive banner list.
enum ListItem: Identifiable {
  case menuItem(RestaurantMenuItem)
  case ad(AdManagerBannerView)

  var id: AnyHashable {
    switch self {
    case .menuItem(let item):
      return item.id
    case .ad(let bannerView):
      return ObjectIdentifier(bannerView)
    }
  }
}

/// Manages the menu items and preloaded inline adaptive banner ads for a scrollable list.
final class InlineAdaptiveBannerViewModel: NSObject, ObservableObject {
  @Published private(set) var listItems = [ListItem]()
  @Published private(set) var adSizes = [ObjectIdentifier: CGSize]()

  private var adsToLoad = [AdManagerBannerView]()
  private var loadedWidth: CGFloat = 0
  private let adUnitID = "/21775744923/example/adaptive-banner"
  private let adInterval = 4

  /// Populates the list items and starts preloading banner ads sequentially for the given width.
  func loadItems(width: CGFloat) {
    guard width > 0, abs(width - loadedWidth) > 1 else { return }
    loadedWidth = width

    listItems.removeAll()
    adsToLoad.removeAll()
    adSizes.removeAll()

    addMenuItems()
    addBannerAds(width: width)
    preloadNextAd()
  }

  /// Returns the loaded size for the given banner view, or `.zero` if it hasn't loaded yet.
  func size(for bannerView: AdManagerBannerView) -> CGSize {
    return adSizes[ObjectIdentifier(bannerView)] ?? .zero
  }

  /// Adds restaurant menu items from `menuItemsJSON.json` to `listItems`.
  private func addMenuItems() {
    guard let url = Bundle.main.url(forResource: "menuItemsJSON", withExtension: "json") else {
      print("Invalid filename for JSON menu item data.")
      return
    }

    do {
      let data = try Data(contentsOf: url)
      let items = try JSONDecoder().decode([RestaurantMenuItem].self, from: data)
      listItems = items.map { .menuItem($0) }
    } catch {
      print("Failed to load menu item JSON data: \(error.localizedDescription)")
    }
  }

  /// Inserts `AdManagerBannerView` instances into `listItems` at each `adInterval`.
  private func addBannerAds(width: CGFloat) {
    var index = adInterval
    let inlineAdSize = currentOrientationInlineAdaptiveBanner(width: width)

    while index < listItems.count {
      let adView = AdManagerBannerView(adSize: inlineAdSize)
      adView.adUnitID = adUnitID
      adView.delegate = self
      adView.adSizeDelegate = self

      adView.validAdSizes = [nsValue(for: inlineAdSize)]

      listItems.insert(.ad(adView), at: index)
      adsToLoad.append(adView)
      index += adInterval
    }
  }

  /// Preloads banner ads sequentially by dequeuing and loading the next ad from `adsToLoad`.
  func preloadNextAd() {
    guard !adsToLoad.isEmpty else { return }
    let ad = adsToLoad.removeFirst()
    ad.load(AdManagerRequest())
  }
}

// MARK: - BannerViewDelegate

extension InlineAdaptiveBannerViewModel: BannerViewDelegate {
  func bannerViewDidReceiveAd(_ bannerView: BannerView) {
    adSizes[ObjectIdentifier(bannerView)] = cgSize(for: bannerView.adSize)
    preloadNextAd()
  }

  func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
    print("Failed to receive ad: \(error.localizedDescription)")
    preloadNextAd()
  }
}

// MARK: - AdSizeDelegate

extension InlineAdaptiveBannerViewModel: AdSizeDelegate {
  func adView(_ bannerView: BannerView, willChangeAdSizeTo size: AdSize) {
    adSizes[ObjectIdentifier(bannerView)] = cgSize(for: size)
  }
}
