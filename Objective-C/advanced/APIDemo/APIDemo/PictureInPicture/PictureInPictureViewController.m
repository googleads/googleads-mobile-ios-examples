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

#import "PictureInPictureViewController.h"

#import <GoogleMobileAds/GoogleMobileAds.h>
#import <GoogleMobileAds/GoogleMobileAds_Beta.h>
#import "PictureInPictureAdManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface PictureInPictureViewController ()

@property(nonatomic, weak) IBOutlet UISegmentedControl *scopeSegmentedControl;
@property(nonatomic, weak) IBOutlet UILabel *positionValueLabel;
@property(nonatomic, weak) IBOutlet UIButton *loadAdButton;
@property(nonatomic, weak) IBOutlet UIButton *showAdButton;
@property(nonatomic, weak) IBOutlet UIButton *hideAdButton;
@property(nonatomic, weak) IBOutlet UILabel *statusLabel;

@property(nonatomic, assign) GADPictureInPictureAdPosition selectedPosition;

@end

@implementation PictureInPictureViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.selectedPosition = GADPictureInPictureAdPositionDefault;

  // Register callback listeners for ad shown / hidden events.
  __weak typeof(self) weakSelf = self;
  PictureInPictureAdManager.sharedInstance.onAdShownListener = ^{
    typeof(self) strongSelf = weakSelf;
    if (!strongSelf) return;
    strongSelf.showAdButton.enabled = NO;
    strongSelf.hideAdButton.enabled = YES;
    strongSelf.statusLabel.text = @"Picture-in-Picture ad shown.";
  };

  PictureInPictureAdManager.sharedInstance.onAdHiddenListener = ^{
    typeof(self) strongSelf = weakSelf;
    if (!strongSelf) return;
    strongSelf.statusLabel.text = @"Picture-in-Picture ad hidden.";
    strongSelf.showAdButton.enabled = [PictureInPictureAdManager.sharedInstance isAdAvailable];
    strongSelf.hideAdButton.enabled = NO;
  };

  self.showAdButton.enabled = [PictureInPictureAdManager.sharedInstance isAdAvailable];
  self.hideAdButton.enabled = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];

  if (self.isMovingFromParentViewController) {
    PictureInPictureAdManager.sharedInstance.onAdShownListener = nil;
    PictureInPictureAdManager.sharedInstance.onAdHiddenListener = nil;

    // Only destroy the ad on dismissal if the scope is not application.
    if (PictureInPictureAdManager.sharedInstance.pipAd.presentationScope !=
        GADPictureInPictureAdPresentationScopeApplication) {
      [PictureInPictureAdManager.sharedInstance destroyAd];
    }
  }
}

#pragma mark - Actions

- (IBAction)positionRowTapped:(UIButton *)sender {
  UIAlertController *sheet = [UIAlertController
      alertControllerWithTitle:@"Position"
                       message:@"Select an initial position for the Picture-in-Picture ad."
                preferredStyle:UIAlertControllerStyleActionSheet];

  NSArray<NSDictionary<NSString *, id> *> *positions = @[
    @{@"title" : @"Default", @"position" : @(GADPictureInPictureAdPositionDefault)},
    @{@"title" : @"Top Left", @"position" : @(GADPictureInPictureAdPositionTopLeft)},
    @{@"title" : @"Top Right", @"position" : @(GADPictureInPictureAdPositionTopRight)},
    @{@"title" : @"Bottom Left", @"position" : @(GADPictureInPictureAdPositionBottomLeft)},
    @{@"title" : @"Bottom Right", @"position" : @(GADPictureInPictureAdPositionBottomRight)},
  ];

  __weak typeof(self) weakSelf = self;
  for (NSDictionary<NSString *, id> *item in positions) {
    NSString *title = item[@"title"];
    GADPictureInPictureAdPosition position = [item[@"position"] integerValue];
    [sheet addAction:[UIAlertAction actionWithTitle:title
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *_Nonnull action) {
                                              typeof(self) strongSelf = weakSelf;
                                              if (!strongSelf) return;
                                              strongSelf.selectedPosition = position;
                                              strongSelf.positionValueLabel.text = title;
                                            }]];
  }

  [sheet addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                            style:UIAlertActionStyleCancel
                                          handler:nil]];

  UIPopoverPresentationController *popover = sheet.popoverPresentationController;
  if (popover) {
    popover.sourceView = sender;
    popover.sourceRect = sender.bounds;
  }

  [self presentViewController:sheet animated:YES completion:nil];
}

- (IBAction)loadAdButtonTapped:(id)sender {
  self.loadAdButton.enabled = NO;
  self.showAdButton.enabled = NO;
  self.hideAdButton.enabled = NO;
  self.statusLabel.text = @"Loading Picture-in-Picture ad...";

  __weak typeof(self) weakSelf = self;
  [PictureInPictureAdManager.sharedInstance
      loadAdWithCompletionHandler:^(GADPictureInPictureAd *_Nullable ad, NSError *_Nullable error) {
        typeof(self) strongSelf = weakSelf;
        if (!strongSelf) return;

        if (error) {
          strongSelf.statusLabel.text =
              [NSString stringWithFormat:@"Picture-in-Picture ad failed to load: %@",
                                         error.localizedDescription];
          strongSelf.loadAdButton.enabled = YES;
          strongSelf.showAdButton.enabled = NO;
          strongSelf.hideAdButton.enabled = NO;
          return;
        }

        strongSelf.statusLabel.text = @"Picture-in-Picture ad loaded.";
        strongSelf.loadAdButton.enabled = YES;
        strongSelf.showAdButton.enabled = YES;
        strongSelf.hideAdButton.enabled = NO;
      }];
}

- (IBAction)showAdButtonTapped:(id)sender {
  if (![PictureInPictureAdManager.sharedInstance isAdAvailable]) {
    self.statusLabel.text = @"No ad loaded to show.";
    return;
  }

  GADPictureInPictureAdPresentationScope selectedScope =
      (self.scopeSegmentedControl.selectedSegmentIndex == 1)
          ? GADPictureInPictureAdPresentationScopeApplication
          : GADPictureInPictureAdPresentationScopeScreen;

  GADPictureInPictureAdOptions *options = [[GADPictureInPictureAdOptions alloc] init];
  options.presentationScope = selectedScope;
  options.position = self.selectedPosition;

  [PictureInPictureAdManager.sharedInstance showAdWithOptions:options];
}

- (IBAction)hideAdButtonTapped:(id)sender {
  [PictureInPictureAdManager.sharedInstance hideAd];
}

@end

NS_ASSUME_NONNULL_END
