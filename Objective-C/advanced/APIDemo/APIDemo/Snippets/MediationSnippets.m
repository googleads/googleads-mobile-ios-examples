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

@import GoogleMobileAds;

@interface MediationSnippets : NSObject
@end

@implementation MediationSnippets

- (void)initializeGoogleMobileAds {
  // [START log_adapter_statuses]
  [[GADMobileAds sharedInstance]
      startWithCompletionHandler:^(GADInitializationStatus *_Nonnull status) {
        // Check each adapter's initialization status.
        NSDictionary<NSString *, GADAdapterStatus *> *adapterStatuses =
            status.adapterStatusesByClassName;
        for (NSString *adapterName in adapterStatuses) {
          GADAdapterStatus *adapterStatus = adapterStatuses[adapterName];
          NSLog(@"Adapter: %@, Description: %@, Latency: %f", adapterName,
                adapterStatus.description, adapterStatus.latency);
        }
      }];
  // [END log_adapter_statuses]
}

@end
