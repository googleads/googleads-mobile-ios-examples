//
//  Copyright (C) 2016 Google, Inc.
//
//  DFPPPIDViewController.swift
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

class DFPPPIDViewController: UIViewController {

  /// The DFP banner view.
  @IBOutlet weak var bannerView: DFPBannerView!

  /// The user name text field.
  @IBOutlet weak var usernameTextField: UITextField!

  override func viewDidLoad() {
    super.viewDidLoad()
    self.bannerView.rootViewController = self
    self.bannerView.adUnitID = Constants.DFPPPIDAdUnitID
  }

  @IBAction func loadAd(sender: AnyObject) {
    self.view.endEditing(true)

    if let text = self.usernameTextField.text where !text.isEmpty {
      let request = DFPRequest()
      request.publisherProvidedID = self.publisherProvidedIdentifierWithString(text);
      self.bannerView.loadRequest(request)
    } else {
      let alert = UIAlertView(title: "Load Ad Error",
          message: "Failed to load ad. Username is required", delegate: self,
          cancelButtonTitle: "OK")
      alert.alertViewStyle = .Default
      alert.show()
    }
  }

  @IBAction func screenTapped(sender: AnyObject) {
    self.view.endEditing(true);
  }

  /// This is a simple method that takes a sample username string and returns an MD5 hash of the
  /// username to use as a PPID. It's being used here as a convenient stand-in for a true
  /// Publisher-Provided Identifier. In your own apps, you can decide for yourself how to generate
  /// the PPID value, though there are some restrictions on what the values can be. For details,
  /// see: https://support.google.com/dfp_premium/answer/2880055
  func publisherProvidedIdentifierWithString(string: String) -> String {
    // Create pointer to the username string as UTF8 string.
    let stringAsUTF8String = string.cStringUsingEncoding(NSUTF8StringEncoding)
    // Create byte array of unsigned characters.
    let MD5Buffer = UnsafeMutablePointer<CUnsignedChar>.alloc(Int(CC_MD5_DIGEST_LENGTH))
    /// Create 16 byte MD5 hash value.
    CC_MD5(stringAsUTF8String!, CC_LONG(strlen(stringAsUTF8String!)), MD5Buffer)
    // Convert MD5 value to NSString of hex values.
    let publisherProvidedIdentifier = NSMutableString()
    for  i in 0..<Int(CC_MD5_DIGEST_LENGTH) {
      publisherProvidedIdentifier.appendFormat("%02x", MD5Buffer[i]);
    }
    return publisherProvidedIdentifier as String;
  }

}
