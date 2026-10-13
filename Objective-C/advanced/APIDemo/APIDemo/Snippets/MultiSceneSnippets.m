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

#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <UIKit/UIKit.h>

@interface MultiSceneSnippets : UIViewController

@property(nonatomic, strong) GADInterstitialAd *interstitial;
@property(nonatomic, strong) GAMInterstitialAd *adManagerInterstitial;

@end

@implementation MultiSceneSnippets {
  BOOL _requestInitialized;
}

// [START load_interstitial]
- (void)loadInterstitial {
  GADRequest *request = [GADRequest request];
  request.scene = self.view.window.windowScene;

  [GADInterstitialAd
       loadWithAdUnitID:@"ca-app-pub-3940256099942544/4411468910"
                request:request
      completionHandler:^(GADInterstitialAd *ad, NSError *error) {
        if (error) {
          NSLog(@"Failed to load interstitial ad with error: %@", [error localizedDescription]);
          return;
        }
        self.interstitial = ad;
      }];
}
// [END load_interstitial]

// [START load_interstitial_gam]
- (void)loadAdManagerInterstitial {
  GAMRequest *request = [GAMRequest request];
  request.scene = self.view.window.windowScene;

  [GAMInterstitialAd loadWithAdManagerAdUnitID:@"/21775744923/example/interstitial"
                                       request:request
                             completionHandler:^(GAMInterstitialAd *ad, NSError *error) {
                               if (error) {
                                 NSLog(@"Failed to load interstitial ad with error: %@",
                                       [error localizedDescription]);
                                 return;
                               }
                               self.adManagerInterstitial = ad;
                             }];
}
// [END load_interstitial_gam]

// [START view_did_appear]
- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  if (!_requestInitialized) {
    [self loadInterstitial];
    _requestInitialized = YES;
  }
}
// [END view_did_appear]

// [START fullscreen_view_will_transition]
- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
  [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

  [coordinator
      animateAlongsideTransition:nil
                      completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
                        if (![self.interstitial canPresentFromRootViewController:self error:nil]) {
                          [self loadInterstitial];
                        }
                      }];
}
// [END fullscreen_view_will_transition]

@end

@interface MultiSceneBannerSnippets : UIViewController

@property(nonatomic, strong) GADBannerView *bannerView;

@end

@implementation MultiSceneBannerSnippets

// [START banner_view_will_transition]
- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
  [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

  [coordinator
      animateAlongsideTransition:nil
                      completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
                        [self loadBannerAd];
                      }];
}

- (void)loadBannerAd {
  dispatch_async(dispatch_get_main_queue(), ^{
    CGRect frame = UIEdgeInsetsInsetRect(self.view.frame, self.view.safeAreaInsets);
    CGFloat viewWidth = frame.size.width;

    self.bannerView.adSize = GADLargeAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth);

    GADRequest *request = [GADRequest request];
    request.scene = self.view.window.windowScene;
    [self.bannerView loadRequest:request];
  });
}
// [END banner_view_will_transition]

@end

@interface MultiSceneAdManagerBannerSnippets : UIViewController

@property(nonatomic, strong) GAMBannerView *bannerView;

@end

@implementation MultiSceneAdManagerBannerSnippets

// [START banner_view_will_transition_gam]
- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
  [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

  [coordinator
      animateAlongsideTransition:nil
                      completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
                        [self loadBannerAd];
                      }];
}

- (void)loadBannerAd {
  dispatch_async(dispatch_get_main_queue(), ^{
    CGRect frame = UIEdgeInsetsInsetRect(self.view.frame, self.view.safeAreaInsets);
    CGFloat viewWidth = frame.size.width;

    self.bannerView.adSize = GADLargeAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth);

    GAMRequest *request = [GAMRequest request];
    request.scene = self.view.window.windowScene;
    [self.bannerView loadRequest:request];
  });
}
// [END banner_view_will_transition_gam]

@end
