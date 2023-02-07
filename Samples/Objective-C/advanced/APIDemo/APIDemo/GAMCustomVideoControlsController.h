//
//  Copyright (C) 2018 Google, Inc.
//
//  GAMCustomVideoControlsController.h
//  APIDemo
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
#import <GoogleMobileAds/GoogleMobileAds.h>

#import "SimpleNativeAdView.h"
#import "CustomControlsView.h"

@interface GAMCustomVideoControlsController : UIViewController

/// Switch to indicate if video ads should start muted.
@property(nonatomic, weak) IBOutlet UISwitch *startMutedSwitch;

/// Switch to indicate if video ads should request custom controls.
@property(nonatomic, weak) IBOutlet UISwitch *requestCustomControlsSwitch;

/// The placeholder for the native ad view that is being presented.
@property(nonatomic, strong) IBOutlet UIView *placeholderView;

/// Switch to request app install ads.
@property(nonatomic, weak) IBOutlet UISwitch *unifiedNativeAdSwitch;

/// Switch to custom native ads.
@property(nonatomic, weak) IBOutlet UISwitch *customNativeAdSwitch;

/// View containing information about video and custom controls.
@property(nonatomic, weak) IBOutlet CustomControlsView *customControlsView;

/// Refresh the native ad.
@property(nonatomic, weak) IBOutlet UIButton *refreshButton;

/// The Google Mobile Ads SDK version number label.
@property(nonatomic, weak) IBOutlet UILabel *versionLabel;

/// Refreshes the ad.
- (IBAction)refreshAd:(id)sender;

@end
