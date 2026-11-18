import Foundation
import GoogleMobileAds
import UIKit
import XCTest

final class InlineAdaptiveBannerViewModelTests: XCTestCase {
  func testLoadItems_ignoresNonPositiveWidth() {
    let viewModel = InlineAdaptiveBannerViewModel(bundle: Bundle(for: Self.self))

    viewModel.loadItems(width: 0)
    XCTAssertTrue(viewModel.listItems.isEmpty)

    viewModel.loadItems(width: -120)
    XCTAssertTrue(viewModel.listItems.isEmpty)
  }

  func testLoadItems_withMissingMenuJSON_leavesListEmpty() {
    let viewModel = InlineAdaptiveBannerViewModel(bundle: Bundle(for: XCTestCase.self))

    viewModel.loadItems(width: 320)

    XCTAssertTrue(viewModel.listItems.isEmpty)
    XCTAssertTrue(viewModel.adSizes.isEmpty)
  }

  func testLoadItems_populatesMenuItemsAndInterleavesAds() {
    let viewModel = InlineAdaptiveBannerViewModel(bundle: Bundle(for: Self.self))

    viewModel.loadItems(width: 320)
    let initialCount = viewModel.listItems.count
    XCTAssertGreaterThan(initialCount, 0)

    let hasAd = viewModel.listItems.contains { item in
      if case .ad = item { return true }
      return false
    }
    XCTAssertTrue(hasAd)

    // Width change within threshold (1 pt) should not reload.
    let firstID = viewModel.listItems.first?.id
    viewModel.loadItems(width: 320.5)
    XCTAssertEqual(viewModel.listItems.first?.id, firstID)
  }

  func testSizeForBannerView_defaultsToZeroAndUpdatesOnDelegateCallbacks() {
    let viewModel = InlineAdaptiveBannerViewModel(bundle: Bundle(for: Self.self))
    let bannerView = AdManagerBannerView(adSize: AdSizeBanner)

    XCTAssertEqual(viewModel.size(for: bannerView), .zero)

    viewModel.bannerViewDidReceiveAd(bannerView)
    XCTAssertEqual(viewModel.size(for: bannerView), cgSize(for: AdSizeBanner))

    viewModel.adView(bannerView, willChangeAdSizeTo: AdSizeLargeBanner)
    XCTAssertEqual(viewModel.size(for: bannerView), cgSize(for: AdSizeLargeBanner))

    let error = NSError(domain: "TestError", code: 1)
    viewModel.bannerView(bannerView, didFailToReceiveAdWithError: error)
    XCTAssertEqual(viewModel.size(for: bannerView), cgSize(for: AdSizeLargeBanner))
  }

  func testListItemID_producesDistinctIdentifiersForMenuItemsAndAds() {
    let menuItem = RestaurantMenuItem(
      name: "Burger",
      description: "Grilled patty",
      price: "$10",
      category: "Mains",
      photo: "burger"
    )
    let bannerView = AdManagerBannerView(adSize: AdSizeBanner)

    let menuListItem = ListItem.menuItem(menuItem)
    let adListItem = ListItem.ad(bannerView)

    XCTAssertNotEqual(menuListItem.id, adListItem.id)
    XCTAssertEqual(menuListItem.id, .menuItem(menuItem.id))
    XCTAssertEqual(adListItem.id, .ad(ObjectIdentifier(bannerView)))
  }
}
