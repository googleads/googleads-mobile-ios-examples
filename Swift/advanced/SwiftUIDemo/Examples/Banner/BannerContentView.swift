import GoogleMobileAds
import SwiftUI

struct BannerContentView: View {
  let navigationTitle: String

  var body: some View {
    BannerView()
      .navigationTitle(navigationTitle)
  }
}

struct BannerContentView_Previews: PreviewProvider {
  static var previews: some View {
    BannerContentView(navigationTitle: "Banner")
  }
}

private struct BannerView: UIViewControllerRepresentable {
  @StateObject private var bannerViewController = BannerViewController()
  private let bannerView = GADBannerView()
  private let adUnitID = "ca-app-pub-3940256099942544/2435281174"

  func makeUIViewController(context: Context) -> some UIViewController {
    bannerView.adUnitID = adUnitID
    bannerView.rootViewController = bannerViewController
    bannerViewController.view.addSubview(bannerView)
    bannerView.delegate = context.coordinator

    return bannerViewController
  }

  func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    guard let viewWidth = bannerViewController.viewWidth else { return }

    bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
    bannerView.load(GADRequest())
  }

  func makeCoordinator() -> Coordinator {
    Coordinator()
  }

  fileprivate class Coordinator: NSObject, GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
      print("DID RECEIVE AD")
    }

    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
      print("DID NOT RECEIVE AD: \(error.localizedDescription)")
    }
  }
}

private class BannerViewController: UIViewController, ObservableObject {
  @Published var viewWidth: CGFloat?

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    viewWidth = view.frame.inset(by: view.safeAreaInsets).size.width
  }

  override func viewWillTransition(
    to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator
  ) {
    coordinator.animate { _ in
      // do nothing
    } completion: { _ in
      self.viewWidth = self.view.frame.inset(by: self.view.safeAreaInsets).size.width
    }
  }
}
