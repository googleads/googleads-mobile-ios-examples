//
//  Copyright 2014-2023 Google LLC
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

@interface ViewController () <GADBannerViewDelegate>

@property(nonatomic, weak) IBOutlet GADBannerView *bannerView;
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

  // Replace this ad unit ID with your own ad unit ID.
  self.bannerView.adUnitID = @"ca-app-pub-3940256099942544/2435281174";
  self.bannerView.rootViewController = self;
  self.bannerView.delegate = self;

  __weak __typeof__(self) weakSelf = self;
  // [START can_request_ads]
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
                                  // [START_EXCLUDE]

                                  // [START add_privacy_options]
                                  strongSelf.privacySettingsButton.enabled =
                                      GoogleMobileAdsConsentManager.sharedInstance
                                          .isPrivacyOptionsRequired;
                                  // [END add_privacy_options]
                                  // [END_EXCLUDE]
                                }];

  // This sample attempts to load ads using consent obtained in the previous session.
  if (GoogleMobileAdsConsentManager.sharedInstance.canRequestAds) {
    [self startGoogleMobileAdsSDK];
  }
  // [END can_request_ads]
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  // Attempting to load adaptive banner ads is handled in viewDidAppear as this is the first
  // time that the safe area is known. If safe area is not a concern (eg your app is locked in
  // portrait mode) the banner can be loaded in viewDidLoad.
  if (GoogleMobileAdsConsentManager.sharedInstance.canRequestAds) {
    [self loadBannerAd];
  }
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
  [coordinator
      animateAlongsideTransition:^(
          id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        [self loadBannerAd];
      }
                      completion:nil];
}

// [START request_ads]
- (void)startGoogleMobileAdsSDK {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    // Initialize the Google Mobile Ads SDK.
    [GADMobileAds.sharedInstance startWithCompletionHandler:nil];
    [self loadBannerAd];
  });
}
// [END request_ads]

- (void)loadBannerAd {
  // Here safe area is taken into account, hence the view frame is used after the
  // view has been laid out.
  CGRect frame = UIEdgeInsetsInsetRect(self.view.frame, self.view.safeAreaInsets);
  CGFloat viewWidth = frame.size.width;

  // Here the current interface orientation is used. If the ad is being preloaded
  // for a future orientation change or different orientation, the function for the
  // relevant orientation should be used.
  self.bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth);

  [self.bannerView loadRequest:[GADRequest request]];
}

#pragma mark GADBannerViewDelegate implementation

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

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
