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

@import GoogleMobileAds;
@import GoogleMobileAds_Beta;

static NSString *const kTestAdUnitID = @"ca-app-pub-3940256099942544/5662855259";
static NSString *const kTestAdapterClassName = @"ExampleMediationAdapter";

@interface ConfigurableInitSnippets : NSObject
@end

@implementation ConfigurableInitSnippets

// Create a config that sets allowed ad unit ids and an initialization timeout.
- (GADMediationInitializationConfiguration *)createAdUnitAdapterInitConfig {
  // [START create_ad_unit_adapter_init_config]
  GADMediationInitializationConfiguration *adapterConfig =
      [[GADMediationInitializationConfiguration alloc] init];
  adapterConfig.includedAdUnitIDs = [NSSet setWithArray:@[ kTestAdUnitID ]];
  adapterConfig.initializationTimeout = 5.0;
  // [END create_ad_unit_adapter_init_config]

  return adapterConfig;
}

// Create a config that sets allowed ad formats ids and an initialization timeout.
- (GADMediationInitializationConfiguration *)createAdFormatAdapterInitConfig {
  // [START create_ad_format_adapter_init_config]
  GADMediationInitializationConfiguration *adapterConfig =
      [[GADMediationInitializationConfiguration alloc] init];
  adapterConfig.includedAdFormats = [NSSet setWithArray:@[ @(GADAdFormatAppOpen) ]];
  adapterConfig.initializationTimeout = 5.0;
  // [END create_ad_format_adapter_init_config]

  return adapterConfig;
}

// Create a config that setIncludedAdapterClasses and an initialization timeout.
- (GADMediationInitializationConfiguration *)createIncludeSpecificAdapterInitConfig {
  // [START create_include_adapter_init_config]
  GADMediationInitializationConfiguration *adapterConfig =
      [[GADMediationInitializationConfiguration alloc] init];
  adapterConfig.includedAdapterClasses = [NSSet setWithArray:@[ kTestAdapterClassName ]];
  adapterConfig.initializationTimeout = 5.0;
  // [END create_include_adapter_init_config]

  return adapterConfig;
}

// Create a config that setExcludedAdapterClasses and an initialization timeout.
- (GADMediationInitializationConfiguration *)createSpecificExclusionAdapterInitConfig {
  // [START create_exclude_adapter_init_config]
  GADMediationInitializationConfiguration *adapterConfig =
      [[GADMediationInitializationConfiguration alloc] init];
  adapterConfig.excludedAdapterClasses = [NSSet setWithArray:@[ kTestAdapterClassName ]];
  adapterConfig.initializationTimeout = 5.0;
  // [END create_exclude_adapter_init_config]

  return adapterConfig;
}

- (void)loadAppOpenAdForAdapterInitConfig:
            (GADMediationInitializationConfiguration *)adapterInitializationConfig
                                 adUnitID:(NSString *)adUnitID {
  // [START make_adapter_init_config_request]

  [[GADMobileAds sharedInstance]
      startWithMediationInitializationConfiguration:adapterInitializationConfig
                                  completionHandler:^(GADInitializationStatus *_Nonnull status) {
                                    // Make your ad request after adapter initialization
                                    // completes.
                                    GADRequest *request = [GADRequest request];
                                    // Set this to guarantee that the ad request
                                    // doesn't wait for any other uninitialized adapters
                                    request.shouldSkipUninitializedAdapters = YES;

                                    [GADAppOpenAd
                                        loadWithAdUnitID:adUnitID
                                                 request:request
                                        completionHandler:^(GADAppOpenAd *_Nullable ad,
                                                            NSError *_Nullable error) {
                                         if (error) {
                                           NSLog(@"Failed to load app open ad with error: %@",
                                                 error.localizedDescription);
                                         }

                                         // Handle non time-sensitive tasks after the
                                         // ad has loaded regardless of whether ad load succeeded.
                                         [self performPostLaunchSetup];
                                       }];
                                  }];

  // [END make_adapter_init_config_request]
}

- (void)performPostLaunchSetup {
  // [START empty_init_config]

  // Call start with nil to initialize any adapters not initialized via configurable initialization.
  [[GADMobileAds sharedInstance]
      startWithMediationInitializationConfiguration:nil
                                  completionHandler:^(GADInitializationStatus *_Nonnull status) {
                                    // Remaining adapters are now initialized.
                                  }];

  // [END empty_init_config]
}

@end
