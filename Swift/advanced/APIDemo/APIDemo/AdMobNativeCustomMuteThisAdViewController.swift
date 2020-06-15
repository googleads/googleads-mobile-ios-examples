//
//  Copyright (C) 2018 Google, Inc.
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

/// A controller that demonstrates how to implement the custom Mute This Ad feature.
class AdMobNativeCustomMuteThisAdViewController: UIViewController {

  /// The view that holds the native ad.
  @IBOutlet var nativeAdPlaceholder: UIView!

  /// The refresh ad button.
  @IBOutlet var refreshAdButton: UIButton!

  // The button to mute the ad.
  @IBOutlet var muteAdButton: UIButton!

  /// Displays the current status of video assets.
  @IBOutlet var videoStatusLabel: UILabel!

  /// The SDK version label.
  @IBOutlet var versionLabel: UILabel!

  /// A picker view for displaying mute this ad reasons.
  @IBOutlet var pickerView: UIPickerView!

  /// The height constraint applied to the ad view, where necessary.
  var heightConstraint: NSLayoutConstraint?

  /// The ad loader. You must keep a strong reference to the GADAdLoader during the ad loading
  /// process.
  var adLoader: GADAdLoader!

  /// The native ad view that is being presented.
  var nativeAdView: GADUnifiedNativeAdView!

  /// The mute reasons being displayed, if applicable.
  var muteReasons: [GADMuteThisAdReason]?

  /// The ad unit ID.
  let adUnitID = "ca-app-pub-3940256099942544/3986624511"

  override func viewDidLoad() {
    super.viewDidLoad()
    versionLabel.text = GADRequest.sdkVersion()
    guard
      let nibObjects =
        Bundle.main.loadNibNamed("UnifiedNativeAdView", owner: nil, options: nil),
      let adView = nibObjects.first as? GADUnifiedNativeAdView
    else {
      assert(false, "Could not load nib file for adView")
    }
    setAdView(adView)
    nativeAdView.isHidden = true
    refreshAd(nil)
  }

  func setAdView(_ view: GADUnifiedNativeAdView) {
    // Remove the previous ad view.
    nativeAdView = view
    nativeAdPlaceholder.addSubview(nativeAdView)
    nativeAdView.translatesAutoresizingMaskIntoConstraints = false

    // Layout constraints for positioning the native ad view to stretch the entire width and height
    // of the nativeAdPlaceholder.
    let viewDictionary = ["_nativeAdView": nativeAdView!]
    self.view.addConstraints(
      NSLayoutConstraint.constraints(
        withVisualFormat: "H:|[_nativeAdView]|",
        options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewDictionary)
    )
    self.view.addConstraints(
      NSLayoutConstraint.constraints(
        withVisualFormat: "V:|[_nativeAdView]|",
        options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewDictionary)
    )
  }

  // MARK: - Actions

  /// Refreshes the native ad.
  @IBAction func refreshAd(_ sender: AnyObject!) {
    refreshAdButton.isEnabled = false
    videoStatusLabel.text = ""
    resetMuteAdDialog()

    // Provide the custom mute this ad loader options to request custom mute feature.
    adLoader = GADAdLoader(
      adUnitID: adUnitID, rootViewController: self,
      adTypes: [.unifiedNative],
      options: [GADNativeMuteThisAdLoaderOptions()])
    adLoader.delegate = self
    adLoader.load(GADRequest())
  }

  /// Returns a `UIImage` representing the number of stars from the given star rating; returns `nil`
  /// if the star rating is less than 3.5 stars.
  func imageOfStars(from starRating: NSDecimalNumber?) -> UIImage? {
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

  // MARK: - Custom Mute This Ad

  // Called when mute ad button is pressed.
  @IBAction func muteAd(_ sender: Any) {
    showMuteAdDialog()
  }

  // Called when a mute reason is selected.
  func muteAdDialogDidSelect(reason: GADMuteThisAdReason) {
    nativeAdView.nativeAd?.muteThisAd(with: reason)
    resetMuteAdDialog()
    muteAd()
  }

  func showMuteAdDialog() {
    guard let nativeAd = nativeAdView.nativeAd,
      let reasons = nativeAd.muteThisAdReasons,
      pickerView.isHidden
    else {
      return
    }

    muteAdButton.isEnabled = false
    muteReasons = reasons

    pickerView.reloadComponent(0)

    // Show the picker view.
    pickerView.isHidden = false

  }

  func muteAd() {
    // Our custom mute implementation simply hides the ad view.
    nativeAdView.isHidden = true
  }

  // Resets the mute ad interface.
  func resetMuteAdDialog() {
    pickerView.isHidden = true
    muteReasons = nil
  }

  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return muteReasons?.count ?? 0
  }

  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }

  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int)
    -> String?
  {
    return muteReasons?[row].reasonDescription ?? ""
  }

  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    if let reason = muteReasons?[row] {
      muteAdDialogDidSelect(reason: reason)
    }
  }
}

extension AdMobNativeCustomMuteThisAdViewController: GADVideoControllerDelegate {

  func videoControllerDidEndVideoPlayback(_ videoController: GADVideoController) {
    videoStatusLabel.text = "Video playback has ended."
  }
}

extension AdMobNativeCustomMuteThisAdViewController: GADAdLoaderDelegate {

  func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
    print("\(adLoader) failed with error: \(error.localizedDescription)")
    refreshAdButton.isEnabled = true
  }
}

extension AdMobNativeCustomMuteThisAdViewController: GADUnifiedNativeAdLoaderDelegate {

  func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADUnifiedNativeAd) {
    refreshAdButton.isEnabled = true

    /// Enable the mute button if custom mute is available.
    muteAdButton.isEnabled = nativeAd.isCustomMuteThisAdAvailable

    // Populate the native ad view with the native ad assets.
    // Some assets are guaranteed to be present in every native ad.
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

    // These assets are not guaranteed to be present. Check that they are before
    // showing or hiding them.
    (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
    nativeAdView.bodyView?.isHidden = nativeAd.body == nil

    (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
    nativeAdView.callToActionView?.isHidden = nativeAd.callToAction == nil

    (nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
    nativeAdView.iconView?.isHidden = nativeAd.icon == nil

    (nativeAdView.starRatingView as? UIImageView)?.image = self.imageOfStars(
      from: nativeAd.starRating)
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

    nativeAdView.isHidden = false
  }
}

// MARK: - GADUnifiedNativeAdDelegate implementation
extension AdMobNativeCustomMuteThisAdViewController: GADUnifiedNativeAdDelegate {

  func nativeAdIsMuted(_ nativeAd: GADUnifiedNativeAd) {
    print("\(#function) called")
  }
}
