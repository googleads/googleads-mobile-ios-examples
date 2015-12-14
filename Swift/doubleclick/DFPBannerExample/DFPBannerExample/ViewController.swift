//  Copyright (c) 2015 Google. All rights reserved.

import UIKit
import GoogleMobileAds

class ViewController: UIViewController {

  @IBOutlet weak var bannerView: DFPBannerView!

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    print("Google Mobile Ads SDK version: " + DFPRequest.sdkVersion())
    bannerView.adUnitID = "/6499/example/banner"
    bannerView.rootViewController = self
    bannerView.loadRequest(DFPRequest())
  }
}
