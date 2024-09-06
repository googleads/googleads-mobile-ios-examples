// Copyright 2024 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "MainViewController.h"

#import <GoogleMobileAds/GoogleMobileAds.h>

#import "GoogleMobileAdsConsentManager.h"
#import "NativeAdViewController.h"

@interface MainViewController () <GADNativeAdLoaderDelegate>

// You must keep a strong reference to the GADAdLoader during the ad loading process.
@property(strong, nonatomic) GADAdLoader *adLoader;

@property(weak, nonatomic) IBOutlet UIBarButtonItem *privacySettingsButton;
@property(weak, nonatomic) IBOutlet UIBarButtonItem *adInspectorButton;
@property(weak, nonatomic) IBOutlet UIButton *loadAdButton;
@property(weak, nonatomic) IBOutlet UIButton *showAdButton;

@property(strong, nonatomic) GADNativeAd *nativeAd;

@end

@implementation MainViewController

- (void)viewDidLoad {
  [super viewDidLoad];

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

                                  [strongSelf.loadAdButton
                                      setEnabled:GoogleMobileAdsConsentManager.sharedInstance
                                                     .canRequestAds];

                                  strongSelf.privacySettingsButton.enabled =
                                      GoogleMobileAdsConsentManager.sharedInstance
                                          .isPrivacyOptionsRequired;
                                }];

  // This sample attempts to load ads using consent obtained in the previous session.
  if (GoogleMobileAdsConsentManager.sharedInstance.canRequestAds) {
    [self startGoogleMobileAdsSDK];
  }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  // Pass the native ad to the full-screen native ad view controller.
  if ([segue.destinationViewController isKindOfClass:[NativeAdViewController class]]) {
    NativeAdViewController *viewController =
        (NativeAdViewController *)segue.destinationViewController;
    viewController.nativeAd = self.nativeAd;
  }
}

- (void)startGoogleMobileAdsSDK {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    // Initialize the Google Mobile Ads SDK.
    [GADMobileAds.sharedInstance startWithCompletionHandler:nil];

    // Configure the ad loader.
    GADNativeAdMediaAdLoaderOptions *mediaLoaderOptions =
        [[GADNativeAdMediaAdLoaderOptions alloc] init];
    mediaLoaderOptions.mediaAspectRatio = GADMediaAspectRatioPortrait;
    self.adLoader = [[GADAdLoader alloc] initWithAdUnitID:@"ca-app-pub-3940256099942544/5406332512"
                                       rootViewController:nil
                                                  adTypes:@[ GADAdLoaderAdTypeNative ]
                                                  options:@[ mediaLoaderOptions ]];
    self.adLoader.delegate = self;
  });
}

- (IBAction)privacySettingsButtonPressed:(UIBarButtonItem *)sender {
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
                                                               handler:nil];

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

- (IBAction)loadAdButtonPressed:(UIButton *)sender {
  self.loadAdButton.enabled = NO;
  self.showAdButton.enabled = NO;

  [self.adLoader loadRequest:[GADRequest request]];
}

- (IBAction)showAdButtonPressed:(UIButton *)sender {
  self.loadAdButton.enabled = YES;
  self.showAdButton.enabled = NO;
}

#pragma mark GADAdLoaderDelegate implementation

- (void)adLoader:(GADAdLoader *)adLoader didReceiveNativeAd:(GADNativeAd *)nativeAd {
  self.nativeAd = nativeAd;
  self.showAdButton.enabled = YES;
}

- (void)adLoader:(GADAdLoader *)adLoader didFailToReceiveAdWithError:(NSError *)error {
  NSLog(@"%@ failed with error: %@", adLoader, error);
  self.loadAdButton.enabled = YES;
}

@end
