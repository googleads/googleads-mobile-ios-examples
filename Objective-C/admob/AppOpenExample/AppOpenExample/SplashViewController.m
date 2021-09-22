//
//  Copyright 2021 Google LLC
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "MainViewController.h"
#import "SplashViewController.h"

/// Number of seconds to count down before showing the app open ad.
/// This simulates the time needed to load the app.
static const NSInteger CounterTime = 5;

@interface SplashViewController ()

@end

@implementation SplashViewController {
  /// Number of seconds remaining to show the app open ad.
  NSInteger _secondsRemaining;
  /// The countdown timer.
  NSTimer *_countdownTimer;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  AppOpenAdManager.sharedInstance.delegate = self;
  [self startTimer];
}

- (void)startTimer {
  _secondsRemaining = CounterTime;
  self.splashScreenLabel.text = [NSString stringWithFormat:@"App is done loading in: %ld",
                                 (long)_secondsRemaining];
  _countdownTimer = [NSTimer
                     scheduledTimerWithTimeInterval:1.0
                     target:self
                     selector:@selector(decrementCounter)
                     userInfo:nil
                     repeats:YES];
}

- (void)decrementCounter {
  _secondsRemaining--;
  if (_secondsRemaining > 0) {
    self.splashScreenLabel.text = [NSString stringWithFormat:@"App is done loading in: %ld",
                                   (long)_secondsRemaining];
  } else {
    self.splashScreenLabel.text = @"Done.";
    [_countdownTimer invalidate];
    _countdownTimer = nil;
    [AppOpenAdManager.sharedInstance showAdIfAvailable:self];
  }
}

- (void)startMainScreen {
  UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
  UIViewController *mainViewController = [mainStoryBoard
                                          instantiateViewControllerWithIdentifier:@"MainStoryBoard"];
  mainViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
  [self presentViewController:mainViewController animated:YES completion:^{
    [self dismissViewControllerAnimated:NO completion:^{
      // Find the keyWindow which is currently being displayed on the device,
      // and set its rootViewController to mainViewController.
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.isKeyWindow == YES"];
      UIWindow *keyWindow = [[UIApplication.sharedApplication.windows
                              filteredArrayUsingPredicate:predicate] firstObject];
      keyWindow.rootViewController = mainViewController;
    }];
  }];
}

#pragma mark - AppOpenAdManagerDelegate

- (void)adDidComplete {
  [self startMainScreen];
}

@end
