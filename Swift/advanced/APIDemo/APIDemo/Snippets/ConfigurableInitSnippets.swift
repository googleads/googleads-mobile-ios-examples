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
import GoogleMobileAds_Private
import UIKit

private class ConfigurableInitSnippets: UIViewController {

  private let adUnitID = "ca-app-pub-3940256099942544/5662855259"
  private let adapterClassName = "ExampleMediationAdapter"

  // Create a config that sets allowed ad unit ids and an initialization timeout.
  private func createAdUnitAdapterInitConfig() -> MediationInitializationConfiguration {
    // [START create_ad_unit_adapter_init_config]
    let adapterConfig = MediationInitializationConfiguration()
    adapterConfig.includedAdUnitIDs = [adUnitID]
    adapterConfig.initializationTimeout = 5.0
    // [END create_ad_unit_adapter_init_config]

    return adapterConfig
  }

  // Create a config that sets allowed ad formats ids and an initialization timeout.
  private func createAdFormatAdapterInitConfig() -> MediationInitializationConfiguration {

    // [START create_ad_format_adapter_init_config]
    let adapterConfig = MediationInitializationConfiguration()
    adapterConfig.includedAdFormats = [AdFormat.appOpen.rawValue as NSNumber]
    adapterConfig.initializationTimeout = 5.0
    // [END create_ad_format_adapter_init_config]

    return adapterConfig
  }

  // Create a config that setAllowedAdapterClasses and an initialization timeout.
  private func createIncludeSpecificAdapterInitConfig() -> MediationInitializationConfiguration {

    // [START create_include_adapter_init_config]
    let adapterConfig = MediationInitializationConfiguration()
    adapterConfig.includedAdapterClasses = [adapterClassName]
    adapterConfig.initializationTimeout = 5.0
    // [END create_include_adapter_init_config]

    return adapterConfig
  }

  // Create a config that setExcludedAdapterClasses and an initialization timeout.
  private func createSpecificExclusionAdapterInitConfig() -> MediationInitializationConfiguration {

    // [START create_exclude_adapter_init_config]
    let adapterConfig = MediationInitializationConfiguration()
    adapterConfig.excludedAdapterClasses = [adapterClassName]
    adapterConfig.initializationTimeout = 5.0
    // [END create_exclude_adapter_init_config]

    return adapterConfig
  }

  private func loadAppOpenAdForAdapterInitConfig(
    adapterInitializationConfig: MediationInitializationConfiguration,
    adUnitID: String
  ) async {

    // [START make_adapter_init_config_request]
    await MobileAds.shared.start(with: adapterInitializationConfig)

    // Make your ad request after adapter initialization completes.
    let request = Request()
    // Set this to guarantee that the ad request
    // doesn't wait for any other uninitialized adapters.
    request.skipUninitializedAdapters = true

    do {
      let _ = try await AppOpenAd.load(with: adUnitID, request: request)
    } catch {
      print("Failed to load app open ad with error: \(error.localizedDescription)")
      // TODO: Handle error
    }

    // Handle non time-sensitive tasks after the ad has loaded regardless of whether ad load
    // succeeded.
    performPostLaunchSetup()
    // [END make_adapter_init_config_request]
  }

  private func performPostLaunchSetup() {

    // [START empty_init_config]

    // Provide start with nil to initialize any adapters
    // not initialized with configurable initialization.
    MobileAds.shared.start(with: nil) { status in
      // Remaining adapters are now initialized.
    }

    // [END empty_init_config]
  }
}
