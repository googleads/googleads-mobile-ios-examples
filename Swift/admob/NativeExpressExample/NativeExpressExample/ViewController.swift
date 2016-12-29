// Copyright (C) 2016 Google, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import GoogleMobileAds
import UIKit

class ViewController: UIViewController, GADNativeExpressAdViewDelegate, GADVideoControllerDelegate {

  // This is a test ad unit that will return test ads for every request.
  let adUnitId = "ca-app-pub-3940256099942544/8897359316"

  @IBOutlet weak var nativeExpressAdView: GADNativeExpressAdView!

  override func viewDidLoad() {
    super.viewDidLoad()
    nativeExpressAdView.adUnitID = adUnitId
    nativeExpressAdView.rootViewController = self
    nativeExpressAdView.delegate = self

    // The video options object can be used to control the initial mute state of video assets.
    // By default, they start muted.
    let videoOptions = GADVideoOptions()
    videoOptions.startMuted = true
    nativeExpressAdView.setAdOptions([videoOptions])

    // Set this UIViewController as the video controller delegate, so it will be notified of events
    // in the video lifecycle.
    nativeExpressAdView.videoController.delegate = self

    let request = GADRequest()
    request.testDevices = [kGADSimulatorID]
    nativeExpressAdView.load(request)
  }

  // MARK: - GADNativeExpressAdViewDelegate

  func nativeExpressAdViewDidReceiveAd(_ nativeExpressAdView: GADNativeExpressAdView) {
    if nativeExpressAdView.videoController.hasVideoContent() {
      print("Received an ad with a video asset.")
    } else {
      print("Received an ad without a video asset.")
    }
  }

  // MARK: - GADVideoControllerDelegate

  func videoControllerDidEndVideoPlayback(_ videoController: GADVideoController) {
    print("The video asset has completed playback.")
  }
}
