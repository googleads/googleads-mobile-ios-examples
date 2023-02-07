// Copyright (C) 2018 Google, Inc.
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

#import <GoogleMobileAds/GoogleMobileAds.h>
#import <UIKit/UIKit.h>

/// A controller that demonstrates how to implement the custom Mute This Ad feature.
@interface AdMobNativeCustomMuteThisAdViewController : UIViewController

/// Container that holds the native ad.
@property(nonatomic, strong) IBOutlet UIView *nativeAdPlaceholder;

/// Refresh the native ad.
@property(nonatomic, strong) IBOutlet UIButton *refreshButton;

/// Mute the native ad.
@property(nonatomic, strong) IBOutlet UIButton *muteAdButton;

/// The Google Mobile Ads SDK version number label.
@property(nonatomic, strong) IBOutlet UILabel *versionLabel;

/// Refreshes the ad.
- (IBAction)refreshAd:(id)sender;

@end
