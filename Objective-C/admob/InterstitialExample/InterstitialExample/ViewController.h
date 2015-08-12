// Copyright (c) 2014 Google. All rights reserved.

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

/// The game text.
@property(nonatomic, weak) IBOutlet UILabel *gameText;

/// The play again button.
@property(nonatomic, weak) IBOutlet UIButton *playAgainButton;

/// Starts a new game. Shows an interstitial if it's ready.
- (IBAction)playAgain:(id)sender;

/// Pauses the game.
- (void)pauseGame;

/// Resumes the game.
- (void)resumeGame;

@end
