//
//  Copyright (C) 2025 Google, Inc.
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

private class MobileAdsSnippets {

  private func presentAdInspector(from viewController: UIViewController?) {
    // [START present_ad_inspector]
    MobileAds.shared.presentAdInspector(from: viewController) { error in
      // Error will be non-nil if there was an issue and the inspector was not displayed.
    }
    // [END present_ad_inspector]
  }
}
