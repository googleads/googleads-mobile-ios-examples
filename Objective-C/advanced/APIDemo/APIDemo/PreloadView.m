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

#import "PreloadView.h"

@implementation PreloadView

- (IBAction)show:(id)sender {
  if (self.showDelegate) {
    self.showDelegate();
  }
}

+ (instancetype)preloadViewWithTitle:(NSString *)title
                        showDelegate:(void (^)(void))showDelegate {
  PreloadView *preloadView = [[[NSBundle mainBundle] loadNibNamed:@"PreloadView"
                                                            owner:nil
                                                          options:nil] firstObject];
  if (![preloadView isKindOfClass:[PreloadView class]]) {
    NSLog(@"Error loading PreloadView nib file.");
    return nil;
  }
  preloadView.titleText.text = title;
  preloadView.titleText.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
  preloadView.titleText.adjustsFontForContentSizeCategory = YES;
  preloadView.statusText.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
  preloadView.statusText.adjustsFontForContentSizeCategory = YES;
  preloadView.showDelegate = showDelegate;
  return preloadView;
}

@end
