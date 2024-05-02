//
//  Copyright (C) 2015 Google, Inc.
//
//  AdMobAdDelegateViewController.h
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

/// Google AdMob - Ad Delegate
/// Demonstrates handling GADBannerViewDelegate ad request status and ad click lifecycle messages.
/// This is an AdMob example, so it uses a GADBannerView to show an AdMob ad. GADBannerViewDelegate
/// also works with GAMBannerView objects, so publishers displaying ads from
/// Google Ad Manager (GAM) can also use it with their banners.
/// To see this in action, use the GAMBannerView class instead of GADBannerView.
@interface AdMobAdDelegateViewController : UIViewController

@end
