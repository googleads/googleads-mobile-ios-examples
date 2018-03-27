//
//  Copyright (C) 2018 Google, Inc.
//
//  DFPCustomVideoControlsController.h
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

class DFPCustomVideoControlsController: UIViewController {
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
        adTypes.append(GADAdLoaderAdType.unifiedNative)
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
      adLoader = GADAdLoader(adUnitID: TestAdUnit, rootViewController: self, adTypes: adTypes, options: [videoOptions])
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
      let viewDictionary : [String:Any] = ["_nativeAdView":view]
        placeholderView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[_nativeAdView]|", options: [], metrics: nil, views: viewDictionary))
        placeholderView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[_nativeAdView]|", options: [], metrics: nil, views: viewDictionary))
    }

  /// Gets an image representing the number of stars. Returns nil if rating is less than 3.5 stars.
  func image(forStars numberOfStars: NSDecimalNumber?) -> UIImage? {
    guard let numberOfStars = numberOfStars  else {
      return nil
    }
    let starRating = Double(numberOfStars)
    var image: UIImage?
      if starRating >= 5 {
          image = UIImage(named: "stars_5")
      }
      else if starRating >= 4.5 {
          image = UIImage(named: "stars_4_5")
      }
      else if starRating >= 4 {
          image = UIImage(named: "stars_4")
      }
      else if starRating >= 3.5 {
          image = UIImage(named: "stars_3_5")
      }
      return image
  }
}

extension DFPCustomVideoControlsController : GADAdLoaderDelegate {
  func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
    print("\(adLoader) failed with error: \(error.localizedDescription)")
    refreshButton.isEnabled = true
  }
}

extension DFPCustomVideoControlsController : GADUnifiedNativeAdLoaderDelegate {
  func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADUnifiedNativeAd) {
    print("Received unified native ad: \(nativeAd)")
    refreshButton.isEnabled = true
    // Create and place ad in view hierarchy.
    let nativeAdView = Bundle.main.loadNibNamed("UnifiedNativeAdView", owner: nil, options: nil)?.first as! GADUnifiedNativeAdView
    setAdView(nativeAdView)
    nativeAdView.nativeAd = nativeAd
    // Populate the native ad view with the native ad assets.
    // Some assets are guaranteed to be present in every native ad.
    (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
    (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
    (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
    // Some native ads will include a video asset, while others do not. Apps can
    // use the GADVideoController's hasVideoContent property to determine if one
    // is present, and adjust their UI accordingly.
    // The UI for this controller constrains the image view's height to match the
    // media view's height, so by changing the one here, the height of both views
    // are being adjusted.
    if let controller = nativeAd.videoController, controller.hasVideoContent() {
      // The video controller has content. Show the media view.
      nativeAdView.mediaView?.isHidden = false
      nativeAdView.imageView?.isHidden = true
      // This app uses a fixed width for the GADMediaView and changes its height
      // to match the aspect ratio of the video it displays.
      if controller.aspectRatio() > 0 {
        let heightConstraint = NSLayoutConstraint(item: nativeAdView.mediaView!,
                                                attribute: .height,
                                                relatedBy: .equal,
                                                toItem: nativeAdView.mediaView!,
                                                attribute: .width,
                                                multiplier: CGFloat(1 / controller.aspectRatio()),
                                                constant: 0)
        heightConstraint.isActive = true
      }
    }
    else {
      // If the ad doesn't contain a video asset, the first image asset is shown
      // in the image view. The existing lower priority height constraint is used.
      nativeAdView.mediaView?.isHidden = true
      nativeAdView.imageView?.isHidden = false
      let firstImage: GADNativeAdImage? = nativeAd.images?.first
      (nativeAdView.imageView as? UIImageView)?.image = firstImage?.image
    }
    customControlsView.controller = nativeAd.videoController
    // These assets are not guaranteed to be present, and should be checked first.
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
  }
}

extension DFPCustomVideoControlsController : GADNativeCustomTemplateAdLoaderDelegate {

  func adLoader(_ adLoader: GADAdLoader, didReceive nativeCustomTemplateAd: GADNativeCustomTemplateAd) {
    print("Received custom native ad: \(nativeCustomTemplateAd)")
    refreshButton.isEnabled = true
    // Create and place ad in view hierarchy.
    let simpleNativeAdView = Bundle.main.loadNibNamed("SimpleNativeAdView", owner: nil, options: nil)?.first as! SimpleNativeAdView
    setAdView(simpleNativeAdView)
    // Populate the custom native ad view with its assets.
    simpleNativeAdView.populate(withCustomNativeAd: nativeCustomTemplateAd)
    customControlsView.controller = nativeCustomTemplateAd.videoController
  }

  func nativeCustomTemplateIDs(for adLoader: GADAdLoader) -> [String] {
    return [TestNativeCustomTemplateID]
  }

}
