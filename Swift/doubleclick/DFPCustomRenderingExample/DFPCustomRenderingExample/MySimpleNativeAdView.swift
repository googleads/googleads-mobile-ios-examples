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
  @IBOutlet weak var mainImageView: UIImageView!
  @IBOutlet weak var captionView: UILabel!

  /// The custom native ad that populated this view.
  var customNativeAd: GADNativeCustomTemplateAd!

  override func awakeFromNib() {
    super.awakeFromNib()

    // Enable clicks on the main image.
    mainImageView.addGestureRecognizer(UITapGestureRecognizer(target: self,
        action: #selector(MySimpleNativeAdView.performClickOnMainImage(_:))))
    mainImageView.userInteractionEnabled = true
  }

  func performClickOnMainImage(sender: UIImage!) {
    // The custom click handler closure overrides the normal click action defined by the ad.
    let customClickHandler: dispatch_block_t = {
      let alertView = UIAlertView(title: "Custom Click", message: "You just clicked on the image!",
          delegate: self, cancelButtonTitle: "OK")
      alertView.alertViewStyle = .Default
      alertView.show()
    }
    customNativeAd.performClickOnAssetWithKey(
        MySimpleNativeAdViewTypeProperties.MySimpleNativeAdViewMainImageKey,
        customClickHandler: customClickHandler)
  }

  /// Populates the ad view with the custom native ad object.
  func populateWithCustomNativeAd(customNativeAd: GADNativeCustomTemplateAd) {
    self.customNativeAd = customNativeAd

    // Populate the custom native ad assets.
    headlineView.text = customNativeAd.stringForKey(
        MySimpleNativeAdViewTypeProperties.MySimpleNativeAdViewHeadlineKey)
    mainImageView.image = customNativeAd.imageForKey(
        MySimpleNativeAdViewTypeProperties.MySimpleNativeAdViewMainImageKey)?.image
    captionView.text = customNativeAd.stringForKey(
        MySimpleNativeAdViewTypeProperties.MySimpleNativeAdViewCaptionKey)
  }

}
