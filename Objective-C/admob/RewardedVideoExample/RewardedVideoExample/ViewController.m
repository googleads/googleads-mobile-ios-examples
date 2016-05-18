//
//  Copyright (C) 2015 Google, Inc.
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

@import GoogleMobileAds;

#import "ViewController.h"

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

@interface ViewController () <GADRewardBasedVideoAdDelegate>

/// Number of coins the user has earned.
@property(nonatomic, assign) NSInteger coinCount;

/// Is an ad being loaded.
@property(nonatomic, assign, getter=isRewardBasedVideoRequestLoading)
    BOOL rewardBasedVideoRequestLoading;

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

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.

  [GADRewardBasedVideoAd sharedInstance].delegate = self;
  self.coinCount = 0;
  [self startNewGame];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self resumeGame];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [self pauseGame];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark Game logic

- (void)startNewGame {
  if (![self isRewardBasedVideoRequestLoading] &&
      ![[GADRewardBasedVideoAd sharedInstance] isReady]) {
    [self requestRewardedVideo];
  }
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

- (void)requestRewardedVideo {
  self.rewardBasedVideoRequestLoading = YES;
  GADRequest *request = [GADRequest request];
  [[GADRewardBasedVideoAd sharedInstance] loadRequest:request
                                         withAdUnitID:@"INSERT_AD_UNIT_HERE"];
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
  if ([[GADRewardBasedVideoAd sharedInstance] isReady]) {
    self.showVideoButton.hidden = NO;
  }
  self.playAgainButton.hidden = NO;
  // Reward user with coins for finishing the game.
  [self earnCoins:GameOverReward];
}

#pragma Interstitial button actions

- (IBAction)playAgain:(id)sender {
  [self startNewGame];
}

- (IBAction)showVideo:(id)sender {
  if ([[GADRewardBasedVideoAd sharedInstance] isReady]) {
    [[GADRewardBasedVideoAd sharedInstance] presentFromRootViewController:self];
  } else {
    [[[UIAlertView alloc]
            initWithTitle:@"Interstitial not ready"
                  message:@"The interstitial didn't finish " @"loading or failed to load"
                 delegate:self
        cancelButtonTitle:@"Drat"
        otherButtonTitles:nil] show];
  }
}

#pragma mark UIAlertViewDelegate implementation

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
  [self startNewGame];
}

#pragma mark GADRewardBasedVideoAdDelegate implementation

- (void)rewardBasedVideoAdDidReceiveAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
  self.rewardBasedVideoRequestLoading = NO;
  NSLog(@"Reward based video ad is received.");
}

- (void)rewardBasedVideoAdDidOpen:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
  NSLog(@"Opened reward based video ad.");
}

- (void)rewardBasedVideoAdDidStartPlaying:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
  NSLog(@"Reward based video ad started playing.");
}

- (void)rewardBasedVideoAdDidClose:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
  NSLog(@"Reward based video ad is closed.");
  self.showVideoButton.hidden = YES;
}

- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd
    didRewardUserWithReward:(GADAdReward *)reward {
  NSString *rewardMessage =
      [NSString stringWithFormat:@"Reward received with currency %@ , amount %lf", reward.type,
                                 [reward.amount doubleValue]];
  NSLog(@"%@", rewardMessage);
  // Reward the user for watching the video.
  [self earnCoins:[reward.amount integerValue]];
  self.showVideoButton.hidden = YES;
}

- (void)rewardBasedVideoAdWillLeaveApplication:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
  NSLog(@"Reward based video ad will leave application.");
}

- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd
    didFailToLoadWithError:(NSError *)error {
  self.rewardBasedVideoRequestLoading = NO;
  NSLog(@"Reward based video ad failed to load.");
}

@end
