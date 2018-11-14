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

/// Custom native ad view struct that defines the custom ad template asset keys as type properties.
struct MySimpleNativeAdViewTypeProperties {

  /// The headline asset key.
  static let MySimpleNativeAdViewHeadlineKey = "Headline"

  /// The main image asset key.
  static let MySimpleNativeAdViewMainImageKey = "MainImage"

  /// The caption asset key.
  static let MySimpleNativeAdViewCaptionKey = "Caption"
}

/// Custom native ad view class with template ID 10063170.
class MySimpleNativeAdView: UIView {

  /// Weak references to this ad's asset views.
  @IBOutlet weak var headlineView: UILabel!
  @IBOutlet weak var mainPlaceholder: UIView!
  @IBOutlet weak var captionView: UILabel!

  /// The custom native ad that populated this view.
  var customNativeAd: GADNativeCustomTemplateAd!

  override func awakeFromNib() {
    super.awakeFromNib()

    // Enable clicks on the main image.
    mainPlaceholder.addGestureRecognizer(UITapGestureRecognizer(target: self,
        action: #selector(MySimpleNativeAdView.performClickOnMainImage(_:))))
    mainPlaceholder.isUserInteractionEnabled = true
  }

  @objc func performClickOnMainImage(_ sender: UIImage!) {
    customNativeAd.performClickOnAsset(
        withKey: MySimpleNativeAdViewTypeProperties.MySimpleNativeAdViewMainImageKey)
  }

  /// Populates the ad view with the custom native ad object.
  func populate(withCustomNativeAd customNativeAd: GADNativeCustomTemplateAd) {
    self.customNativeAd = customNativeAd
    // The custom click handler closure overrides the normal click action defined by the ad.
    customNativeAd.customClickHandler = { assetID in
      let alertView = UIAlertView(title: "Custom Click", message: "You just clicked on the image!",
          delegate: self, cancelButtonTitle: "OK")
      alertView.alertViewStyle = .default
      alertView.show()
    }

    // Populate the custom native ad assets.
    let headlineKey = MySimpleNativeAdViewTypeProperties.MySimpleNativeAdViewHeadlineKey
    headlineView.text = customNativeAd.string(forKey: headlineKey)
    let captionKey = MySimpleNativeAdViewTypeProperties.MySimpleNativeAdViewCaptionKey
    captionView.text = customNativeAd.string(forKey: captionKey)

    let mainView: UIView = self.mainView(forCustomNativeAd: customNativeAd)
    updateMainView(mainView)
  }

  /// This custom native ad also has a both a video and image associated with it. We'll use the
  /// video asset if available, and otherwise fallback to the image asset.
  private func mainView(forCustomNativeAd customNativeAd:GADNativeCustomTemplateAd) -> UIView {
    if customNativeAd.videoController.hasVideoContent(),
      let mediaView = customNativeAd.mediaView {
      return mediaView
    } else {
      let imageKey = MySimpleNativeAdViewTypeProperties.MySimpleNativeAdViewMainImageKey
      let image: UIImage? = customNativeAd.image(forKey: imageKey)?.image
      return UIImageView(image: image)
    }
  }

  private func updateMainView(_ mainView:UIView) {
    // Remove all the media placeholder's subviews.
    for subview: UIView in mainPlaceholder.subviews {
      subview.removeFromSuperview()
    }
    mainPlaceholder.addSubview(mainView)
    // Size the media view to fill our container size.
    mainView.translatesAutoresizingMaskIntoConstraints = false
    let viewDictionary: [AnyHashable: Any] = ["mainView":mainView]
    mainPlaceholder.addConstraints(NSLayoutConstraint.constraints(
      withVisualFormat: "H:|[mainView]|", options: [], metrics: nil,
      views: viewDictionary as? [String : Any] ?? [String : Any]()))
    mainPlaceholder.addConstraints(NSLayoutConstraint.constraints(
      withVisualFormat: "V:|[mainView]|", options: [], metrics: nil,
      views: viewDictionary as? [String : Any] ?? [String : Any]()))
  }

}
