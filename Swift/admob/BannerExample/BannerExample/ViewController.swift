//  Copyright (c) 2015 Google. All rights reserved.

import UIKit
import GoogleMobileAds

class ViewController: UIViewController {

  @IBOutlet var bannerView: GADBannerView!

  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    println("Google Mobile Ads SDK version: " + GADRequest.sdkVersion())
    bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
    bannerView.rootViewController = self
    bannerView.loadRequest(GADRequest())
  }
}
