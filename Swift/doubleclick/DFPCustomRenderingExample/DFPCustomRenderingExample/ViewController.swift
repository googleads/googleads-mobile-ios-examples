//
//  Copyright (C) 2015 Google, Inc.
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

class ViewController: UIViewController {

  // The view that holds the native ad.
  @IBOutlet weak var nativeAdPlaceholder: UIView!

  // Displays status messages about presence of video assets.
  @IBOutlet weak var videoStatusLabel: UILabel!

  // The app install ad switch.
  @IBOutlet weak var nativeAdSwitch: UISwitch!

  // The custom native ad switch.
  @IBOutlet weak var customNativeAdSwitch: UISwitch!

  // The refresh ad button.
  @IBOutlet weak var refreshAdButton: UIButton!

  // The SDK version label.
  @IBOutlet weak var versionLabel: UILabel!

  // Switch to indicate if video ads should start muted.
  @IBOutlet weak var startMutedSwitch: UISwitch!

  /// The ad loader. You must keep a strong reference to the GADAdLoader during the ad loading
  /// process.
  var adLoader: GADAdLoader!

  /// The native ad view that is being presented.
  var nativeAdView: UIView?

  /// The ad unit ID.
  let adUnitID = "/6499/example/native"

  /// The native custom template id
  let nativeCustomTemplateId = "10104090"

  override func viewDidLoad() {
    super.viewDidLoad()
    versionLabel.text = GADRequest.sdkVersion()
    refreshAd(nil)
  }

  func setAdView(_ view: UIView) {
    // Remove the previous ad view.
    nativeAdView?.removeFromSuperview()
    nativeAdView = view
    nativeAdPlaceholder.addSubview(nativeAdView!)
    nativeAdView!.translatesAutoresizingMaskIntoConstraints = false

    // Layout constraints for positioning the native ad view to stretch the entire width and height
    // of the nativeAdPlaceholder.
    let viewDictionary = ["_nativeAdView": nativeAdView!]
    self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[_nativeAdView]|",
        options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewDictionary))
    self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[_nativeAdView]|",
        options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewDictionary))
  }

  // MARK: - Actions

  /// Refreshes the native ad.
  @IBAction func refreshAd(_ sender: AnyObject!) {
    var adTypes = [GADAdLoaderAdType]()
    if nativeAdSwitch.isOn {
      adTypes.append(GADAdLoaderAdType.unifiedNative)
    }
    if customNativeAdSwitch.isOn {
      adTypes.append(GADAdLoaderAdType.nativeCustomTemplate)
    }

    if adTypes.isEmpty {
      let alertView = UIAlertView(title: "Alert", message: "At least one ad format must be " +
          "selected to refresh the ad.", delegate: self, cancelButtonTitle: "OK")
      alertView.alertViewStyle = .default
      alertView.show()
    } else {
      refreshAdButton.isEnabled = false
      let videoOptions = GADVideoOptions()
      videoOptions.startMuted = startMutedSwitch.isOn
      adLoader = GADAdLoader(adUnitID: adUnitID, rootViewController: self,
          adTypes: adTypes, options: [videoOptions])
      adLoader.delegate = self
      adLoader.load(GADRequest())
      videoStatusLabel.text = ""
    }
  }

  /// Returns a `UIImage` representing the number of stars from the given star rating; returns `nil`
  /// if the star rating is less than 3.5 stars.
  func imageOfStars(fromStarRating starRating: NSDecimalNumber?) -> UIImage? {
    guard let rating = starRating?.doubleValue else {
      return nil
    }
    if rating >= 5 {
      return UIImage(named: "stars_5")
    } else if rating >= 4.5 {
      return UIImage(named: "stars_4_5")
    } else if rating >= 4 {
      return UIImage(named: "stars_4")
    } else if rating >= 3.5 {
      return UIImage(named: "stars_3_5")
    } else {
      return nil
    }
  }

  /// Updates the videoController's delegate and viewController's UI according to videoController
  /// 'hasVideoContent()' value.
  /// Some content ads will include a video asset, while others do not. Apps can use the
  /// GADVideoController's hasVideoContent property to determine if one is present, and adjust their
  /// UI accordingly.
  func updateVideoStatusLabel(forAdsVideoController videoController: GADVideoController) {
    if videoController.hasVideoContent() {
      // By acting as the delegate to the GADVideoController, this ViewController receives messages
      // about events in the video lifecycle.
      videoStatusLabel.text = "Ad contains a video asset."
    }
    else {
      videoStatusLabel.text = "Ad does not contain a video."
    }
  }

}

// MARK: - GADAdLoaderDelegate
extension ViewController : GADAdLoaderDelegate {
  func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
    print("\(adLoader) failed with error: \(error.localizedDescription)")
    refreshAdButton.isEnabled = true
  }
}

// MARK: - GADUnifiedNativeAdLoaderDelegate
extension ViewController : GADUnifiedNativeAdLoaderDelegate {

