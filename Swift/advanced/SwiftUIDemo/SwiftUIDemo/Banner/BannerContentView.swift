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
  @State private var viewWidth: CGFloat = .zero
  private let bannerView = GADBannerView()
  private let adUnitID = "ca-app-pub-3940256099942544/2435281174"

  func makeUIViewController(context: Context) -> some UIViewController {
    let bannerViewController = BannerViewController()
    bannerView.adUnitID = adUnitID
    bannerView.rootViewController = bannerViewController
    bannerView.delegate = context.coordinator
    bannerView.translatesAutoresizingMaskIntoConstraints = false
    bannerViewController.view.addSubview(bannerView)
    // Constrain GADBannerView to the bottom of the view.
    NSLayoutConstraint.activate([
      bannerView.bottomAnchor.constraint(
        equalTo: bannerViewController.view.safeAreaLayoutGuide.bottomAnchor),
      bannerView.centerXAnchor.constraint(equalTo: bannerViewController.view.centerXAnchor),
    ])
    bannerViewController.delegate = context.coordinator

    return bannerViewController
  }

  func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    guard viewWidth != .zero else { return }

    bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
    bannerView.load(GADRequest())
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  fileprivate class Coordinator: NSObject, BannerViewControllerWidthDelegate, GADBannerViewDelegate
  {
    let parent: BannerView

    init(_ parent: BannerView) {
      self.parent = parent
    }

    // MARK: - BannerViewControllerWidthDelegate methods

    func bannerViewController(
      _ bannerViewController: BannerViewController, didUpdate width: CGFloat
    ) {
      parent.viewWidth = width
    }

    // MARK: - GADBannerViewDelegate methods

    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
      print("DID RECEIVE AD")
    }

    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
      print("DID NOT RECEIVE AD: \(error.localizedDescription)")
    }
  }
}

protocol BannerViewControllerWidthDelegate: AnyObject {
  func bannerViewController(_ bannerViewController: BannerViewController, didUpdate width: CGFloat)
}

class BannerViewController: UIViewController {

  weak var delegate: BannerViewControllerWidthDelegate?

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    delegate?.bannerViewController(
      self, didUpdate: view.frame.inset(by: view.safeAreaInsets).size.width)
  }

  override func viewWillTransition(
    to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator
  ) {
    coordinator.animate { _ in
      // do nothing
    } completion: { _ in
      self.delegate?.bannerViewController(
        self, didUpdate: self.view.frame.inset(by: self.view.safeAreaInsets).size.width)
    }
  }
}
