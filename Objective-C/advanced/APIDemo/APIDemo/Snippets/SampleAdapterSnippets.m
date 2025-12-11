// Copyright 2025 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

NS_ASSUME_NONNULL_BEGIN

// [START implement_adapter_protocol]
@interface SampleAdapterSnippets : NSObject <GADRTBAdapter>
@end
// [END implement_adapter_protocol]

@implementation SampleAdapterSnippets

static NSString *const kSDKVersionString = @"1.2.3";
static NSString *const kSampleSignalPlaceholder = @"your_sdk_secure_signal_string";

#pragma mark - GADRTBAdapter Protocol Methods

// [START set_up_with_configuration]
+ (void)setUpWithConfiguration:(GADMediationServerConfiguration *)configuration
             completionHandler:(GADMediationAdapterSetUpCompletionBlock)completionHandler {
  // Add your SDK initialization logic here.

  // Invoke the completionHandler once initialization completes. Pass a nil
  // error to indicate initialization succeeded.
  completionHandler(nil);
}
// [END set_up_with_configuration]

// [START sdk_adapter_version]
+ (GADVersionNumber)adapterVersion {
  // If your secure signals SDK implements this adapter in the same binary
  // return the same version as your SDK.
  // return [self adSDKVersion];

  // If you built a separate binary for this secure signals adapter, return
  // the adapter's version here.
  GADVersionNumber version = {};
  version.majorVersion = 4;
  version.minorVersion = 5;
  version.patchVersion = 6;
  return version;
}
// [END sdk_adapter_version]

// [START sdk_version]
+ (GADVersionNumber)adSDKVersion {
  // Return your SDK's version string here.
  NSString *versionString = kSDKVersionString;
  NSArray<NSString *> *components = [versionString componentsSeparatedByString:@"."];
  GADVersionNumber version = {};
  if (components.count == 3) {
    version.majorVersion = components[0].integerValue;
    version.minorVersion = components[1].integerValue;
    version.patchVersion = components[2].integerValue;
  } else {
    NSLog(@"Unexpected version string: %@. Returning 0.0.0 for adSDKVersion.", versionString);
  }
  return version;
}
// [END sdk_version]

// [START collect_signals]
- (void)collectSignalsForRequestParameters:(GADRTBRequestParameters *)params
                         completionHandler:(GADRTBSignalCompletionHandler)handler {
  // Add your signal collection logic here.
  NSString *signals = kSampleSignalPlaceholder;

  // Return the signals as a string to the Google Mobile Ads SDK.
  handler(signals, nil);
}
// [END collect_signals]

// [START network_extras_class]
+ (nullable Class<GADAdNetworkExtras>)networkExtrasClass {
  // Network extras are not applicable because signal providers do not request ads.
  return nil;
}
// [END network_extras_class]

@end

NS_ASSUME_NONNULL_END
