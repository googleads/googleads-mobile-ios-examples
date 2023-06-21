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

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// The Google Mobile Ads SDK provides the User Messaging Platform (Google's
/// IAB Certified consent management platform) as one solution to capture
/// consent for users in GDPR impacted countries. This is an example and
/// you can choose another consent management platform to capture consent.
@interface GoogleMobileAdsConsentManager : NSObject

@property(class, atomic, readonly, strong, nonnull) GoogleMobileAdsConsentManager *sharedInstance;
@property(nonatomic, readonly) BOOL canRequestAds;
@property(nonatomic, readonly) BOOL isFormAvailable;

/// Helper method to call the UMP SDK methods to request consent information and load/present a
/// consent form if necessary.
///
/// @param viewController The view controller to present the user consent form on screen.
/// @param completionHandler The block to execute after consent gathering finishes.
- (void)gatherConsentFromConsentPresentationViewController:(UIViewController *)viewController
                                  consentGatheringComplete:
                                      (void (^)(NSError *_Nullable error))completionHandler;

/// Helper method to call the UMP SDK method to present the privacy options form.
///
/// Attempts to load a new privacy options form upon completion.
///
/// @param viewController The view controller to present the privacy options form on screen.
/// @param completionHandler The block to execute after the presentation finishes.
- (void)presentPrivacyOptionsFormFromViewController:(UIViewController *)viewController
                                  completionHandler:
                                      (void (^)(NSError *_Nullable error))completionHandler;

@end

NS_ASSUME_NONNULL_END
