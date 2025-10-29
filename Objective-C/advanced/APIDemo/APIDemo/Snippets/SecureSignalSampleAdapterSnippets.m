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

#pragma mark - YourSDK

/**
 * A mock SDK class used for demonstration purposes in code snippets. In a real adapter
 * implementation, you would replace calls to this class with calls to your actual SDK.
 */
@interface YourSDK : NSObject

/** Mock SDK initialization method. */
+ (void)initializeSDK;

/**
 * Mock SDK version retrieval method.
 *
 * @return The mock SDK version string.
 */
+ (NSString *)version;

/**
 * Mock SDK asynchronous signal collection method.
 *
 * @param handler A block to call with the collected signal.
 */
+ (void)collectSignalsWithCompletionHandler:(void (^)(NSString *_Nullable signal))handler;

@end

static NSString *const kYourSDKVersion = @"1.2.3";
static NSString *const kYourMockSignal = @"sample_signal";

@implementation YourSDK

+ (void)initializeSDK {
  // No-op for mock.
}

+ (NSString *)version {
  return kYourSDKVersion;
}

+ (void)collectSignalsWithCompletionHandler:(void (^)(NSString *_Nullable signal))handler {
  // Simulate an async operation completing after 0.1 seconds.
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)),
                 dispatch_get_main_queue(), ^{
                   handler(kYourMockSignal);
                 });
}

@end

#pragma mark - SecureSignalSampleAdapterSnippets

@interface SecureSignalSampleAdapterSnippets : NSObject <GADRTBAdapter>
@end

@implementation SecureSignalSampleAdapterSnippets

// [START set_up_with_configuration]
+ (void)setUpWithConfiguration:(GADMediationServerConfiguration *)configuration
             completionHandler:(GADMediationAdapterSetUpCompletionBlock)completionHandler {
  // Initialize your ad network's SDK.
  [YourSDK initializeSDK];

  // Invoke the completionHandler once initialization completes. Pass a nil
  // error to indicate initialization succeeded.
  completionHandler(nil);
}
// [END set_up_with_configuration]

// [START sdk_adapter_version]
+ (GADVersionNumber)adapterVersion {
  // If your secure signals SDK implements this adapter in the same binary,
  // return the same version as your SDK.
  // return [self adSDKVersion];

  // If you built a separate binary for this secure signals adapter, return
  // the adapter's version. Example adapter version 4.5.6:
  GADVersionNumber version = {};
  version.majorVersion = 4;
  version.minorVersion = 5;
  version.patchVersion = 6;
  return version;
}
// [END sdk_adapter_version]

// [START sdk_version]
+ (GADVersionNumber)adSDKVersion {
  NSString *versionString = [YourSDK version];
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
  // This example assumes your SDK has an asynchronous method to get a signal string.
  [YourSDK collectSignalsWithCompletionHandler:^(NSString *_Nullable signal) {
    handler(signal, nil);
  }];
}
// [END collect_signals]

// [START network_extras_class]
+ (nullable Class<GADAdNetworkExtras>)networkExtrasClass {
  // If your adapter required extra parameters, you would return an instance of your class here.
  // Example: return [YourNetworkExtras class];
  return Nil;
}
// [END network_extras_class]

@end

NS_ASSUME_NONNULL_END
