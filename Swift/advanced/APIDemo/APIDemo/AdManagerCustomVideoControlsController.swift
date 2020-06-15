//
//  Copyright (C) 2018 Google, Inc.
//
//  AdManagerCustomVideoControlsController.h
//  APIDemo
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

private let TestAdUnit = "/6499/example/native-video"
private let TestNativeCustomTemplateID = "10104090"

class AdManagerCustomVideoControlsController: UIViewController {
  /// Switch to indicate if video ads should start muted.
  @IBOutlet weak var startMutedSwitch: UISwitch!
  /// Switch to indicate if video ads should request custom controls.
  @IBOutlet weak var requestCustomControlsSwitch: UISwitch!
  /// The placeholder for the native ad view that is being presented.
  @IBOutlet var placeholderView: UIView!
  /// Switch to request app install ads.
  @IBOutlet weak var unifiedNativeAdSwitch: UISwitch!
  /// Switch to custom native ads.
  @IBOutlet weak var customNativeAdSwitch: UISwitch!
  /// View containing information about video and custom controls.
  @IBOutlet weak var customControlsView: CustomControlsView!
  /// Refresh the native ad.
  @IBOutlet weak var refreshButton: UIButton!
  /// The Google Mobile Ads SDK version number label.
  @IBOutlet weak var versionLabel: UILabel!

  /// You must keep a strong reference to the GADAdLoader during the ad loading process.
  var adLoader: GADAdLoader?
  /// The native ad view being presented.
  var nativeAdView: UIView?

  override func viewDidLoad() {
    super.viewDidLoad()
    versionLabel.text = GADRequest.sdkVersion()
    refreshAd(nil)
  }
  @IBAction func refreshAd(_ sender: Any?) {
    // Loads an ad for any of unified native or custom native ads.
    var adTypes = [GADAdLoaderAdType]()
    if unifiedNativeAdSwitch.isOn {
      adTypes.append(.unifiedNative)
    }
    if customNativeAdSwitch.isOn {
      adTypes.append(GADAdLoaderAdType.nativeCustomTemplate)
    }
    if adTypes.count <= 0 {
      print("Error: You must specify at least one ad type to load.")
      return
    }
    let videoOptions = GADVideoOptions()
    videoOptions.startMuted = startMutedSwitch.isOn
    videoOptions.customControlsRequested = requestCustomControlsSwitch.isOn
    refreshButton.isEnabled = false
    adLoader = GADAdLoader(
      adUnitID: TestAdUnit, rootViewController: self, adTypes: adTypes, options: [videoOptions])
    customControlsView.reset(withStartMuted: videoOptions.startMuted)
    adLoader?.delegate = self
    adLoader?.load(DFPRequest())
  }
  func setAdView(_ view: UIView) {
    // Remove previous ad view.
    nativeAdView?.removeFromSuperview()
    nativeAdView = view
    // Add new ad view and set constraints to fill its container.
    placeholderView.addSubview(view)
    nativeAdView?.translatesAutoresizingMaskIntoConstraints = false
    let viewDictionary: [String: Any] = ["_nativeAdView": view]
    placeholderView.addConstraints(
      NSLayoutConstraint.constraints(
        withVisualFormat: "H:|[_nativeAdView]|", options: [], metrics: nil, views: viewDictionary))
    placeholderView.addConstraints(
      NSLayoutConstraint.constraints(
        withVisualFormat: "V:|[_nativeAdView]|", options: [], metrics: nil, views: viewDictionary))
  }

  /// Gets an image representing the number of stars. Returns nil if rating is less than 3.5 stars.
  func image(forStars numberOfStars: NSDecimalNumber?) -> UIImage? {
    guard let numberOfStars = numberOfStars else {
      return nil
    }
    let starRating = Double(truncating: numberOfStars)
    var image: UIImage?
    if starRating >= 5 {
      image = UIImage(named: "stars_5")
    } else if starRating >= 4.5 {
      image = UIImage(named: "stars_4_5")
    } else if starRating >= 4 {
      image = UIImage(named: "stars_4")
    } else if starRating >= 3.5 {
      image = UIImage(named: "stars_3_5")
    }
    return image
  }
}

