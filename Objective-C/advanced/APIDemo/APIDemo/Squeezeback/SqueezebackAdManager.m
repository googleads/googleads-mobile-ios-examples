//
//  Copyright 2026 Google LLC
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

#import "SqueezebackAdManager.h"

#import "Constants.h"

@interface SqueezebackAdManager ()

@property(nonatomic, readwrite, nullable) GADSqueezebackAd *squeezebackAd;
@property(nonatomic, readwrite, getter=isAdShowing) BOOL adShowing;

@end

@implementation SqueezebackAdManager

+ (instancetype)sharedInstance {
  static SqueezebackAdManager *sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[SqueezebackAdManager alloc] init];
  });
  return sharedInstance;
}

- (void)loadAdWithCompletionHandler:(nullable void (^)(GADSqueezebackAd *_Nullable ad,
                                                       NSError *_Nullable error))completionHandler {
  if (self.isAdShowing) {
    NSString *message = @"Cannot load a new squeezeback ad while one is currently showing.";
    NSLog(@"%@", message);
    if (completionHandler) {
      NSError *error = [NSError errorWithDomain:@"com.google.APIDemo.SqueezebackAdManager"
                                           code:1
                                       userInfo:@{NSLocalizedDescriptionKey : message}];
      completionHandler(nil, error);
    }
    return;
  }

  GADRequest *request = [GADRequest request];
  __weak __typeof__(self) weakSelf = self;
  [GADSqueezebackAd loadWithAdUnitID:AdUnitIDSqueezeback
                             request:request
                   completionHandler:^(GADSqueezebackAd *_Nullable ad, NSError *_Nullable error) {
                     [weakSelf handleLoadedAd:ad error:error completionHandler:completionHandler];
                   }];
}

- (void)handleLoadedAd:(nullable GADSqueezebackAd *)ad
                 error:(nullable NSError *)error
     completionHandler:(nullable void (^)(GADSqueezebackAd *_Nullable ad,
                                          NSError *_Nullable error))completionHandler {
  if (self.isAdShowing) {
    return;
  }
  if (error) {
    NSLog(@"Squeezeback ad failed to load: %@", error.localizedDescription);
  } else {
    NSLog(@"Squeezeback ad loaded.");
    [self.squeezebackAd hide];
    self.squeezebackAd = ad;
    self.squeezebackAd.delegate = self;
  }
  if (completionHandler) {
    completionHandler(error ? nil : ad, error);
  }
}

- (void)showAd {
  if (!self.squeezebackAd || self.isAdShowing) {
    NSLog(@"No squeezeback ad available to show.");
    return;
  }
  GADSqueezebackAdOptions *options = [[GADSqueezebackAdOptions alloc] init];
  [self.squeezebackAd showWithOptions:options];
}

- (void)hideAd {
  [self.squeezebackAd hide];
}

- (void)destroyAd {
  self.adShowing = NO;
  GADSqueezebackAd *ad = self.squeezebackAd;
  self.squeezebackAd = nil;
  [ad hide];
}

- (BOOL)isAdAvailable {
  return self.squeezebackAd != nil && !self.isAdShowing;
}

#pragma mark - GADSqueezebackAdDelegate

- (void)squeezebackAdDidShow:(GADSqueezebackAd *)squeezebackAd {
  if (self.squeezebackAd != squeezebackAd) {
    return;
  }
  NSLog(@"Squeezeback ad shown.");
  self.adShowing = YES;
  [self.delegate squeezebackAdManagerDidShowAd:self];
}

- (void)squeezebackAdDidHide:(GADSqueezebackAd *)squeezebackAd {
  NSLog(@"Squeezeback ad hidden.");
  if (self.squeezebackAd != squeezebackAd) {
    return;
  }
  self.adShowing = NO;
  self.squeezebackAd = nil;
  [self.delegate squeezebackAdManagerDidHideAd:self];
}

- (void)squeezebackAdDidFailToShow:(GADSqueezebackAd *)squeezebackAd withError:(NSError *)error {
  NSLog(@"Squeezeback ad failed to show: %@", error.localizedDescription);
  if (self.squeezebackAd != squeezebackAd) {
    return;
  }
  self.adShowing = NO;
  [self.delegate squeezebackAdManager:self didFailToShowAdWithError:error];
}

- (void)squeezebackAdDidRecordImpression:(GADSqueezebackAd *)squeezebackAd {
  NSLog(@"Squeezeback ad recorded an impression.");
}

- (void)squeezebackAdDidRecordClick:(GADSqueezebackAd *)squeezebackAd {
  NSLog(@"Squeezeback ad recorded a click.");
}

- (void)squeezebackAd:(GADSqueezebackAd *)squeezebackAd
    didRecordPaidEventWithAdValue:(GADAdValue *)adValue {
  NSLog(@"Squeezeback ad paid: %@ %@", adValue.value, adValue.currencyCode);
}

- (void)squeezebackAdWillPresentScreen:(GADSqueezebackAd *)squeezebackAd {
  NSLog(@"Squeezeback ad will present screen.");
}

- (void)squeezebackAdWillDismissScreen:(GADSqueezebackAd *)squeezebackAd {
  NSLog(@"Squeezeback ad will dismiss screen.");
}

- (void)squeezebackAdDidDismissScreen:(GADSqueezebackAd *)squeezebackAd {
  NSLog(@"Squeezeback ad dismissed screen.");
}

@end
