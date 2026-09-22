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

#import "PictureInPictureAdManager.h"

#import "Constants.h"

@interface PictureInPictureAdManager ()

@property(nonatomic, readwrite, nullable) GADPictureInPictureAd *pipAd;

@end

@implementation PictureInPictureAdManager

+ (instancetype)sharedInstance {
  static PictureInPictureAdManager *sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[PictureInPictureAdManager alloc] init];
  });
  return sharedInstance;
}

- (void)loadAdWithCompletionHandler:(nullable void (^)(GADPictureInPictureAd *_Nullable ad,
                                                       NSError *_Nullable error))completionHandler {
  GADRequest *request = [GADRequest request];
  __weak typeof(self) weakSelf = self;
  [GADPictureInPictureAd
       loadWithAdUnitID:AdUnitIDPictureInPicture
                request:request
      completionHandler:^(GADPictureInPictureAd *_Nullable ad, NSError *_Nullable error) {
        typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
          if (completionHandler) {
            completionHandler(ad, error);
          }
          return;
        }

        if (error) {
          NSLog(@"Picture-in-Picture ad failed to load: %@", error.localizedDescription);
          if (completionHandler) {
            completionHandler(nil, error);
          }
          return;
        }

        NSLog(@"Picture-in-Picture ad loaded.");
        [strongSelf.pipAd hide];
        strongSelf.pipAd = ad;
        [strongSelf setAdEventCallback:ad];
        if (completionHandler) {
          completionHandler(ad, nil);
        }
      }];
}

- (void)showAdWithOptions:(GADPictureInPictureAdOptions *)options {
  if (!self.pipAd) {
    NSLog(@"No Picture-in-Picture ad available to show.");
    return;
  }
  [self.pipAd showWithOptions:options];
}

- (void)hideAd {
  [self.pipAd hide];
}

- (void)destroyAd {
  [self.pipAd hide];
  self.pipAd = nil;
}

- (BOOL)isAdAvailable {
  return self.pipAd != nil;
}

- (void)setAdEventCallback:(GADPictureInPictureAd *)ad {
  ad.delegate = self;
  ad.paidEventHandler = ^(GADAdValue *value) {
    NSLog(@"Picture-in-Picture ad paid: %@ %@", value.value, value.currencyCode);
  };
}

#pragma mark - GADPictureInPictureAdDelegate

- (void)pictureInPictureAdDidShow:(GADPictureInPictureAd *)pictureInPictureAd {
  NSLog(@"Picture-in-Picture ad shown.");
  if (self.onAdShownListener) {
    self.onAdShownListener();
  }
}

- (void)pictureInPictureAdDidHide:(GADPictureInPictureAd *)pictureInPictureAd {
  NSLog(@"Picture-in-Picture ad hidden.");
  if (self.onAdHiddenListener) {
    self.onAdHiddenListener();
  }
}

- (void)pictureInPictureAdDidFailToShow:(GADPictureInPictureAd *)pictureInPictureAd
                              withError:(NSError *)error {
  NSLog(@"Picture-in-Picture ad failed to show: %@", error.localizedDescription);
}

- (void)pictureInPictureAdDidRecordImpression:(GADPictureInPictureAd *)pictureInPictureAd {
  NSLog(@"Picture-in-Picture ad recorded an impression.");
}

- (void)pictureInPictureAdDidRecordClick:(GADPictureInPictureAd *)pictureInPictureAd {
  NSLog(@"Picture-in-Picture ad recorded a click.");
}

- (void)pictureInPictureAdWillPresentScreen:(GADPictureInPictureAd *)pictureInPictureAd {
  NSLog(@"Picture-in-Picture ad will present screen.");
}

- (void)pictureInPictureAdWillDismissScreen:(GADPictureInPictureAd *)pictureInPictureAd {
  NSLog(@"Picture-in-Picture ad will dismiss screen.");
}

- (void)pictureInPictureAdDidDismissScreen:(GADPictureInPictureAd *)pictureInPictureAd {
  NSLog(@"Picture-in-Picture ad dismissed screen.");
}

@end
