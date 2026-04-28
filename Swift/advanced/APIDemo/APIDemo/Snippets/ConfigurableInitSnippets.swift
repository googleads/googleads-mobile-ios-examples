//
//  Copyright (C) 2026 Google, Inc.
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

private class ConfigurableInitSnippets: UIViewController {

  private let adUnitID = "ca-app-pub-3940256099942544/5662855259"
  private let adapterClassName = "com.google.ads.mediation.example.ExampleMediationAdapter"

  // Scenario 1A: (Prioritize Ad + with timeout)
  // Create a config that sets allowed ad unit ids and an init timeout
  private func createAdUnitAdapterInitConfig() -> MediationInitializationConfiguration {

    // [START create_ad_unit_adapter_init_config]
    let adapterConfig = MediationInitializationConfiguration()
    adapterConfig.includedAdUnitIDs = [adUnitID]
    adapterConfig.initializationTimeout = 5.0  // 5 seconds
    // [END create_ad_unit_adapter_init_config]

    return adapterConfig
  }

  // Scenario 1B: (Prioritize Ad + with timeout)
  // Create a config that sets allowed ad formats ids and an init timeout
  private func createAdFormatAdapterInitConfig() -> MediationInitializationConfiguration {

    // [START create_ad_format_adapter_init_config]
    let adapterConfig = MediationInitializationConfiguration()
    adapterConfig.includedAdFormats = [NSNumber(value: AdFormat.appOpen.rawValue)]
    adapterConfig.initializationTimeout = 5.0  // 5 seconds
    // [END create_ad_format_adapter_init_config]

    return adapterConfig
  }

  // Scenario 2: (Specifically include selected adapters)
  // Create a config that setAllowedAdapterClasses and an init timeout
  private func createIncludeSpecificAdapterInitConfig() -> MediationInitializationConfiguration {

    // [START create_include_adapter_init_config]
    let adapterConfig = MediationInitializationConfiguration()
    adapterConfig.includedAdapterClasses = [""]
    adapterConfig.initializationTimeout = 5.0  // 5 seconds
    // [END create_include_adapter_init_config]

    return adapterConfig
  }

  // Scenario 3: (Exclude specific adapters)
  // Create a config that setExcludedAdapterClasses and an init timeout
  private func createSpecificExclusionAdapterInitConfig() -> MediationInitializationConfiguration {

    // [START create_exclude_adapter_init_config]
    let adapterConfig = MediationInitializationConfiguration()
    adapterConfig.excludedAdapterClasses = [adapterClassName]
    adapterConfig.initializationTimeout = 5.0  // 5 seconds
    // [END create_exclude_adapter_init_config]

    return adapterConfig
  }

  private func loadAppOpenAdForAdapterInitConfig(
    adapterInitializationConfig: MediationInitializationConfiguration,
    adUnitID: String
  ) {

    // [START make_adapter_init_config_request]

    // Initialize the Next-Gen SDK with a config containing your adapter init settings
    MobileAds.shared.start(with: adapterInitializationConfig) { status in

      // Make your ad request as soon as adapter initialization completes.
      let request = Request()
      // Important: Set this to guarantee that the ad request
      // doesn't wait for any other uninitialized adapters
      request.skipUninitializedAdapters = true

      AppOpenAd.load(
        with: adUnitID,
        request: request
      ) { ad, error in
        if let error = error {
          print("Failed to load app open ad with error: \(error.localizedDescription)")
          return
        }

        // Handle necessary, but non time-sensitive tasks after the ad has loaded.
        self.performPostLaunchSetup()
      }
    }

    // [END make_adapter_init_config_request]
  }

  private func performPostLaunchSetup() {

    // [START empty_init_config]

    // Initialize rest of your adapters by providing an empty configuration
    MobileAds.shared.start(with: nil) { status in
      // Remaining adapters are now initialized.
    }

    // [END empty_init_config]
  }
}
