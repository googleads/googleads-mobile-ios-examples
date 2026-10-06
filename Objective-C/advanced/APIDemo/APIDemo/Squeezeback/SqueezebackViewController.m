//
//  Copyright 2026 Google LLC
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

#import "SqueezebackViewController.h"

#import <GoogleMobileAds/GoogleMobileAds.h>
#import <GoogleMobileAds/GoogleMobileAds_Beta.h>
#import "SqueezebackAdManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface SqueezebackViewController ()

@property(nonatomic, weak) IBOutlet UIButton *loadAdButton;
@property(nonatomic, weak) IBOutlet UIButton *showAdButton;
@property(nonatomic, weak) IBOutlet UIButton *hideAdButton;
@property(nonatomic, weak) IBOutlet UILabel *statusLabel;

@end

@implementation SqueezebackViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  // Register callback listeners for ad shown / hidden events.
  __weak typeof(self) weakSelf = self;
  SqueezebackAdManager.sharedInstance.onAdShownListener = ^{
    typeof(self) strongSelf = weakSelf;
    if (!strongSelf) return;
    strongSelf.showAdButton.enabled = NO;
    strongSelf.hideAdButton.enabled = YES;
    strongSelf.statusLabel.text = @"Squeezeback ad shown.";
  };

  SqueezebackAdManager.sharedInstance.onAdHiddenListener = ^{
    typeof(self) strongSelf = weakSelf;
    if (!strongSelf) return;
    strongSelf.statusLabel.text = @"Squeezeback ad hidden.";
    strongSelf.showAdButton.enabled = [SqueezebackAdManager.sharedInstance isAdAvailable];
    strongSelf.hideAdButton.enabled = NO;
  };

  self.showAdButton.enabled = [SqueezebackAdManager.sharedInstance isAdAvailable];
  self.hideAdButton.enabled = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];

  if (self.isMovingFromParentViewController) {
    SqueezebackAdManager.sharedInstance.onAdShownListener = nil;
    SqueezebackAdManager.sharedInstance.onAdHiddenListener = nil;
    [SqueezebackAdManager.sharedInstance destroyAd];
  }
}

#pragma mark - Actions

- (IBAction)loadAdButtonTapped:(id)sender {
  self.loadAdButton.enabled = NO;
  self.showAdButton.enabled = NO;
  self.hideAdButton.enabled = NO;
  self.statusLabel.text = @"Loading squeezeback ad...";

  __weak typeof(self) weakSelf = self;
  [SqueezebackAdManager.sharedInstance
      loadAdWithCompletionHandler:^(GADSqueezebackAd *_Nullable ad, NSError *_Nullable error) {
        typeof(self) strongSelf = weakSelf;
        if (!strongSelf) return;

        if (error) {
          strongSelf.statusLabel.text = [NSString
              stringWithFormat:@"Squeezeback ad failed to load: %@", error.localizedDescription];
          strongSelf.loadAdButton.enabled = YES;
          strongSelf.showAdButton.enabled = NO;
          strongSelf.hideAdButton.enabled = NO;
          return;
        }

        strongSelf.statusLabel.text = @"Squeezeback ad loaded.";
        strongSelf.loadAdButton.enabled = YES;
        strongSelf.showAdButton.enabled = YES;
        strongSelf.hideAdButton.enabled = NO;
      }];
}

- (IBAction)showAdButtonTapped:(id)sender {
  if (![SqueezebackAdManager.sharedInstance isAdAvailable]) {
    self.statusLabel.text = @"No ad loaded to show.";
    return;
  }

  [SqueezebackAdManager.sharedInstance showAd];
}

- (IBAction)hideAdButtonTapped:(id)sender {
  [SqueezebackAdManager.sharedInstance hideAd];
}

@end

NS_ASSUME_NONNULL_END
