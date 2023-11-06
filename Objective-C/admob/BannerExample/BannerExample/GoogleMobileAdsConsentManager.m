//
//  Copyright 2023 Google LLC
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

#import "GoogleMobileAdsConsentManager.h"

#import <GoogleMobileAds/GoogleMobileAds.h>
#import <UserMessagingPlatform/UserMessagingPlatform.h>


@implementation GoogleMobileAdsConsentManager

+ (instancetype)sharedInstance {
  static GoogleMobileAdsConsentManager *shared;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    shared = [[GoogleMobileAdsConsentManager alloc] init];
  });
  return shared;
}

- (BOOL)canRequestAds {
  return UMPConsentInformation.sharedInstance.canRequestAds;
}

- (BOOL)isPrivacyOptionsRequired {
  return UMPConsentInformation.sharedInstance.privacyOptionsRequirementStatus ==
         UMPPrivacyOptionsRequirementStatusRequired;
}

- (void)gatherConsentFromConsentPresentationViewController:(UIViewController *)viewController
                                  consentGatheringComplete:
                                      (void (^)(NSError *_Nullable))consentGatheringComplete {
  UMPRequestParameters *parameters = [[UMPRequestParameters alloc] init];

  // For testing purposes, you can force a UMPDebugGeography of EEA or not EEA.
  UMPDebugSettings *debugSettings = [[UMPDebugSettings alloc] init];
  // debugSettings.geography = UMPDebugGeographyEEA;
  parameters.debugSettings = debugSettings;

  // Requesting an update to consent information should be called on every app launch.
  [UMPConsentInformation.sharedInstance
      requestConsentInfoUpdateWithParameters:parameters
                           completionHandler:^(NSError *_Nullable requestConsentError) {
                             if (requestConsentError) {
                               consentGatheringComplete(requestConsentError);
                             } else {
                               [UMPConsentForm
                                   loadAndPresentIfRequiredFromViewController:viewController
                                                            completionHandler:^(
                                                                NSError
                                                                    *_Nullable loadAndPresentError) {
                                                              // Consent has been gathered.
                                                              consentGatheringComplete(
                                                                  loadAndPresentError);
                                                            }];
                             }
                           }];
}

- (void)presentPrivacyOptionsFormFromViewController:(UIViewController *)viewController
                                  completionHandler:
                                      (void (^)(NSError *_Nullable))completionHandler {
  [UMPConsentForm presentPrivacyOptionsFormFromViewController:viewController
                                            completionHandler:completionHandler];
}

@end
