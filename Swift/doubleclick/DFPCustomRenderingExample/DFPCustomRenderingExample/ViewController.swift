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

class ViewController: UIViewController, GADNativeAppInstallAdLoaderDelegate,
    GADNativeContentAdLoaderDelegate, GADNativeCustomTemplateAdLoaderDelegate {

  // The view that holds the native ad.
  @IBOutlet weak var nativeAdPlaceholder: UIView!

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

  /// The ad loader. You must keep a strong reference to the GADAdLoader during the ad loading
  /// process.
  var adLoader: GADAdLoader!

  /// The native ad view that is being presented.
  var nativeAdView: UIView?

  /// The ad unit ID.
  let adUnitID = "/6499/example/native"

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
    var adTypes = [String]()
    if appInstallAdSwitch.isOn {
      adTypes.append(kGADAdLoaderAdTypeNativeAppInstall)
    }
    if contentAdSwitch.isOn {
      adTypes.append(kGADAdLoaderAdTypeNativeContent)
    }
    if customNativeAdSwitch.isOn {
      adTypes.append(kGADAdLoaderAdTypeNativeCustomTemplate)
    }

    if adTypes.isEmpty {
      let alertView = UIAlertView(title: "Alert", message: "At least one ad format must be " +
          "selected to refresh the ad.", delegate: self, cancelButtonTitle: "OK")
      alertView.alertViewStyle = .default
      alertView.show()
    } else {
      refreshAdButton.isEnabled = false
      adLoader = GADAdLoader(adUnitID: adUnitID, rootViewController: self,
          adTypes: adTypes, options: nil)
      adLoader.delegate = self
      adLoader.load(GADRequest())
    }
  }

  // MARK: - GADAdLoaderDelegate

  func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
    print("\(adLoader) failed with error: \(error.localizedDescription)")
    refreshAdButton.isEnabled = true
  }

  // MARK: - GADNativeAppInstallAdLoaderDelegate

  func adLoader(_ adLoader: GADAdLoader, didReceive nativeAppInstallAd: GADNativeAppInstallAd) {
    print("Received native app install ad: \(nativeAppInstallAd)")
    refreshAdButton.isEnabled = true

    // Create and place the ad in the view hierarchy.
    let appInstallAdView = Bundle.main.loadNibNamed("NativeAppInstallAdView", owner: nil,
        options: nil)?.first as! GADNativeAppInstallAdView
    setAdView(appInstallAdView)

    // Associate the app install ad view with the app install ad object. This is required to make
    // the ad clickable.
    appInstallAdView.nativeAppInstallAd = nativeAppInstallAd

    // Populate the app install ad view with the app install ad assets.
    // Some assets are guaranteed to be present in every app install ad.
    (appInstallAdView.headlineView as! UILabel).text = nativeAppInstallAd.headline
    (appInstallAdView.iconView as! UIImageView).image = nativeAppInstallAd.icon?.image
    (appInstallAdView.bodyView as! UILabel).text = nativeAppInstallAd.body
    (appInstallAdView.imageView as! UIImageView).image =
        (nativeAppInstallAd.images?.first as! GADNativeAdImage).image
    (appInstallAdView.callToActionView as! UIButton).setTitle(
        nativeAppInstallAd.callToAction, for: UIControlState.normal)

    // Other assets are not, however, and should be checked first.
    let starRatingView = appInstallAdView.starRatingView
    if let starRating = nativeAppInstallAd.starRating {
      (starRatingView as! UIImageView).image = imageOfStarsFromStarRating(starRating)
      starRatingView?.isHidden = false
    } else {
      starRatingView?.isHidden = true
    }

    let storeView = appInstallAdView.storeView
    if let store = nativeAppInstallAd.store {
      (storeView as! UILabel).text = store
      storeView?.isHidden = false
    } else {
      storeView?.isHidden = true
    }

    let priceView = appInstallAdView.priceView
    if let price = nativeAppInstallAd.price {
      (priceView as! UILabel).text = price
      priceView?.isHidden = false
    } else {
      priceView?.isHidden = true
    }

    // In order for the SDK to process touch events properly, user interaction should be disabled.
    (appInstallAdView.callToActionView as! UIButton).isUserInteractionEnabled = false
  }

  /// Returns a `UIImage` representing the number of stars from the given star rating; returns `nil`
  /// if the star rating is less than 3.5 stars.
  func imageOfStarsFromStarRating(_ starRating: NSDecimalNumber) -> UIImage? {
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

  // MARK: - GADNativeContentAdLoaderDelegate

  func adLoader(_ adLoader: GADAdLoader, didReceive nativeContentAd: GADNativeContentAd) {
    print("Received native content ad: \(nativeContentAd)")
    refreshAdButton.isEnabled = true

    // Create and place the ad in the view hierarchy.
    let contentAdView = Bundle.main.loadNibNamed(
        "NativeContentAdView", owner: nil, options: nil)?.first as! GADNativeContentAdView
    setAdView(contentAdView)

    // Associate the content ad view with the content ad object. This is required to make the ad
    // clickable.
    contentAdView.nativeContentAd = nativeContentAd

    // Populate the content ad view with the content ad assets.
    // Some assets are guaranteed to be present in every content ad.
    (contentAdView.headlineView as! UILabel).text = nativeContentAd.headline
    (contentAdView.bodyView as! UILabel).text = nativeContentAd.body
    (contentAdView.imageView as! UIImageView).image =
        (nativeContentAd.images?.first as! GADNativeAdImage).image
    (contentAdView.advertiserView as! UILabel).text = nativeContentAd.advertiser
    (contentAdView.callToActionView as! UIButton).setTitle(
        nativeContentAd.callToAction, for: UIControlState.normal)

    // Other assets are not, however, and should be checked first.
    let logoView = contentAdView.logoView
    if let logoImage = nativeContentAd.logo?.image {
      (logoView as! UIImageView).image = logoImage
      logoView?.isHidden = false
    } else {
      logoView?.isHidden = true
    }

    // In order for the SDK to process touch events properly, user interaction should be disabled.
    (contentAdView.callToActionView as! UIButton).isUserInteractionEnabled = false
  }

  // MARK: - GADNativeCustomTemplateAdLoaderDelegate

  func adLoader(_ adLoader: GADAdLoader,
      didReceive nativeCustomTemplateAd: GADNativeCustomTemplateAd) {
    print("Received custom native ad: \(nativeCustomTemplateAd)")
    refreshAdButton.isEnabled = true

    // Create and place the ad in the view hierarchy.
    let customNativeAdView = Bundle.main.loadNibNamed(
        "SimpleCustomNativeAdView", owner: nil, options: nil)!.first as! MySimpleNativeAdView
    setAdView(customNativeAdView)

    // Populate the custom native ad view with the custom native ad assets.
    customNativeAdView.populateWithCustomNativeAd(nativeCustomTemplateAd)
  }

  func nativeCustomTemplateIDs(for adLoader: GADAdLoader) -> [Any] {
    return [ "10063170" ]
  }

}
