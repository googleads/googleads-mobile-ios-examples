//
//  Copyright (C) 2014 Google LLC
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

@interface GoogleMobileAdsConsentManager ()

/// The UMP SDK consent form.
@property(nonatomic, strong) UMPConsentForm *form;

@end

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
  return UMPConsentInformation.sharedInstance.consentStatus == UMPConsentStatusNotRequired ||
         UMPConsentInformation.sharedInstance.consentStatus == UMPConsentStatusObtained;
}

- (BOOL)isFormAvailable {
  return UMPConsentInformation.sharedInstance.formStatus == UMPFormStatusAvailable;
}

- (void)gatherConsentFromConsentPresentationViewController:(UIViewController *)viewController
                                  consentGatheringComplete:
                                      (void (^)(NSError *_Nullable))consentGatheringComplete {
  UMPRequestParameters *parameters = [[UMPRequestParameters alloc] init];

  // For testing purposes, you can force a UMPDebugGeography of EEA or not EEA.
  UMPDebugSettings *debugSettings = [[UMPDebugSettings alloc] init];
  // debugSettings.geography = UMPDebugGeographyEEA;
  parameters.debugSettings = debugSettings;

  __weak __typeof__(self) weakSelf = self;
  // Requesting an update to consent information should be called on every app launch.
  [UMPConsentInformation.sharedInstance
      requestConsentInfoUpdateWithParameters:parameters
                           completionHandler:^(NSError *_Nullable requestConsentError) {
                             if (requestConsentError) {
                               consentGatheringComplete(requestConsentError);
                             } else {
                               [weakSelf handleRequestConsentInfoFromViewController:viewController
                                                                  completionHandler:
                                                                      consentGatheringComplete];
                             }
                           }];
}

- (void)handleRequestConsentInfoFromViewController:(UIViewController *_Nonnull)viewController
                                 completionHandler:
                                     (void (^_Nonnull)(NSError *_Nullable))completionHandler {
  __weak __typeof__(self) weakSelf = self;
  [self loadAndPresentFormFromViewControllerIfRequired:viewController
                                     completionHandler:^(NSError *_Nullable loadAndPresentError) {
                                       // Consent has been gathered.
                                       completionHandler(loadAndPresentError);
                                       // Your app needs to allow the user to change their consent
                                       // status at any time. Load another form and store it so
                                       // it's ready to be displayed immediately after the user
                                       // clicks your app's privacy settings button.
                                       [weakSelf loadPrivacyOptionsFormIfRequired];
                                     }];
}

- (void)loadAndPresentFormFromViewControllerIfRequired:(UIViewController *)viewController
                                     completionHandler:
                                         (void (^)(NSError *_Nullable))completionHandler {
  // Determine the consent-related action to take based on the UMPConsentStatus.
  if (UMPConsentInformation.sharedInstance.consentStatus == UMPConsentStatusNotRequired ||
      UMPConsentInformation.sharedInstance.consentStatus == UMPConsentStatusObtained) {
    // Consent has already been gathered or not required.
    completionHandler(nil);
    return;
  }

  [UMPConsentForm loadWithCompletionHandler:^(UMPConsentForm *_Nullable consentForm,
                                              NSError *_Nullable loadError) {
    if (loadError) {
      completionHandler(loadError);
    } else {
      [consentForm presentFromViewController:viewController
                           completionHandler:^(NSError *_Nullable formError) {
                             completionHandler(formError);
                           }];
    }
  }];
}

- (void)loadPrivacyOptionsFormIfRequired {
  // No privacy options form needed if consent form is not available.
  if (!self.isFormAvailable) {
    return;
  }

  __weak __typeof__(self) weakSelf = self;
  [UMPConsentForm loadWithCompletionHandler:^(UMPConsentForm *_Nullable consentForm,
                                              NSError *_Nullable loadError) {
    if (loadError) {
      // See UMPFormErrorCode for more info.
      return NSLog(@"Error: %@", [loadError localizedDescription]);
    } else {
      weakSelf.form = consentForm;
    }
  }];
}

- (void)presentPrivacyOptionsFormFromViewController:(UIViewController *)viewController
                                  completionHandler:
                                      (void (^)(NSError *_Nullable))completionHandler {
  if (!self.form) {
    completionHandler([NSError
        errorWithDomain:@"com.google"
                   code:0
               userInfo:@{NSLocalizedDescriptionKey : @"No form available."}]);

    // Your app needs to allow the user to change their consent status at any
    // time. Load another form and store it so it's ready to be displayed
    // immediately after the user clicks your app's privacy settings button.
    [self loadPrivacyOptionsFormIfRequired];
    return;
  }

  [self.form presentFromViewController:viewController
                     completionHandler:^(NSError *_Nullable formError) {
                       completionHandler(formError);

                       // Your app needs to allow the user to change their consent status at any
                       // time. Load another form and store it so it's ready to be displayed
                       // immediately after the user clicks your app's privacy settings button.
                       [self loadPrivacyOptionsFormIfRequired];
                     }];
}

@end
