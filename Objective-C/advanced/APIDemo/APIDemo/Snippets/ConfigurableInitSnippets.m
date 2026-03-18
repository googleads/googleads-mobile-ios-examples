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

@interface ConfigurableInitSnippets : NSObject

- (GADMediationInitializationConfiguration *)createAdUnitAdapterInitConfig;
- (GADMediationInitializationConfiguration *)createAdFormatAdapterInitConfig;
- (GADMediationInitializationConfiguration *)createIncludeSpecificAdapterInitConfig;
- (GADMediationInitializationConfiguration *)createSpecificExclusionAdapterInitConfig;

- (void)loadAppOpenAdForAdapterInitConfig:
            (GADMediationInitializationConfiguration *)adapterInitializationConfig
                                 adUnitID:(NSString *)adUnitID;

- (void)performPostLaunchSetup;

@end

@implementation ConfigurableInitSnippets {
  NSString *_adUnitID;
  NSString *_adapterClassName;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _adUnitID = @"ca-app-pub-3940256099942544/5662855259";
    _adapterClassName = @"com.google.ads.mediation.example.ExampleMediationAdapter";
  }
  return self;
}

// Scenario 1A: (Prioritize Ad + with timeout)
// Create a config that sets allowed ad unit ids and an init timeout
- (GADMediationInitializationConfiguration *)createAdUnitAdapterInitConfig {
  // [START create_ad_unit_adapter_init_config]
  GADMediationInitializationConfiguration *adapterConfig =
      [[GADMediationInitializationConfiguration alloc] init];
  adapterConfig.includedAdUnitIDs = [NSSet setWithArray:@[ _adUnitID ]];
  adapterConfig.initializationTimeout = 5.0;  // 5 seconds
  // [END create_ad_unit_adapter_init_config]

  return adapterConfig;
}

// Scenario 1B: (Prioritize Ad + with timeout)
// Create a config that sets allowed ad formats ids and an init timeout
- (GADMediationInitializationConfiguration *)createAdFormatAdapterInitConfig {
  // [START create_ad_format_adapter_init_config]
  GADMediationInitializationConfiguration *adapterConfig =
      [[GADMediationInitializationConfiguration alloc] init];
  adapterConfig.includedAdFormats = [NSSet setWithArray:@[ @(GADAdFormatAppOpen) ]];
  adapterConfig.initializationTimeout = 5.0;  // 5 seconds
  // [END create_ad_format_adapter_init_config]

  return adapterConfig;
}

// Scenario 2: (Specifically include selected adapters)
// Create a config that setIncludedAdapterClasses and an init timeout
- (GADMediationInitializationConfiguration *)createIncludeSpecificAdapterInitConfig {
  // [START create_include_adapter_init_config]
  GADMediationInitializationConfiguration *adapterConfig =
      [[GADMediationInitializationConfiguration alloc] init];
  adapterConfig.includedAdapterClasses = [NSSet setWithArray:@[ @"" ]];
  adapterConfig.initializationTimeout = 5.0;  // 5 seconds
  // [END create_include_adapter_init_config]

  return adapterConfig;
}

// Scenario 3: (Exclude specific adapters)
// Create a config that setExcludedAdapterClasses and an init timeout
- (GADMediationInitializationConfiguration *)createSpecificExclusionAdapterInitConfig {
  // [START create_exclude_adapter_init_config]
  GADMediationInitializationConfiguration *adapterConfig =
      [[GADMediationInitializationConfiguration alloc] init];
  adapterConfig.excludedAdapterClasses = [NSSet setWithArray:@[ _adapterClassName ]];
  adapterConfig.initializationTimeout = 5.0;  // 5 seconds
  // [END create_exclude_adapter_init_config]

  return adapterConfig;
}

- (void)loadAppOpenAdForAdapterInitConfig:
            (GADMediationInitializationConfiguration *)adapterInitializationConfig
                                 adUnitID:(NSString *)adUnitID {
  // [START make_adapter_init_config_request]

  // Initialize the Next-Gen SDK with a config containing your adapter init settings
  [[GADMobileAds sharedInstance]
      startWithMediationInitializationConfiguration:adapterInitializationConfig
                                  completionHandler:^(GADInitializationStatus *_Nonnull status) {
                                    // Make your ad request as soon as adapter initialization
                                    // completes.
                                    GADRequest *request = [GADRequest request];
                                    // Important: Set this to guarantee that the ad request
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
                                           return;
                                         }

                                         // TODO: Your ad logic here
                                         // ....

                                         // Handle necessary, but non time-sensitive tasks after the
                                         // ad has loaded.
                                         [self performPostLaunchSetup];
                                       }];
                                  }];

  // [END make_adapter_init_config_request]
}

- (void)performPostLaunchSetup {
  // [START empty_init_config]

  // Initialize rest of your adapters by providing an empty configuration
  [[GADMobileAds sharedInstance]
      startWithMediationInitializationConfiguration:nil
                                  completionHandler:^(GADInitializationStatus *_Nonnull status) {
                                    // Remaining adapters are now initialized.
                                  }];

  // [END empty_init_config]
}

@end
