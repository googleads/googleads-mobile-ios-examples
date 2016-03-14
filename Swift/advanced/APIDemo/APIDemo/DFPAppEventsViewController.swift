//
//  Copyright (C) 2016 Google, Inc.
//
//  DFPAppEventsViewController.swift
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
//

import GoogleMobileAds
import UIKit

/// DFP - App Events
/// Demonstrates handling GADAppEventDelegate app event messages sent by the DFP banner.
class DFPAppEventsViewController: UIViewController, GADAppEventDelegate {

  /// The DFP banner view.
  @IBOutlet weak var bannerView: DFPBannerView!

  override func viewDidLoad() {
    super.viewDidLoad()
    self.bannerView.adUnitID = Constants.DFPAppEventsAdUnitID
    self.bannerView.rootViewController = self
    self.bannerView.appEventDelegate = self
    self.bannerView.loadRequest(DFPRequest())
  }

  // MARK - GADAppEventDelegate

  func adView(banner: GADBannerView!, didReceiveAppEvent name: String!, withInfo info: String!) {
    // The DFP banner sends app event messages to its app event delegate, this view controller. The
    // GADAppEventDelegate will be notified when the SDK receives an app event message from the
    // banner. In this demo, the GADAppEventDelegate method sets the background of this view
    // controller to match the data that comes in. The banner will send "red" when it loads, "blue"
    // five seconds later, and "green" if the user taps the banner.
    //
    // This is just a demonstration, of course. Your apps can do much more interesting things with
    // app events.
    if name == "color" {
      switch info {
      case "blue":
        self.view.backgroundColor = UIColor.blueColor()
      case "red":
        self.view.backgroundColor = UIColor.redColor()
      case "green":
        self.view.backgroundColor = UIColor.greenColor()
      default:
        break
      }
    }
  }

}
