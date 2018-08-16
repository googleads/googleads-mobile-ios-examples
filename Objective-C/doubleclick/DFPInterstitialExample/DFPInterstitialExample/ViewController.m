//
//  Copyright (C) 2014 Google, Inc.
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

@import GoogleMobileAds;

typedef NS_ENUM(NSUInteger, GameState) {
  kGameStateNotStarted = 0,  ///< Game has not started.
  kGameStatePlaying = 1,     ///< Game is playing.
  kGameStatePaused = 2,      ///< Game is paused.
  kGameStateEnded = 3        ///< Game has ended.
};

/// The game length.
static const NSInteger kGameLength = 5;

@interface ViewController () <GADInterstitialDelegate, UIAlertViewDelegate>

/// The DFP interstitial ad.
@property(nonatomic, strong) DFPInterstitial *interstitial;

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

  [self startNewGame];
}

#pragma mark Game logic

- (void)startNewGame {
  [self createAndLoadInterstitial];

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

- (void)createAndLoadInterstitial {
  self.interstitial = [[DFPInterstitial alloc] initWithAdUnitID:@"/6499/example/interstitial"];
  [self.interstitial loadRequest:[DFPRequest request]];
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

  [[[UIAlertView alloc]
          initWithTitle:@"Game Over"
                message:[NSString stringWithFormat:@"You lasted %ld seconds", (long)kGameLength]
               delegate:self
      cancelButtonTitle:@"Ok"
      otherButtonTitles:nil] show];
}

- (IBAction)playAgain:(id)sender {
  [self startNewGame];
}

#pragma mark UIAlertViewDelegate implementation

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
  if (self.interstitial.isReady) {
    [self.interstitial presentFromRootViewController:self];
  } else {
    NSLog(@"Ad wasn't ready");
  }
  self.playAgainButton.hidden = NO;
}

#pragma mark dealloc

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:UIApplicationDidEnterBackgroundNotification
                                                object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:UIApplicationDidBecomeActiveNotification
                                                object:nil];
}

@end
