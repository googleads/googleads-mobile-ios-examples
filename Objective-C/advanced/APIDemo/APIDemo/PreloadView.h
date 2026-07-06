//
//  Copyright (C) 2024 Google LLC
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

NS_ASSUME_NONNULL_BEGIN

/// Custom view representing an ad format preloader section with status and presentation controls.
@interface PreloadView : UIView

@property(nonatomic, strong) IBOutlet UILabel *titleText;
@property(nonatomic, strong) IBOutlet UILabel *statusText;
@property(nonatomic, strong) IBOutlet UIButton *showButton;
@property(nonatomic, copy) void (^showDelegate)(void);

- (IBAction)show:(id)sender;

/// Creates and returns a preload view with the specified title and show delegate.
///
/// @param title The title text for the preload view.
/// @param showDelegate A block executed when the show button is tapped.
/// @return An initialized preload view instance or nil if XIB loading fails.
+ (nullable instancetype)preloadViewWithTitle:(NSString *)title
                                 showDelegate:(void (^)(void))showDelegate;

@end

NS_ASSUME_NONNULL_END
