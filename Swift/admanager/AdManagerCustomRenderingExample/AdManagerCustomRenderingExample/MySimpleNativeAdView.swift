//
//  Copyright 2015 Google LLC
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

/// Custom native ad view struct that defines the custom ad template asset keys as type properties.
enum MySimpleNativeAdViewTypeProperties {

  /// The headline asset key.
  static let mySimpleNativeAdViewHeadlineKey = "Headline"

  /// The main image asset key.
  static let mySimpleNativeAdViewMainImageKey = "MainImage"

  /// The caption asset key.
  static let mySimpleNativeAdViewCaptionKey = "Caption"
}

/// Custom native ad view class with format ID 10063170.
class MySimpleNativeAdView: UIView {

  /// Weak references to this ad's asset views.
  @IBOutlet weak var headlineView: UILabel!
  @IBOutlet weak var mainPlaceholder: UIView!
  @IBOutlet weak var captionView: UILabel!
  @IBOutlet weak var adChoicesView: UIImageView!

  /// The custom native ad that populated this view.
  var customNativeAd: CustomNativeAd!

  override func awakeFromNib() {
    super.awakeFromNib()

    DispatchQueue.main.async {
      // Enable clicks on the main image.
      self.mainPlaceholder.addGestureRecognizer(
        UITapGestureRecognizer(
          target: self,
          action: #selector(self.performClickOnMainImage(_:))))
      self.mainPlaceholder.isUserInteractionEnabled = true

      // Enable clicks on AdChoices.
      self.adChoicesView.addGestureRecognizer(
        UITapGestureRecognizer(
          target: self,
          action: #selector(self.performClickOnAdChoices(_:))))
      self.adChoicesView.isUserInteractionEnabled = true
    }
  }

  @objc func performClickOnMainImage(_ sender: UITapGestureRecognizer!) {
    customNativeAd.performClickOnAsset(
      withKey: MySimpleNativeAdViewTypeProperties.mySimpleNativeAdViewMainImageKey)
  }

  @objc func performClickOnAdChoices(_ sender: UITapGestureRecognizer!) {
    customNativeAd.performClickOnAsset(
      withKey: GADNativeAssetIdentifier.adChoicesViewAsset.rawValue)
  }

  /// Populates the ad view with the custom native ad object.
  func populate(withCustomNativeAd customNativeAd: CustomNativeAd) {
    self.customNativeAd = customNativeAd

    // Render the AdChoices image.
    let adChoicesKey = GADNativeAssetIdentifier.adChoicesViewAsset.rawValue
    let adChoicesImage = customNativeAd.image(forKey: adChoicesKey)?.image
    adChoicesView.image = adChoicesImage
    adChoicesView.isHidden = adChoicesImage == nil

    // The custom click handler closure overrides the normal click action defined by the ad.
    customNativeAd.customClickHandler = { assetID in
      let alert = UIAlertController(
        title: "Custom Click",
        message: "You just clicked on the image!",
        preferredStyle: .alert)
      let alertAction = UIAlertAction(
        title: "OK",
        style: .cancel,
        handler: nil)
      alert.addAction(alertAction)
      UIApplication.shared.keyWindow?.rootViewController?.present(
        alert, animated: true, completion: nil)
    }

    // Populate the custom native ad assets.
    let headlineKey = MySimpleNativeAdViewTypeProperties.mySimpleNativeAdViewHeadlineKey
    headlineView.text = customNativeAd.string(forKey: headlineKey)
    let captionKey = MySimpleNativeAdViewTypeProperties.mySimpleNativeAdViewCaptionKey
    captionView.text = customNativeAd.string(forKey: captionKey)

    let mainView: UIView = self.mainView(forCustomNativeAd: customNativeAd)
    updateMainView(mainView)
  }

  /// This custom native ad also has a both a video and image associated with it. We'll use the
  /// video asset if available, and otherwise fallback to the image asset.
  private func mainView(forCustomNativeAd customNativeAd: CustomNativeAd) -> UIView {
    if customNativeAd.mediaContent.hasVideoContent {
      let mediaView = MediaView()
      mediaView.mediaContent = customNativeAd.mediaContent
      return mediaView
    } else {
      let imageKey = MySimpleNativeAdViewTypeProperties.mySimpleNativeAdViewMainImageKey
      let image: UIImage? = customNativeAd.image(forKey: imageKey)?.image
      return UIImageView(image: image)
    }
  }

  private func updateMainView(_ mainView: UIView) {
    // Remove all the media placeholder's subviews.
    for subview: UIView in mainPlaceholder.subviews {
      subview.removeFromSuperview()
    }
    mainPlaceholder.addSubview(mainView)
    // Size the media view to fill our container size.
    mainView.translatesAutoresizingMaskIntoConstraints = false
    let viewDictionary: [AnyHashable: Any] = ["mainView": mainView]
    mainPlaceholder.addConstraints(
      NSLayoutConstraint.constraints(
        withVisualFormat: "H:|[mainView]|", options: [], metrics: nil,
        views: viewDictionary as? [String: Any] ?? [String: Any]()))
    mainPlaceholder.addConstraints(
      NSLayoutConstraint.constraints(
        withVisualFormat: "V:|[mainView]|", options: [], metrics: nil,
        views: viewDictionary as? [String: Any] ?? [String: Any]()))
  }
}
