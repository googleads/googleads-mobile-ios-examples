//
//  Copyright (C) 2016 Google, Inc.
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
    bannerView.rootViewController = self
    bannerView.adUnitID = Constants.DFPPPIDAdUnitID
  }

  @IBAction func loadAd(sender: AnyObject) {
    view.endEditing(true)

    if let username = usernameTextField.text where !username.isEmpty {
      let request = DFPRequest()
      request.publisherProvidedID = generatePublisherProvidedIdentifierFromUsername(username)
      bannerView.loadRequest(request)
    } else {
      let alert = UIAlertView(title: "Load Ad Error",
          message: "Failed to load ad. Username is required",
          delegate: self,
          cancelButtonTitle: "OK")
      alert.alertViewStyle = .Default
      alert.show()
    }
  }

  @IBAction func screenTapped(sender: AnyObject) {
    view.endEditing(true)
  }

  /// Returns an MD5 hash `String` generated from the provided username `String` to use as the
  /// Publisher-Provided Identifier (PPID). The MD5 hash `String` is being used here as a convenient
  /// stand-in for a true PPID. In your own apps, you can decide for yourself how to generate the
  /// PPID value, though there are some restrictions on what the values can be. For details, see:
  /// https://support.google.com/dfp_premium/answer/2880055
  func generatePublisherProvidedIdentifierFromUsername(username: String) -> String {
    // The UTF8 C string representation of the username `String`.
    let utf8Username = username.cStringUsingEncoding(NSUTF8StringEncoding)
    // Allocate memory for a byte array of unsigned characters with size equal to
    // CC_MD5_DIGEST_LENGTH.
    let md5Buffer = UnsafeMutablePointer<CUnsignedChar>.alloc(Int(CC_MD5_DIGEST_LENGTH))
    // Create the 16 byte MD5 hash value.
    CC_MD5(utf8Username!, CC_LONG(strlen(utf8Username!)), md5Buffer)
    // Convert the MD5 hash value to an NSString of hex values.
    let publisherProvidedIdentifier = NSMutableString()
    for index in 0..<Int(CC_MD5_DIGEST_LENGTH) {
      publisherProvidedIdentifier.appendFormat("%02x", md5Buffer[index])
    }
    // Deallocate the memory for the byte array of unsigned characters with size equal to
    // CC_MD5_DIGEST_LENGTH.
    md5Buffer.dealloc(Int(CC_MD5_DIGEST_LENGTH))
    return publisherProvidedIdentifier as String
  }

}
