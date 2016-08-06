// Copyright (C) 2015 Google, Inc.
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

@import GoogleMobileAds;
@import UIKit;

@interface ViewController : UIViewController

/// Container that holds the native ad.
@property(nonatomic, weak) IBOutlet UIView *nativeAdPlaceholder;

/// Switch to request app install ads.
@property(nonatomic, weak) IBOutlet UISwitch *appInstallAdSwitch;

/// Switch to request content ads.
@property(nonatomic, weak) IBOutlet UISwitch *contentAdSwitch;

/// Refresh the native ad.
@property(nonatomic, weak) IBOutlet UIButton *refreshButton;

/// The Google Mobile Ads SDK version number label.
@property(nonatomic, weak) IBOutlet UILabel *versionLabel;

/// Refreshes the ad.
- (IBAction)refreshAd:(id)sender;

@end