  func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADUnifiedNativeAd) {
    print("Received unified native ad: \(nativeAd)")
    refreshAdButton.isEnabled = true
    // Create and place ad in view hierarchy.
    let nibView = Bundle.main.loadNibNamed("UnifiedNativeAdView", owner: nil, options: nil)?.first
    guard let nativeAdView = nibView as? GADUnifiedNativeAdView else {
      return
    }
    setAdView(nativeAdView)

    // Set ourselves as the native ad delegate to be notified of native ad events.
    nativeAd.delegate = self

    nativeAdView.nativeAd = nativeAd
    // Populate the native ad view with the native ad assets.
    // Some assets are guaranteed to be present in every native ad.
    (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
    (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
    (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)

    // Some native ads will include a video asset, while others do not. Apps can use the
    // GADVideoController's hasVideoContent property to determine if one is present, and adjust their
    // UI accordingly.
    // The UI for this controller constrains the image view's height to match the media view's
    // height, so by changing the one here, the height of both views are being adjusted.
    if let controller = nativeAd.videoController, controller.hasVideoContent() {
      // The video controller has content. Show the media view.
      if let mediaView = nativeAdView.mediaView {
        mediaView.isHidden = false
        nativeAdView.imageView?.isHidden = true
        // This app uses a fixed width for the GADMediaView and changes its height to match the aspect
        // ratio of the video it displays.
        if controller.aspectRatio() > 0 {
          let heightConstraint = NSLayoutConstraint(item: mediaView,
                                                    attribute: .height,
                                                    relatedBy: .equal,
                                                    toItem: mediaView,
                                                    attribute: .width,
                                                    multiplier: CGFloat(1 / controller.aspectRatio()),
                                                    constant: 0)
          heightConstraint.isActive = true
        }
      }
      // By acting as the delegate to the GADVideoController, this ViewController receives messages
      // about events in the video lifecycle.
      controller.delegate = self
      videoStatusLabel.text = "Ad contains a video asset."
    }
    else {
      // If the ad doesn't contain a video asset, the first image asset is shown in the
      // image view. The existing lower priority height constraint is used.
      nativeAdView.mediaView?.isHidden = true
      nativeAdView.imageView?.isHidden = false
      let firstImage: GADNativeAdImage? = nativeAd.images?.first
      (nativeAdView.imageView as? UIImageView)?.image = firstImage?.image
      videoStatusLabel.text = "Ad does not contain a video."
    }
    // These assets are not guaranteed to be present, and should be checked first.
    (nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
    if let _ = nativeAd.icon {
      nativeAdView.iconView?.isHidden = false
    } else {
      nativeAdView.iconView?.isHidden = true
    }
    (nativeAdView.starRatingView as? UIImageView)?.image = imageOfStars(fromStarRating:nativeAd.starRating)
    if let _ = nativeAd.starRating {
      nativeAdView.starRatingView?.isHidden = false
    }
    else {
      nativeAdView.starRatingView?.isHidden = true
    }
    (nativeAdView.storeView as? UILabel)?.text = nativeAd.store
    if let _ = nativeAd.store {
      nativeAdView.storeView?.isHidden = false
    }
    else {
      nativeAdView.storeView?.isHidden = true
    }
    (nativeAdView.priceView as? UILabel)?.text = nativeAd.price
    if let _ = nativeAd.price {
      nativeAdView.priceView?.isHidden = false
    }
    else {
      nativeAdView.priceView?.isHidden = true
    }
    (nativeAdView.advertiserView as? UILabel)?.text = nativeAd.advertiser
    if let _ = nativeAd.advertiser {
      nativeAdView.advertiserView?.isHidden = false
    }
    else {
      nativeAdView.advertiserView?.isHidden = true
    }
    // In order for the SDK to process touch events properly, user interaction should be disabled.
    nativeAdView.callToActionView?.isUserInteractionEnabled = false
  }
}


// MARK: - GADNativeCustomTemplateAdLoaderDelegate
extension ViewController : GADNativeCustomTemplateAdLoaderDelegate {
  func nativeCustomTemplateIDs(for adLoader: GADAdLoader) -> [String] {
    return [ nativeCustomTemplateId ]
  }

  func adLoader(_ adLoader: GADAdLoader,
                didReceive nativeCustomTemplateAd: GADNativeCustomTemplateAd) {
    print("Received custom native ad: \(nativeCustomTemplateAd)")
    refreshAdButton.isEnabled = true
    // Create and place the ad in the view hierarchy.
    let customNativeAdView = Bundle.main.loadNibNamed(
      "SimpleCustomNativeAdView", owner: nil, options: nil)!.first as! MySimpleNativeAdView
    setAdView(customNativeAdView)
    // Update the ViewController for video content.
    updateVideoStatusLabel(forAdsVideoController: nativeCustomTemplateAd.videoController)
    if (nativeCustomTemplateAd.videoController.hasVideoContent()) {
      nativeCustomTemplateAd.videoController.delegate = self
    }
    // Populate the custom native ad view with the custom native ad assets.
    customNativeAdView.populate(withCustomNativeAd:nativeCustomTemplateAd)
  }
}

// MARK: - GADVideoControllerDelegate implementation
extension ViewController : GADVideoControllerDelegate {

  func videoControllerDidEndVideoPlayback(_ videoController: GADVideoController) {
    videoStatusLabel.text = "Video playback has ended."
  }
}

// MARK: - GADUnifiedNativeAdDelegate implementation
extension ViewController : GADUnifiedNativeAdDelegate {

  func nativeAdDidRecordClick(_ nativeAd: GADUnifiedNativeAd) {
    print("\(#function) called")
  }

  func nativeAdDidRecordImpression(_ nativeAd: GADUnifiedNativeAd) {
    print("\(#function) called")
  }

  func nativeAdWillPresentScreen(_ nativeAd: GADUnifiedNativeAd) {
    print("\(#function) called")
  }

  func nativeAdWillDismissScreen(_ nativeAd: GADUnifiedNativeAd) {
    print("\(#function) called")
  }

  func nativeAdDidDismissScreen(_ nativeAd: GADUnifiedNativeAd) {
    print("\(#function) called")
  }

  func nativeAdWillLeaveApplication(_ nativeAd: GADUnifiedNativeAd) {
    print("\(#function) called")
  }
}
