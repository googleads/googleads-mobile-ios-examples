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

#import "ViewController.h"

#import <GoogleMobileAds/GoogleMobileAds.h>

#import "GoogleMobileAdsConsentManager.h"

typedef NS_ENUM(NSUInteger, GameState) {
  kGameStateNotStarted = 0,  ///< Game has not started.
  kGameStatePlaying = 1,     ///< Game is playing.
  kGameStatePaused = 2,      ///< Game is paused.
  kGameStateEnded = 3        ///< Game has ended.
};

/// The game length.
static const NSInteger kGameLength = 5;

@interface ViewController () <GADFullScreenContentDelegate>

/// The AdManager interstitial ad.
@property(nonatomic, strong) GAMInterstitialAd *interstitial;

/// The countdown timer.
@property(nonatomic, strong) NSTimer *timer;

/// The amount of time left in the game.
@property(nonatomic, assign) NSInteger timeLeft;

/// The state of the game.
@property(nonatomic, assign) GameState gameState;

/// The date that the timer was paused.
@property(nonatomic, strong) NSDate *pauseDate;

/// The last fire date before a pause.
@property(nonatomic, strong) NSDate *previousFireDate;

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  // Sets up a loading spinner while consent is being gathered.
  dispatch_block_t loadingSpinnerBlock = dispatch_block_create(0, ^{
    [self.loadingSpinner startAnimating];
  });
  // Show spinner if loading takes longer than 1 second.
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(),
                 loadingSpinnerBlock);

  // Pause game when application is backgrounded.
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(pauseGame)
                                               name:UIApplicationDidEnterBackgroundNotification
                                             object:nil];

  // Resume game when application becomes active.
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(resumeGame)
                                               name:UIApplicationDidBecomeActiveNotification
                                             object:nil];

  __weak __typeof__(self) weakSelf = self;
  [GoogleMobileAdsConsentManager.sharedInstance
      gatherConsentFromConsentPresentationViewController:self
                                consentGatheringComplete:^(NSError *_Nullable consentError) {
                                  __strong __typeof__(self) strongSelf = weakSelf;
                                  if (!strongSelf) {
                                    return;
                                  }
                                  dispatch_block_cancel(loadingSpinnerBlock);
                                  [strongSelf.loadingSpinner stopAnimating];

                                  // Animate the visibility of the game UI.
                                  [UIView animateWithDuration:0.25
                                                   animations:^{
                                                     strongSelf.gameView.alpha = 1;
                                                   }];

                                  [strongSelf startNewGame];

                                  if (consentError) {
                                    // Consent gathering failed.
                                    NSLog(@"Error: %@", consentError.localizedDescription);
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

- (void)startGoogleMobileAdsSDK {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    // Initialize the Google Mobile Ads SDK.
    [GADMobileAds.sharedInstance startWithCompletionHandler:nil];

    // Request an ad.
    [self loadInterstitial];
  });
}

#pragma mark Game logic

- (void)startNewGame {
  self.gameState = kGameStatePlaying;
  self.playAgainButton.hidden = YES;
  self.timeLeft = kGameLength;
  [self updateTimeLeft];
  self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                target:self
                                              selector:@selector(decrementTimeLeft:)
                                              userInfo:nil
                                               repeats:YES];
}

- (void)loadInterstitial {
  // [START load_interstitial]
  [GAMInterstitialAd loadWithAdManagerAdUnitID:@"/21775744923/example/interstitial"
                                       request:[GAMRequest request]
                             completionHandler:^(GAMInterstitialAd *ad, NSError *error) {
                               if (error) {
                                 NSLog(@"Failed to load interstitial ad with error: %@",
                                       [error localizedDescription]);
                                 return;
                               }
                               self.interstitial = ad;
                               // [START set_the_delegate]
                               self.interstitial.fullScreenContentDelegate = self;
                               // [END set_the_delegate]
                             }];
  // [END load_interstitial]
}

- (void)updateTimeLeft {
  self.gameText.text = [NSString stringWithFormat:@"%ld seconds left!", (long)self.timeLeft];
}

