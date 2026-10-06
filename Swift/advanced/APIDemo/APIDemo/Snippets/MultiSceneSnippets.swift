//
//  Copyright (C) 2026 Google, Inc.
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
import SwiftUI
import UIKit

@MainActor
private class MultiSceneSnippets: UIViewController {

  private var interstitial: InterstitialAd?
  private var adManagerInterstitial: AdManagerInterstitialAd?
  private var requestInitialized = false

  // [START load_interstitial]
  func loadInterstitial() async {
    let request = Request()
    request.scene = view.window?.windowScene

    do {
      interstitial = try await InterstitialAd.load(
        with: "ca-app-pub-3940256099942544/4411468910", request: request)
    } catch {
      print("Failed to load interstitial ad with error: \(error.localizedDescription)")
    }
  }
  // [END load_interstitial]

  // [START load_interstitial_gam]
  func loadAdManagerInterstitial() async {
    let request = AdManagerRequest()
    request.scene = view.window?.windowScene

    do {
      adManagerInterstitial = try await AdManagerInterstitialAd.load(
        with: "/21775744923/example/interstitial", request: request)
    } catch {
      print("Failed to load interstitial ad with error: \(error.localizedDescription)")
    }
  }
  // [END load_interstitial_gam]

  // [START view_did_appear]
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if !requestInitialized {
      Task {
        await loadInterstitial()
      }
      requestInitialized = true
    }
  }
  // [END view_did_appear]

  // [START fullscreen_view_will_transition]
  override func viewWillTransition(
    to size: CGSize,
    with coordinator: UIViewControllerTransitionCoordinator
  ) {
    super.viewWillTransition(to: size, with: coordinator)

    coordinator.animate(alongsideTransition: nil) { [weak self] _ in
      guard let self else { return }
      do {
        try self.interstitial?.canPresent(from: self)
      } catch {
        Task {
          await self.loadInterstitial()
        }
      }
    }
  }
  // [END fullscreen_view_will_transition]
}

@MainActor
private class MultiSceneBannerSnippets: UIViewController {

  private var bannerView: BannerView!

  // [START banner_view_will_transition]
  override func viewWillTransition(
    to size: CGSize,
    with coordinator: UIViewControllerTransitionCoordinator
  ) {
    super.viewWillTransition(to: size, with: coordinator)

    coordinator.animate(alongsideTransition: nil) { [weak self] _ in
      self?.loadBannerAd()
    }
  }

  @MainActor
  func loadBannerAd() {
    let frame = view.frame.inset(by: view.safeAreaInsets)
    let viewWidth = frame.size.width

    bannerView.adSize = largeAnchoredAdaptiveBanner(width: viewWidth)

    let request = Request()
    request.scene = view.window?.windowScene
    bannerView.load(request)
  }
  // [END banner_view_will_transition]
}

@MainActor
private class MultiSceneAdManagerBannerSnippets: UIViewController {

  private var bannerView: AdManagerBannerView!

  // [START banner_view_will_transition_gam]
  override func viewWillTransition(
    to size: CGSize,
    with coordinator: UIViewControllerTransitionCoordinator
  ) {
    super.viewWillTransition(to: size, with: coordinator)

    coordinator.animate(alongsideTransition: nil) { [weak self] _ in
      self?.loadBannerAd()
    }
  }

  @MainActor
  func loadBannerAd() {
    let frame = view.frame.inset(by: view.safeAreaInsets)
    let viewWidth = frame.size.width

    bannerView.adSize = largeAnchoredAdaptiveBanner(width: viewWidth)

    let request = AdManagerRequest()
    request.scene = view.window?.windowScene
    bannerView.load(request)
  }
  // [END banner_view_will_transition_gam]
}

// MARK: - SwiftUI Snippets

@MainActor
private struct MultiSceneSwiftUISnippets {
  // [START configure_scene_swiftui]
  func loadInterstitial() async {
    let request = Request()
    request.scene =
      UIApplication.shared.connectedScenes
      .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene

    do {
      let _ = try await InterstitialAd.load(
        with: "ca-app-pub-3940256099942544/4411468910", request: request)
    } catch {
      print("Failed to load interstitial ad with error: \(error.localizedDescription)")
    }
  }
  // [END configure_scene_swiftui]

  // [START configure_scene_swiftui_gam]
  func loadAdManagerInterstitial() async {
    let request = AdManagerRequest()
    request.scene =
      UIApplication.shared.connectedScenes
      .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene

    do {
      let _ = try await AdManagerInterstitialAd.load(
        with: "/21775744923/example/interstitial", request: request)
    } catch {
      print("Failed to load interstitial ad with error: \(error.localizedDescription)")
    }
  }
  // [END configure_scene_swiftui_gam]
}

// [START banner_view_will_transition_swiftui]
struct MultiSceneBannerView: View {
  var body: some View {
    GeometryReader { geometry in
      let adSize = largeAnchoredAdaptiveBanner(width: geometry.size.width)
      MultiSceneBannerViewContainer(adSize: adSize)
        .frame(width: adSize.size.width, height: adSize.size.height)
    }
  }
}

private struct MultiSceneBannerViewContainer: UIViewRepresentable {
  let adSize: AdSize

  func makeUIView(context: Context) -> BannerView {
    let bannerView = BannerView(adSize: adSize)
    let request = Request()
    request.scene =
      UIApplication.shared.connectedScenes
      .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
    bannerView.load(request)
    return bannerView
  }

  func updateUIView(_ uiView: BannerView, context: Context) {
    if uiView.adSize.size != adSize.size {
      uiView.adSize = adSize
      let request = Request()
      request.scene = uiView.window?.windowScene
      uiView.load(request)
    }
  }
}
// [END banner_view_will_transition_swiftui]

// [START banner_view_will_transition_swiftui_gam]
struct MultiSceneAdManagerBannerView: View {
  var body: some View {
    GeometryReader { geometry in
      let adSize = largeAnchoredAdaptiveBanner(width: geometry.size.width)
      MultiSceneAdManagerBannerViewContainer(adSize: adSize)
        .frame(width: adSize.size.width, height: adSize.size.height)
    }
  }
}

private struct MultiSceneAdManagerBannerViewContainer: UIViewRepresentable {
  let adSize: AdSize

  func makeUIView(context: Context) -> AdManagerBannerView {
    let bannerView = AdManagerBannerView(adSize: adSize)
    let request = AdManagerRequest()
    request.scene =
      UIApplication.shared.connectedScenes
      .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
    bannerView.load(request)
    return bannerView
  }

  func updateUIView(_ uiView: AdManagerBannerView, context: Context) {
    if uiView.adSize.size != adSize.size {
      uiView.adSize = adSize
      let request = AdManagerRequest()
      request.scene = uiView.window?.windowScene
      uiView.load(request)
    }
  }
}
// [END banner_view_will_transition_swiftui_gam]
