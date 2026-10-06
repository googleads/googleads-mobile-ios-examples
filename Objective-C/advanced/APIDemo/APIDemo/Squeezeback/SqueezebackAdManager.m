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
  GADRequest *request = [GADRequest request];
  __weak typeof(self) weakSelf = self;
  [GADSqueezebackAd loadWithAdUnitID:AdUnitIDSqueezeback
                             request:request
                   completionHandler:^(GADSqueezebackAd *_Nullable ad, NSError *_Nullable error) {
                     typeof(self) strongSelf = weakSelf;
                     if (!strongSelf) {
                       if (completionHandler) {
                         completionHandler(ad, error);
                       }
                       return;
                     }

                     if (error) {
                       NSLog(@"Squeezeback ad failed to load: %@", error.localizedDescription);
                       if (completionHandler) {
                         completionHandler(nil, error);
                       }
                       return;
                     }

                     NSLog(@"Squeezeback ad loaded.");
                     [strongSelf.squeezebackAd hide];
                     strongSelf.squeezebackAd = ad;
                     [strongSelf setAdEventCallback:ad];
                     if (completionHandler) {
                       completionHandler(ad, nil);
                     }
                   }];
}

- (void)showAd {
  if (!self.squeezebackAd) {
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
  [self.squeezebackAd hide];
  self.squeezebackAd = nil;
}

- (BOOL)isAdAvailable {
  return self.squeezebackAd != nil;
}

- (void)setAdEventCallback:(GADSqueezebackAd *)ad {
  ad.delegate = self;
  ad.paidEventHandler = ^(GADAdValue *value) {
    NSLog(@"Squeezeback ad paid: %@ %@", value.value, value.currencyCode);
  };
}

#pragma mark - GADSqueezebackAdDelegate

- (void)squeezebackAdDidShow:(GADSqueezebackAd *)squeezebackAd {
  NSLog(@"Squeezeback ad shown.");
  if (self.onAdShownListener) {
    self.onAdShownListener();
  }
}

- (void)squeezebackAdDidHide:(GADSqueezebackAd *)squeezebackAd {
  NSLog(@"Squeezeback ad hidden.");
  if (self.onAdHiddenListener) {
    self.onAdHiddenListener();
  }
}

- (void)squeezebackAdDidFailToShow:(GADSqueezebackAd *)squeezebackAd withError:(NSError *)error {
  NSLog(@"Squeezeback ad failed to show: %@", error.localizedDescription);
}

- (void)squeezebackAdDidRecordImpression:(GADSqueezebackAd *)squeezebackAd {
  NSLog(@"Squeezeback ad recorded an impression.");
}

- (void)squeezebackAdDidRecordClick:(GADSqueezebackAd *)squeezebackAd {
  NSLog(@"Squeezeback ad recorded a click.");
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
