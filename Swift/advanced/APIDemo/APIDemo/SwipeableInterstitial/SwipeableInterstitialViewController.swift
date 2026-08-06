//
//  Copyright 2026 Google LLC
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

import SwiftUI
import UIKit

/// AdMob / Ad Manager - Swipeable interstitial ads in a scrolling vertical feed.
class SwipeableInterstitialViewController: UIViewController {

  override var prefersStatusBarHidden: Bool {
    true
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .black

    if #available(iOS 17.0, *) {
      // Use iOS 17+ SwiftUI ScrollView with paging behavior to natively simulate
      // a vertical scrolling feed without needing complex custom
      // UICollectionView pagination layouts.
      let hosting = UIHostingController(
        rootView: SwipeableFeedView(onBack: { [weak self] in
          self?.navigationController?.popViewController(animated: true)
        }))
      addChild(hosting)
      hosting.view.frame = view.bounds
      hosting.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      view.addSubview(hosting.view)
      hosting.didMove(toParent: self)
    } else {
      // SwipeableInterstitialAd works on iOS 12+. For < iOS 17 vertical
      // paging implementations, use UICollectionView with isPagingEnabled.
      let fallbackLabel = UILabel()
      fallbackLabel.numberOfLines = 0
      fallbackLabel.text = """
        SwipeableInterstitialAd works on iOS 12+.

        Native SwiftUI vertical paging requires iOS 17+.
        For iOS < 17, use UICollectionView with isPagingEnabled.
        """
      fallbackLabel.textColor = .white
      fallbackLabel.textAlignment = .center
      fallbackLabel.frame = view.bounds
      view.addSubview(fallbackLabel)
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(true, animated: animated)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.setNavigationBarHidden(false, animated: animated)
  }
}
