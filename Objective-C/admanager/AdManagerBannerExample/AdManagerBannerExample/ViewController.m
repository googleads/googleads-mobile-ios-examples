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

#import "ViewController.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "GoogleMobileAdsConsentManager.h"
#import "ViewController.h"

@interface ViewController () <GADBannerViewDelegate>

@property(nonatomic, weak) IBOutlet GAMBannerView *bannerView;
@property(weak, nonatomic) IBOutlet UIBarButtonItem *privacySettingsButton;
@property(weak, nonatomic) IBOutlet UIBarButtonItem *adInspectorButton;

@end

@implementation ViewController

- (IBAction)privacySettingsTapped:(UIBarButtonItem *)sender {
  [GoogleMobileAdsConsentManager.sharedInstance
      presentPrivacyOptionsFormFromViewController:self
                                completionHandler:^(NSError *_Nullable formError) {
                                  if (formError) {
                                    UIAlertController *alertController = [UIAlertController
                                        alertControllerWithTitle:formError.localizedDescription
                                                         message:@"Please try again later."
                                                  preferredStyle:UIAlertControllerStyleAlert];
                                    UIAlertAction *defaultAction =
                                        [UIAlertAction actionWithTitle:@"OK"
                                                                 style:UIAlertActionStyleCancel
                                                               handler:^(UIAlertAction *action){
                                                               }];

                                    [alertController addAction:defaultAction];
                                    [self presentViewController:alertController
                                                       animated:YES
                                                     completion:nil];
                                  }
                                }];
}

- (IBAction)adInspectorTapped:(UIBarButtonItem *)sender {
  [GADMobileAds.sharedInstance
      presentAdInspectorFromViewController:self
                         completionHandler:^(NSError *_Nullable error) {
                           if (error) {
                             UIAlertController *alertController = [UIAlertController
                                 alertControllerWithTitle:error.localizedDescription
                                                  message:@"Please try again later."
                                           preferredStyle:UIAlertControllerStyleAlert];
                             UIAlertAction *defaultAction =
                                 [UIAlertAction actionWithTitle:@"OK"
                                                          style:UIAlertActionStyleCancel
                                                        handler:^(UIAlertAction *action){
                                                        }];

                             [alertController addAction:defaultAction];
                             [self presentViewController:alertController
                                                animated:YES
                                              completion:nil];
                           }
                         }];
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.bannerView.rootViewController = self;
  // [START banner_view_delegate]
  self.bannerView.delegate = self;
  // [END banner_view_delegate]

  // Replace this ad unit ID with your own ad unit ID.
  self.bannerView.adUnitID = @"/21775744923/example/adaptive-banner";

  __weak __typeof__(self) weakSelf = self;
  [GoogleMobileAdsConsentManager.sharedInstance
      gatherConsentFromConsentPresentationViewController:self
                                consentGatheringComplete:^(NSError *_Nullable consentError) {
                                  if (consentError) {
                                    // Consent gathering failed.
                                    NSLog(@"Error: %@", consentError.localizedDescription);
                                  }

                                  __strong __typeof__(self) strongSelf = weakSelf;
                                  if (!strongSelf) {
                                    return;
                                  }

                                  if (GoogleMobileAdsConsentManager.sharedInstance.canRequestAds) {
                                    [strongSelf startGoogleMobileAdsSDK];
                                  }

                                  strongSelf.privacySettingsButton.enabled =
                                      GoogleMobileAdsConsentManager.sharedInstance
                                          .isPrivacyOptionsRequired;
                                }];

  // This sample attempts to load ads using consent obtained in the previous session.
  if (GoogleMobileAdsConsentManager.sharedInstance.canRequestAds) {
    [self startGoogleMobileAdsSDK];
  }
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
  [coordinator
      animateAlongsideTransition:^(
          id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        if (GoogleMobileAdsConsentManager.sharedInstance.canRequestAds) {
          [self loadBannerAd];
        }
      }
                      completion:nil];
}

- (void)startGoogleMobileAdsSDK {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    // [START initialize_sdk]
    // Initialize the Google Mobile Ads SDK.
    [GADMobileAds.sharedInstance startWithCompletionHandler:nil];
    // [END initialize_sdk]
    [self loadBannerAd];
  });
}

- (void)loadBannerAd {
  // Note that Google may serve any reservation ads that that are smaller than
  // the adaptive size as outlined here - https://support.google.com/admanager/answer/9464128.
  // The returned ad will be centered in the ad view.

  // [START ad_size]
  // Request an anchored adaptive banner with a width of 375.
  self.bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(375);
  // [END ad_size]

  // [START load_ad]
  [self.bannerView loadRequest:[GAMRequest request]];
  // [END load_ad]
}

#pragma mark GADBannerViewDelegate implementation

// [START banner_view_delegate_methods]
- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView {
  NSLog(@"bannerViewDidReceiveAd");
}

- (void)bannerView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error {
  NSLog(@"bannerView:didFailToReceiveAdWithError: %@", [error localizedDescription]);
}

- (void)bannerViewDidRecordImpression:(GADBannerView *)bannerView {
  NSLog(@"bannerViewDidRecordImpression");
}

- (void)bannerViewWillPresentScreen:(GADBannerView *)bannerView {
  NSLog(@"bannerViewWillPresentScreen");
}

- (void)bannerViewWillDismissScreen:(GADBannerView *)bannerView {
  NSLog(@"bannerViewWillDismissScreen");
}

- (void)bannerViewDidDismissScreen:(GADBannerView *)bannerView {
  NSLog(@"bannerViewDidDismissScreen");
}
// [END banner_view_delegate_methods]

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
