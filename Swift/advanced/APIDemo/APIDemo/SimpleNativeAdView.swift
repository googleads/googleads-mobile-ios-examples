//
//  Copyright (C) 2018 Google, Inc.
//
//  SimpleNativeAdView.swift
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
import GoogleMobileAds
import UIKit

/// Headline asset key.
private let SimpleNativeAdViewHeadlineKey = "Headline"
/// Main image asset key.
private let SimpleNativeAdViewMainImageKey = "MainImage"
/// Caption asset key.
private let SimpleNativeAdViewCaptionKey = "Caption"

/// View representing a custom native ad format with template ID 10063170.
class SimpleNativeAdView: UIView {
  // Weak references to this ad's asset views.
  @IBOutlet weak var headlineView: UILabel!

  @IBOutlet weak var mainPlaceholder: UIView!
  @IBOutlet weak var captionView: UILabel!

  /// The custom native ad that populated this view.
  var customNativeAd: GADNativeCustomTemplateAd?

  override func awakeFromNib() {
    super.awakeFromNib()
    // Enable clicks on the headline.
    headlineView.addGestureRecognizer(
      UITapGestureRecognizer(target: self, action: #selector(self.performClickOnHeadline)))
    headlineView.isUserInteractionEnabled = true
  }

  @objc func performClickOnHeadline() {
    customNativeAd?.performClickOnAsset(withKey: SimpleNativeAdViewHeadlineKey)
  }

  /// Populates the ad view with the custom native ad object.
  func populate(withCustomNativeAd customNativeAd: GADNativeCustomTemplateAd) {
    self.customNativeAd = customNativeAd
    // The custom click handler is an optional block which will override the normal click action
    // defined by the ad. Pass nil for the click handler to let the SDK process the default click
    // action.
    customNativeAd.customClickHandler = { (_ assetID: String) -> Void in
      let alert = UIAlertController(
        title: "Custom Click",
        message: "You just clicked on the headline!",
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
    headlineView.text = customNativeAd.string(forKey: SimpleNativeAdViewHeadlineKey)
    captionView.text = customNativeAd.string(forKey: SimpleNativeAdViewCaptionKey)
    // Remove all the media placeholder's subviews.
    for subview: UIView in mainPlaceholder.subviews {
      subview.removeFromSuperview()
    }
    // This custom native ad has both a video and an image associated with it. We'll use the video
    // asset if available, and otherwise fallback to the image asset.
    var mainView: UIView!
    if customNativeAd.videoController.hasVideoContent() {
      mainView = customNativeAd.mediaView
    } else {
      let image: UIImage? = customNativeAd.image(forKey: SimpleNativeAdViewMainImageKey)?.image
      mainView = UIImageView(image: image)
    }
    mainPlaceholder.addSubview(mainView!)
    // Size the media view to fill our container size.
    mainView.translatesAutoresizingMaskIntoConstraints = false
    let viewDictionary: [String: Any] = ["mainView": mainView]
    mainPlaceholder.addConstraints(
      NSLayoutConstraint.constraints(
        withVisualFormat: "H:|[mainView]|", options: [], metrics: nil, views: viewDictionary))
    mainPlaceholder.addConstraints(
      NSLayoutConstraint.constraints(
        withVisualFormat: "V:|[mainView]|", options: [], metrics: nil, views: viewDictionary))
  }
}
