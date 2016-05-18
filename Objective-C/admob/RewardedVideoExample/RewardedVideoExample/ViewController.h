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

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

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

/// Pauses the game.
- (void)pauseGame;

/// Resumes the game.
- (void)resumeGame;

@end
