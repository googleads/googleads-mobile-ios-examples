//
//  Copyright 2022 Google LLC
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

/// GameState indicates the progress of the game.
typedef NS_ENUM(NSUInteger, GameState) {
  /** Game has not started. */
  GameStateNotStarted = 0,
  /** Game is playing. */
  GameStatePlaying = 1,
  /** Game is paused. */
  GameStatePaused = 2,
  /** Game has ended. */
  GameStateEnded = 3
};

/// The game length.
static const NSInteger kGameLength = 5;

/// The time length before showing ads.
static const NSInteger kAdIntroLength = 3;

@interface ViewController () <GADFullScreenContentDelegate>

/// The privacy settings button.
@property(weak, nonatomic) IBOutlet UIBarButtonItem *privacySettingsButton;

/// The game text.
@property(nonatomic, weak) IBOutlet UILabel *gameText;

/// The play again button.
@property(nonatomic, weak) IBOutlet UIButton *playAgainButton;

/// The text indicating current coin count.
@property(weak, nonatomic) IBOutlet UILabel *coinCountLabel;

/// Starts a new game. Shows a rewarded interstitial if it's ready.
- (IBAction)playAgain:(id)sender;

/// The rewarded interstitial ad.
@property(nonatomic) GADRewardedInterstitialAd *rewardedInterstitialAd;

/// Number of coins the user has earned.
@property(nonatomic) NSInteger coinCount;

/// The countdown timer.
@property(nonatomic) NSTimer *timer;

/// The amount of time left in the game.
@property(nonatomic) NSInteger timeLeft;

/// The state of the game.
@property(nonatomic) GameState gameState;

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  // Pause game when application is backgrounded.
  [NSNotificationCenter.defaultCenter addObserver:self
                                         selector:@selector(pauseGame)
                                             name:UIApplicationDidEnterBackgroundNotification
                                           object:nil];

  // Resume game when application becomes active.
  [NSNotificationCenter.defaultCenter addObserver:self
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
    [self loadRewardedInterstitialAd];
  });
}

#pragma mark Game logic

- (void)startNewGame {
  self.gameState = GameStatePlaying;
  self.playAgainButton.hidden = YES;
  self.timeLeft = kGameLength;
  [self updateTimeLeft];
  self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                target:self
                                              selector:@selector(decrementTimeLeft:)
                                              userInfo:nil
                                               repeats:YES];
}

- (void)loadRewardedInterstitialAd {
  GADRequest *request = [GADRequest request];
  [GADRewardedInterstitialAd loadWithAdUnitID:@"ca-app-pub-3940256099942544/6978759866"
                                      request:request
                            completionHandler:^(GADRewardedInterstitialAd *ad, NSError *error) {
                              if (error) {
                                NSLog(@"Failed to load rewarded interstitial ad with error: %@",
                                      error.localizedDescription);
                                self.playAgainButton.hidden = NO;
                                return;
                              }
                              self.rewardedInterstitialAd = ad;
                              self.rewardedInterstitialAd.fullScreenContentDelegate = self;
                            }];
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

- (void)earnCoins:(NSInteger)coins {
  self.coinCount += coins;
  [self.coinCountLabel setText:[NSString stringWithFormat:@"Coins: %ld", (long)self.coinCount]];
}

- (void)pauseGame {
  if (self.gameState != GameStatePlaying) {
    return;
  }
  self.gameState = GameStatePaused;

  // Prevent the timer from firing while app is in background.
  [self.timer invalidate];
  self.timer = nil;
}

- (void)resumeGame {
  if (self.gameState != GameStatePaused) {
    return;
  }
  self.gameState = GameStatePlaying;

  if (!self.timer) {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                  target:self
                                                selector:@selector(decrementTimeLeft:)
                                                userInfo:nil
                                                 repeats:YES];
  }
}

- (void)endGame {
  self.gameState = GameStateEnded;
  [self.timer invalidate];
  self.timer = nil;
  [self earnCoins:1];
  __weak ViewController *weakSelf = self;

  __block BOOL adCanceled = NO;

  UIAlertController *alert = [UIAlertController
      alertControllerWithTitle:@"Game Over!"
                       message:[NSString stringWithFormat:@"Watch an ad for 10 more coins. Video "
                                                          @"starting in %ld seconds...",
                                                          (long)kAdIntroLength]
                preferredStyle:UIAlertControllerStyleAlert];

  UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"No, thanks"
                                                         style:UIAlertActionStyleCancel
                                                       handler:^(UIAlertAction *_Nonnull action) {
                                                         adCanceled = YES;
                                                         self.playAgainButton.hidden = NO;
                                                       }];

  [alert addAction:cancelAction];
  [self presentViewController:alert
                     animated:YES
                   completion:^() {
                     ViewController *strongSelf = weakSelf;
                     if (!strongSelf) {
                       return;
                     }

                     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, kAdIntroLength * NSEC_PER_SEC),
                                    dispatch_get_main_queue(), ^{
                                      [self
                                          dismissViewControllerAnimated:YES
                                                             completion:^{
                                                               if (!adCanceled) {
                                                                 [self showRewardedInterstitialAd];
                                                               }
                                                             }];
                                    });
                   }];
}

- (void)showRewardedInterstitialAd {
  if (self.rewardedInterstitialAd) {
    [self.rewardedInterstitialAd
        presentFromRootViewController:self
             userDidEarnRewardHandler:^{
               GADAdReward *reward = self.rewardedInterstitialAd.adReward;

               NSString *rewardMessage =
                   [NSString stringWithFormat:@"Reward received with "
                                              @"currency %@ , amount %ld",
                                              reward.type, [reward.amount longValue]];
               NSLog(@"%@", rewardMessage);
               // Reward the user for watching the
               // video.
               [self earnCoins:reward.amount.longValue];
             }];
  } else {
    NSLog(@"Ad wasn't ready");
  }
}

#pragma mark GADFullScreeContentDelegate implementation

- (void)adWillPresentFullScreenContent:(id<GADFullScreenPresentingAd>)ad {
  NSLog(@"Ad did present full screen content.");
}

- (void)ad:(id)ad didFailToPresentFullScreenContentWithError:(NSError *)error {
  NSLog(@"Ad failed to present full screen content with error %@.", error.localizedDescription);
  self.rewardedInterstitialAd = nil;
  self.playAgainButton.hidden = NO;
}

- (void)adDidDismissFullScreenContent:(id)ad {
  NSLog(@"Ad did dismiss full screen content.");
  self.rewardedInterstitialAd = nil;
  self.playAgainButton.hidden = NO;
}

#pragma mark Rewarded Interstitial button actions

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

- (IBAction)playAgain:(id)sender {
  [self startNewGame];
  if (GoogleMobileAdsConsentManager.sharedInstance.canRequestAds) {
    [self loadRewardedInterstitialAd];
  }
}

@end
