// Copyright 2015 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

/// The privacy settings button.
@property(nonatomic, weak) IBOutlet UIBarButtonItem *privacySettingsButton;

/// The ad inspector button.
@property(weak, nonatomic) IBOutlet UIBarButtonItem *adInspectorButton;

/// Container that holds the native ad.
@property(nonatomic, weak) IBOutlet UIView *nativeAdPlaceholder;

/// Indicates if video ads should start muted.
@property(nonatomic, weak) IBOutlet UISwitch *startMutedSwitch;

/// Displays status messages about video assets.
@property(nonatomic, weak) IBOutlet UILabel *videoStatusLabel;

/// Refresh the native ad.
@property(nonatomic, weak) IBOutlet UIButton *refreshButton;

/// The Google Mobile Ads SDK version number label.
@property(nonatomic, weak) IBOutlet UILabel *versionLabel;

/// Refreshes the ad.
- (IBAction)refreshAd:(id)sender;

@end