extension AdManagerCustomVideoControlsController: GADAdLoaderDelegate {
  func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
    print("\(adLoader) failed with error: \(error.localizedDescription)")
    refreshButton.isEnabled = true
  }
}

extension AdManagerCustomVideoControlsController: GADUnifiedNativeAdLoaderDelegate {
  func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADUnifiedNativeAd) {
    print("Received unified native ad: \(nativeAd)")
    refreshButton.isEnabled = true
    // Create and place ad in view hierarchy.
    let nativeAdView =
      Bundle.main.loadNibNamed("UnifiedNativeAdView", owner: nil, options: nil)?.first
      as! GADUnifiedNativeAdView
    setAdView(nativeAdView)

    // Populate the native ad view with the native ad assets.
    // The headline and mediaContent are guaranteed to be present in every native ad.
    (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
    nativeAdView.mediaView?.mediaContent = nativeAd.mediaContent

    // This app uses a fixed width for the GADMediaView and changes its height to match the aspect
    // ratio of the media it displays.
    if let mediaView = nativeAdView.mediaView, nativeAd.mediaContent.aspectRatio > 0 {
      let heightConstraint = NSLayoutConstraint(
        item: mediaView,
        attribute: .height,
        relatedBy: .equal,
        toItem: mediaView,
        attribute: .width,
        multiplier: CGFloat(1 / nativeAd.mediaContent.aspectRatio),
        constant: 0)
      heightConstraint.isActive = true
    }

    customControlsView.controller = nativeAd.videoController

    // These assets are not guaranteed to be present. Check that they are before
    // showing or hiding them.
    (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
    nativeAdView.bodyView?.isHidden = nativeAd.body == nil

    (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
    nativeAdView.callToActionView?.isHidden = nativeAd.callToAction == nil

    (nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
    nativeAdView.iconView?.isHidden = nativeAd.icon == nil

    (nativeAdView.starRatingView as? UIImageView)?.image = self.image(forStars: nativeAd.starRating)
    nativeAdView.starRatingView?.isHidden = nativeAd.starRating == nil

    (nativeAdView.storeView as? UILabel)?.text = nativeAd.store
    nativeAdView.storeView?.isHidden = nativeAd.store == nil

    (nativeAdView.priceView as? UILabel)?.text = nativeAd.price
    nativeAdView.priceView?.isHidden = nativeAd.price == nil

    (nativeAdView.advertiserView as? UILabel)?.text = nativeAd.advertiser
    nativeAdView.advertiserView?.isHidden = nativeAd.advertiser == nil

    // In order for the SDK to process touch events properly, user interaction
    // should be disabled.
    nativeAdView.callToActionView?.isUserInteractionEnabled = false

    // Associate the native ad view with the native ad object. This is
    // required to make the ad clickable.
    // Note: this should always be done after populating the ad views.
    nativeAdView.nativeAd = nativeAd
  }
}

extension AdManagerCustomVideoControlsController: GADNativeCustomTemplateAdLoaderDelegate {

  func adLoader(
    _ adLoader: GADAdLoader, didReceive nativeCustomTemplateAd: GADNativeCustomTemplateAd
  ) {
    print("Received custom native ad: \(nativeCustomTemplateAd)")
    refreshButton.isEnabled = true
    // Create and place ad in view hierarchy.
    let simpleNativeAdView =
      Bundle.main.loadNibNamed("SimpleNativeAdView", owner: nil, options: nil)?.first
      as! SimpleNativeAdView
    setAdView(simpleNativeAdView)
    // Populate the custom native ad view with its assets.
    simpleNativeAdView.populate(withCustomNativeAd: nativeCustomTemplateAd)
    customControlsView.controller = nativeCustomTemplateAd.videoController
  }

  func nativeCustomTemplateIDs(for adLoader: GADAdLoader) -> [String] {
    return [TestNativeCustomTemplateID]
  }

}
