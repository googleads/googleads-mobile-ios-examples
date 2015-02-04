//  Copyright (c) 2014 Google. All rights reserved.

@import GoogleMobileAds;

#import "ViewController.h"

typedef NS_ENUM(NSUInteger, GameState) {
  kGameStateNotStarted = 0,  ///< Game has not started.
  kGameStatePlaying = 1,     ///< Game is playing.
  kGameStatePaused = 2,      ///< Game is paused.
  kGameStateEnded = 3        ///< Game has ended.
};

@interface ViewController ()<GADInterstitialDelegate, UIAlertViewDelegate>

/// The DFP interstitial ad.
@property(nonatomic, strong) DFPInterstitial *interstitial;

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
  // Do any additional setup after loading the view, typically from a nib.

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
  self.gameState = kGameStatePlaying;
  self.playAgainButton.hidden = YES;
  [self createAndLoadInterstitial];
  self.counter = 3;
  self.gameText.text = [NSString stringWithFormat:@"%ld", (long)self.counter];
  self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                target:self
                                              selector:@selector(decrementCounter:)
                                              userInfo:nil
                                               repeats:YES];
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

- (void)decrementCounter:(NSTimer *)timer {
  self.counter--;
  if (self.counter > 0) {
    self.gameText.text = [NSString stringWithFormat:@"%ld", (long)self.counter];
  } else {
    [self endGame];
  }
}

- (void)endGame {
  self.gameState = kGameStateEnded;
  self.gameText.text = @"Game over!";
  self.playAgainButton.hidden = NO;
  [self.timer invalidate];
  self.timer = nil;
}

- (void)createAndLoadInterstitial {
  self.interstitial = [[DFPInterstitial alloc] init];
  self.interstitial.adUnitID = @"/6499/example/interstitial";
  self.interstitial.delegate = self;
  [self.interstitial loadRequest:[DFPRequest request]];
}

- (IBAction)playAgain:(id)sender {
  if (self.interstitial.isReady) {
    [self.interstitial presentFromRootViewController:self];
  } else {
    [[[UIAlertView alloc] initWithTitle:@"Interstitial not ready"
                                message:@"The interstitial didn't finish loading or failed to load"
                               delegate:self
                      cancelButtonTitle:@"Drat"
                      otherButtonTitles:nil] show];
  }
}

#pragma mark UIAlertViewDelegate implementation

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
  [self startNewGame];
}

#pragma mark GADInterstitialDelegate implementation

- (void)interstitial:(DFPInterstitial *)interstitial
    didFailToReceiveAdWithError:(GADRequestError *)error {
  NSLog(@"interstitialDidFailToReceiveAdWithError: %@", [error localizedDescription]);
}

- (void)interstitialDidDismissScreen:(DFPInterstitial *)interstitial {
  NSLog(@"interstitialDidDismissScreen");
  [self startNewGame];
}

@end
