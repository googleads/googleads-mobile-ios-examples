//
//  Copyright 2017 Google LLC
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

/// Constant for coin rewards.
static const NSInteger GameOverReward = 1;

/// Starting time for game counter.
static const NSInteger GameLength = 10;

typedef NS_ENUM(NSInteger, GameState) {
  kGameStateNotStarted = 0,  ///< Game has not started.
  kGameStatePlaying = 1,     ///< Game is playing.
  kGameStatePaused = 2,      ///< Game is paused.
  kGameStateEnded = 3        ///< Game has ended.
};

@interface ViewController () <GADFullScreenContentDelegate>

/// The privacy settings button.
@property(weak, nonatomic) IBOutlet UIBarButtonItem *privacySettingsButton;

/// The game text.
@property(weak, nonatomic) IBOutlet UILabel *gameLabel;

/// The play again button.
@property(weak, nonatomic) IBOutlet UIButton *playAgainButton;

/// The button to show rewarded video.
@property(weak, nonatomic) IBOutlet UIButton *showVideoButton;

/// The text indicating current coin count.
@property(weak, nonatomic) IBOutlet UILabel *coinCountLabel;

/// Restarts the game.
- (IBAction)playAgain:(id)sender;

/// Shows a rewarded video.
- (IBAction)showVideo:(id)sender;

/// Number of coins the user has earned.
@property(nonatomic, assign) NSInteger coinCount;

/// The countdown timer.
@property(nonatomic, strong) NSTimer *timer;

/// The game counter.
@property(nonatomic, assign) NSInteger counter;

/// The state of the game.
@property(nonatomic, assign) GameState gameState;

/// The date that the timer was paused.
@property(nonatomic, strong) NSDate *pauseDate;

/// The last fire date before a pause.
@property(nonatomic, strong) NSDate *previousFireDate;

/// A pre-loaded rewarded ad.
@property(nonatomic, strong) GADRewardedAd *rewardedAd;

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.coinCount = 0;

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
    [self loadRewardedAd];
  });
}

#pragma mark Game logic

- (void)startNewGame {
  self.gameState = kGameStatePlaying;
  self.playAgainButton.hidden = YES;
  self.showVideoButton.hidden = YES;
  self.counter = GameLength;
  self.gameLabel.text = [NSString stringWithFormat:@"%ld", (long)self.counter];
  self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                target:self
                                              selector:@selector(decrementCounter:)
                                              userInfo:nil
                                               repeats:YES];
  self.timer.tolerance = GameLength * 0.1;
}

- (void)loadRewardedAd {
  GAMRequest *request = [GAMRequest request];
  [GADRewardedAd
       loadWithAdUnitID:@"/6499/example/rewarded-video"
                request:request
      completionHandler:^(GADRewardedAd *ad, NSError *error) {
        if (error) {
          NSLog(@"Rewarded ad failed to load with error: %@", [error localizedDescription]);
          return;
        }
        self.rewardedAd = ad;
        NSLog(@"Rewarded ad loaded.");
        self.rewardedAd.fullScreenContentDelegate = self;
      }];
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
  NSTimeInterval pauseDuration = [self.pauseDate timeIntervalSinceNow];

  // Set the timer to start firing again.
  [self.timer setFireDate:[self.previousFireDate dateByAddingTimeInterval:-pauseDuration]];
}

- (void)setTimer:(NSTimer *)timer {
  [_timer invalidate];
  _timer = timer;
}

- (void)decrementCounter:(NSTimer *)timer {
  self.counter--;
  if (self.counter > 0) {
    self.gameLabel.text = [NSString stringWithFormat:@"%ld", (long)self.counter];
  } else {
    [self endGame];
  }
}

- (void)earnCoins:(NSInteger)coins {
  self.coinCount += coins;
  [self.coinCountLabel setText:[NSString stringWithFormat:@"Coins: %ld", (long)self.coinCount]];
}

- (void)endGame {
  self.timer = nil;
  self.gameState = kGameStateEnded;
  self.gameLabel.text = @"Game over!";
  if (self.rewardedAd && [self.rewardedAd canPresentFromRootViewController:self error:nil]) {
    self.showVideoButton.hidden = NO;
  }
  self.playAgainButton.hidden = NO;
  // Reward user with coins for finishing the game.
  [self earnCoins:GameOverReward];
}

#pragma mark Button actions

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
    [self loadRewardedAd];
  }
}

- (IBAction)showVideo:(id)sender {
  self.showVideoButton.hidden = YES;

  if (self.rewardedAd && [self.rewardedAd canPresentFromRootViewController:self error:nil]) {
    [self.rewardedAd presentFromRootViewController:self
                          userDidEarnRewardHandler:^{
                            GADAdReward *reward = self.rewardedAd.adReward;

                            NSString *rewardMessage = [NSString
                                stringWithFormat:@"Reward received with currency %@ , amount %lf",
                                                 reward.type, [reward.amount doubleValue]];
                            NSLog(@"%@", rewardMessage);
                            // Reward the user for watching the video.
                            [self earnCoins:[reward.amount integerValue]];
                          }];
  }
}

#pragma mark GADFullScreenContentDelegate implementation

/// Tells the delegate that the rewarded ad will be presented.
- (void)adWillPresentFullScreenContent:(id)ad {
  NSLog(@"Rewarded ad will be presented.");
}

/// Tells the delegate that the rewarded ad failed to present.
- (void)ad:(id)ad didFailToPresentFullScreenContentWithError:(NSError *)error {
  NSLog(@"Rewarded ad failed to present with error: %@", [error localizedDescription]);
  UIAlertController *alert = [UIAlertController
      alertControllerWithTitle:@"Rewarded Ad not ready"
                       message:[NSString
                                   stringWithFormat:@"Rewarded ad failed to present with error: %@",
                                                    [error localizedDescription]]
                preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"Drat"
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil];
  [alert addAction:alertAction];
  [self presentViewController:alert animated:YES completion:nil];
}

/// Tells the delegate that the rewarded ad was dismissed.
- (void)adDidDismissFullScreenContent:(id)ad {
  [self loadRewardedAd];
  self.showVideoButton.hidden = YES;
  NSLog(@"Rewarded ad dismissed.");
}
@end