- (void)decrementTimeLeft:(NSTimer *)timer {
  self.timeLeft--;
  [self updateTimeLeft];
  if (self.timeLeft == 0) {
    [self endGame];
  }
}

- (void)pauseGame {
  if (self.gameState != kGameStatePlaying) {
    return;
  }
  self.gameState = kGameStatePaused;

  // Record the relevant pause times.
  self.pauseDate = [NSDate date];
  self.previousFireDate = [self.timer fireDate];

  // Prevent the timer from firing while app is in background.
  [self.timer setFireDate:[NSDate distantFuture]];
}

- (void)resumeGame {
  if (self.gameState != kGameStatePaused) {
    return;
  }
  self.gameState = kGameStatePlaying;

  // Calculate amount of time the app was paused.
  float pauseTime = [self.pauseDate timeIntervalSinceNow] * -1;

  // Set the timer to start firing again.
  [self.timer setFireDate:[NSDate dateWithTimeInterval:pauseTime sinceDate:self.previousFireDate]];
}

- (void)endGame {
  self.gameState = kGameStateEnded;
  [self.timer invalidate];
  self.timer = nil;
  __weak ViewController *weakSelf = self;
  UIAlertController *alert = [UIAlertController
      alertControllerWithTitle:@"Game Over"
                       message:[NSString
                                   stringWithFormat:@"You lasted %ld seconds", (long)kGameLength]
                preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction *alertAction =
      [UIAlertAction actionWithTitle:@"OK"
                               style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction *action) {
                               __strong __typeof__(self) strongSelf = weakSelf;
                               if (!strongSelf) {
                                return;
                              }
                              [strongSelf presentInterstitialAd];
                              strongSelf.playAgainButton.hidden = NO;
                            }];
  [alert addAction:alertAction];
  [self presentViewController:alert animated:YES completion:nil];
}

- (void)presentInterstitialAd {
  if (!self.interstitial ||
      ![self.interstitial canPresentFromRootViewController:self error:nil]) {
    NSLog(@"Ad wasn't ready");
    return;
  }
  // [START present_interstitial]
  [self.interstitial presentFromRootViewController:self];
  // [END present_interstitial]
}

- (IBAction)privacySettingsTapped:(UIBarButtonItem *)sender {
  [self pauseGame];

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
                                                               handler:^(UIAlertAction *action) {
                                                                 [self resumeGame];
                                                               }];

                                    [alertController addAction:defaultAction];
                                    [self presentViewController:alertController
                                                       animated:YES
                                                     completion:nil];
                                  } else {
                                    [self resumeGame];
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

- (IBAction)playAgain:(id)sender {
  [self startNewGame];

  if (GoogleMobileAdsConsentManager.sharedInstance.canRequestAds) {
    [self loadInterstitial];
  }
}

#pragma GADFullScreenContentdelegate implementation

// [START ad_events]
- (void)adDidRecordImpression:(id<GADFullScreenPresentingAd>)ad {
  NSLog(@"%s called", __PRETTY_FUNCTION__);
}

- (void)adDidRecordClick:(id<GADFullScreenPresentingAd>)ad {
  NSLog(@"%s called", __PRETTY_FUNCTION__);
}

- (void)ad:(id<GADFullScreenPresentingAd>)ad
    didFailToPresentFullScreenContentWithError:(NSError *)error {
  NSLog(@"%s called with error: %@", __PRETTY_FUNCTION__, error.localizedDescription);
  // Clear the interstitial ad.
  self.interstitial = nil;
}

- (void)adWillPresentFullScreenContent:(id<GADFullScreenPresentingAd>)ad {
  NSLog(@"%s called", __PRETTY_FUNCTION__);
}

- (void)adWillDismissFullScreenContent:(id<GADFullScreenPresentingAd>)ad {
  NSLog(@"%s called", __PRETTY_FUNCTION__);
}

- (void)adDidDismissFullScreenContent:(id<GADFullScreenPresentingAd>)ad {
  NSLog(@"%s called", __PRETTY_FUNCTION__);
  // Clear the interstitial ad.
  self.interstitial = nil;
}
// [END ad_events]

@end
