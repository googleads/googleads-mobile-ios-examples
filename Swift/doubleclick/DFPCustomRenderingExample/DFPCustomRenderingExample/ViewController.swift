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
  @IBOutlet weak var appInstallAdSwitch: UISwitch!

  // The content ad switch.
  @IBOutlet weak var contentAdSwitch: UISwitch!

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
    if appInstallAdSwitch.isOn {
      adTypes.append(GADAdLoaderAdType.nativeAppInstall)
    }
    if contentAdSwitch.isOn {
      adTypes.append(GADAdLoaderAdType.nativeContent)
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
  func imageOfStars(fromStarRating starRating: NSDecimalNumber) -> UIImage? {
    let rating = starRating.doubleValue
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

// MARK: - GADNativeAppInstallAdLoaderDelegate
extension ViewController : GADNativeAppInstallAdLoaderDelegate {
  func adLoader(_ adLoader: GADAdLoader, didReceive nativeAppInstallAd: GADNativeAppInstallAd) {
    print("Received native app install ad: \(nativeAppInstallAd)")
    refreshAdButton.isEnabled = true
    // Create and place ad in view hierarchy.
    let nibView = Bundle.main.loadNibNamed("NativeAppInstallAdView", owner: nil, options: nil)?.first
    guard let appInstallAdView: GADNativeAppInstallAdView = nibView as? GADNativeAppInstallAdView else {
      return
    }
    setAdView(appInstallAdView)
    // Associate the app install ad view with the app install ad object. This is required to make
    // the ad clickable.
    appInstallAdView.nativeAppInstallAd = nativeAppInstallAd
    // Populate the app install ad view with the app install ad assets.
    // Some assets are guaranteed to be present in every app install ad.
    (appInstallAdView.headlineView as! UILabel).text = nativeAppInstallAd.headline
    (appInstallAdView.iconView as! UIImageView).image = nativeAppInstallAd.icon?.image
    (appInstallAdView.bodyView as! UILabel).text = nativeAppInstallAd.body
    (appInstallAdView.callToActionView as! UIButton).setTitle(nativeAppInstallAd.callToAction, for: .normal)

    // Update the ViewController for video content.
    updateVideoStatusLabel(forAdsVideoController: nativeAppInstallAd.videoController)

    // Some app install ads will include a video asset, while others do not. Apps can use the
    // GADVideoController's hasVideoContent property to determine if one is present, and adjust
    // their UI accordingly.

    // The UI for this controller constrains the image view's height to match the media view's
    // height, so by changing the one here, the height of both views are being adjusted.
    if (nativeAppInstallAd.videoController.hasVideoContent()) {

      // The video controller has content. Show the media view.
      appInstallAdView.mediaView?.isHidden = false
      appInstallAdView.imageView?.isHidden = true

      // This app uses a fixed width for the GADMediaView and changes its height to match the aspect
      // ratio of the video it displays.
      let heightConstraint = NSLayoutConstraint(
            item: appInstallAdView.mediaView!,
            attribute: .height,
            relatedBy: .equal,
            toItem: appInstallAdView.mediaView!,
            attribute: .width,
            multiplier: CGFloat(1.0 / nativeAppInstallAd.videoController.aspectRatio()),
            constant: 0)
      heightConstraint.isActive = true

      // By acting as the delegate to the GADVideoController, this ViewController receives messages
      // about events in the video lifecycle.
      nativeAppInstallAd.videoController.delegate = self

    } else {
      // If the ad doesn't contain a video asset, the first image asset is shown in the
      // image view. The existing lower priority height constraint is used.
      appInstallAdView.mediaView?.isHidden = true
      appInstallAdView.imageView?.isHidden = false

      let firstImage: GADNativeAdImage? = nativeAppInstallAd.images?.first as? GADNativeAdImage
      (appInstallAdView.imageView as? UIImageView)?.image = firstImage?.image

    }

    // These assets are not guaranteed to be present, and should be checked first.
    if let starRating = nativeAppInstallAd.starRating {
      (appInstallAdView.starRatingView as? UIImageView)?.image = imageOfStars(fromStarRating:starRating)
      appInstallAdView.starRatingView?.isHidden = false
    }
    else {
      appInstallAdView.starRatingView?.isHidden = true
    }
    if let store = nativeAppInstallAd.store {
      (appInstallAdView.storeView as? UILabel)?.text = store
      appInstallAdView.storeView?.isHidden = false
    }
    else {
      appInstallAdView.storeView?.isHidden = true
    }
    if let price = nativeAppInstallAd.price {
      (appInstallAdView.priceView as? UILabel)?.text = price
      appInstallAdView.priceView?.isHidden = false
    }
    else {
      appInstallAdView.priceView?.isHidden = true
    }
    // In order for the SDK to process touch events properly, user interaction should be disabled.
    appInstallAdView.callToActionView?.isUserInteractionEnabled = false
  }
}

// MARK: - GADNativeContentAdLoaderDelegate implementation
extension ViewController : GADNativeContentAdLoaderDelegate {

  func adLoader(_ adLoader: GADAdLoader, didReceive nativeContentAd: GADNativeContentAd) {
    print("Received native content ad: \(nativeContentAd)")
    refreshAdButton.isEnabled = true
    // Create and place ad in view hierarchy.
    let nibView = Bundle.main.loadNibNamed("NativeContentAdView", owner: nil, options: nil)?.first
    guard let contentAdView: GADNativeContentAdView = nibView as? GADNativeContentAdView else {
      return
    }
    setAdView(contentAdView)
    // Associate the content ad view with the content ad object. This is required to make the ad
    // clickable.
    contentAdView.nativeContentAd = nativeContentAd
    // Populate the content ad view with the content ad assets.
    // Some assets are guaranteed to be present in every content ad.
    (contentAdView.headlineView as? UILabel)?.text = nativeContentAd.headline
    (contentAdView.bodyView as? UILabel)?.text = nativeContentAd.body
    (contentAdView.advertiserView as? UILabel)?.text = nativeContentAd.advertiser
    (contentAdView.callToActionView as? UIButton)?.setTitle(nativeContentAd.callToAction, for: .normal)

    // Update the ViewController for video content.
    updateVideoStatusLabel(forAdsVideoController: nativeContentAd.videoController)
    if (nativeContentAd.videoController.hasVideoContent()) {
      nativeContentAd.videoController.delegate = self
    }
    // These assets are not guaranteed to be present, and should be checked first.
    if let image = nativeContentAd.logo?.image {
      (contentAdView.logoView as? UIImageView)?.image = image
      contentAdView.logoView?.isHidden = false
    }
    else {
      contentAdView.logoView?.isHidden = true
    }
    // In order for the SDK to process touch events properly, user interaction should be disabled.
    contentAdView.callToActionView?.isUserInteractionEnabled = false
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
