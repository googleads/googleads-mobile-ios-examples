//
//  Copyright (C) 2015 Google, Inc.
//
//  ViewController.swift
//  NativeExample
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
    GADNativeContentAdLoaderDelegate {

  /// The view that holds the native ad.
  @IBOutlet weak var nativeAdPlaceholder: UIView!

  /// The app install ad switch.
  @IBOutlet weak var appInstallAdSwitch: UISwitch!

  /// The content ad switch.
  @IBOutlet weak var contentAdSwitch: UISwitch!

  /// The refresh ad button.
  @IBOutlet weak var refreshAdButton: UIButton!

  /// The SDK version label.
  @IBOutlet weak var versionLabel: UILabel!

  /// The ad loader. You must keep a strong reference to the GADAdLoader during the ad loading
  /// process.
  var adLoader: GADAdLoader!

  /// The native ad view that is being presented.
  var nativeAdView: UIView?

  /// The ad unit ID.
  let adUnitID = "ca-app-pub-3940256099942544/3986624511"

  override func viewDidLoad() {
    super.viewDidLoad()
    self.versionLabel.text = GADRequest.sdkVersion()
    self.refreshAd(nil)
  }

  func setAdView(view: UIView) {
    // Remove the previous ad view.
    self.nativeAdView?.removeFromSuperview()
    self.nativeAdView = view
    self.nativeAdPlaceholder.addSubview(view)
    self.nativeAdView!.translatesAutoresizingMaskIntoConstraints = false

    // Layout constraints for positioning the native ad view to stretch the entire width and height
    // of the nativeAdPlaceholder.
    let viewDictionary = ["_nativeAdView": nativeAdView!]
    self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[_nativeAdView]|",
        options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewDictionary))
    self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[_nativeAdView]|",
        options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewDictionary))
  }

  // MARK: - Actions

  /// Refresh the native ad.
  @IBAction func refreshAd(sender: AnyObject!) {
    var adTypes = [String]()
    if self.appInstallAdSwitch.on {
      adTypes.append(kGADAdLoaderAdTypeNativeAppInstall)
    }
    if self.contentAdSwitch.on {
      adTypes.append(kGADAdLoaderAdTypeNativeContent)
    }

    if adTypes.isEmpty {
      let alertView = UIAlertView(title: "Alert", message: "At least one ad format must be " +
          "selected to refresh the ad.", delegate: self, cancelButtonTitle: "OK")
      alertView.alertViewStyle = .Default
      alertView.show()
    } else {
      self.refreshAdButton.enabled = false
      self.adLoader = GADAdLoader.init(adUnitID: adUnitID, rootViewController: self,
          adTypes: adTypes, options: nil)
      if self.adLoader == nil {
        print("GADAdLoader failed to initialize.")
        self.refreshAdButton.enabled = true
        return
      }
      self.adLoader.delegate = self
      self.adLoader.loadRequest(GADRequest())
    }
  }

  // MARK: - GADAdLoaderDelegate

  func adLoader(adLoader: GADAdLoader!, didFailToReceiveAdWithError error: GADRequestError!) {
    print("\(adLoader) failed with error: \(error.localizedDescription)")
    self.refreshAdButton.enabled = true
  }

  // Mark: - GADNativeAppInstallAdLoaderDelegate

  func adLoader(adLoader: GADAdLoader!,
      didReceiveNativeAppInstallAd nativeAppInstallAd: GADNativeAppInstallAd!) {
    print("Received native app install ad: \(nativeAppInstallAd)")
    self.refreshAdButton.enabled = true

    // Create and place the ad in the view hierarchy.
    let appInstallAdView = NSBundle.mainBundle().loadNibNamed("NativeAppInstallAdView", owner: nil,
        options: nil).first as! GADNativeAppInstallAdView
    self.setAdView(appInstallAdView)

    // Associate the app install ad view with the app install ad object. This is required to make
    // the ad clickable.
    appInstallAdView.nativeAppInstallAd = nativeAppInstallAd

    // Populate the app install ad view with the app install ad assets.
    (appInstallAdView.headlineView as! UILabel).text = nativeAppInstallAd.headline
    (appInstallAdView.iconView as! UIImageView).image = nativeAppInstallAd.icon?.image
    (appInstallAdView.bodyView as! UILabel).text = nativeAppInstallAd.body
    (appInstallAdView.storeView as! UILabel).text = nativeAppInstallAd.store
    (appInstallAdView.priceView as! UILabel).text = nativeAppInstallAd.price
    (appInstallAdView.imageView as! UIImageView).image =
        (nativeAppInstallAd.images?.first as! GADNativeAdImage).image
    (appInstallAdView.starRatingView as! UIImageView).image =
        self.imageForStars(nativeAppInstallAd.starRating)
    (appInstallAdView.callToActionView as! UIButton).setTitle(
        nativeAppInstallAd.callToAction, forState: UIControlState.Normal)

    // In order for the SDK to process touch events properly, user interaction should be disabled.
    (appInstallAdView.callToActionView as! UIButton).userInteractionEnabled = false
  }

  /// Gets an image representing the number of stars. Returns nil if rating is less than 3.5 stars.
  func imageForStars(numberOfStars: NSDecimalNumber) -> UIImage? {
    let starRating = numberOfStars.doubleValue
    if starRating >= 5 {
      return UIImage(named: "stars_5")
    } else if starRating >= 4.5 {
      return UIImage(named: "stars_4_5")
    } else if starRating >= 4 {
      return UIImage(named: "stars_4")
    } else if starRating >= 3.5 {
      return UIImage(named: "stars_3_5")
    } else {
      return nil
    }
  }

  // Mark: - GADNativeContentAdLoaderDelegate

  func adLoader(adLoader: GADAdLoader!,
      didReceiveNativeContentAd nativeContentAd: GADNativeContentAd!) {
    print("Received native content ad: \(nativeContentAd)")
    self.refreshAdButton.enabled = true

    // Create and place the ad in the view hierarchy.
    let contentAdView = NSBundle.mainBundle().loadNibNamed("NativeContentAdView", owner: nil,
        options: nil).first as! GADNativeContentAdView
    self.setAdView(contentAdView)

    // Associate the content ad view with the content ad object. This is required to make the ad
    // clickable.
    contentAdView.nativeContentAd = nativeContentAd;

    // Populate the content ad view with the content ad assets.
    (contentAdView.headlineView as! UILabel).text = nativeContentAd.headline
    (contentAdView.bodyView as! UILabel).text = nativeContentAd.body
    (contentAdView.imageView as! UIImageView).image =
        (nativeContentAd.images?.first as! GADNativeAdImage).image
    (contentAdView.logoView as! UIImageView).image = nativeContentAd.logo?.image
    (contentAdView.advertiserView as! UILabel).text = nativeContentAd.advertiser
    (contentAdView.callToActionView as! UIButton).setTitle(
        nativeContentAd.callToAction, forState: UIControlState.Normal)

    // In order for the SDK to process touch events properly, user interaction should be disabled.
    (contentAdView.callToActionView as! UIButton).userInteractionEnabled = false
  }
}
