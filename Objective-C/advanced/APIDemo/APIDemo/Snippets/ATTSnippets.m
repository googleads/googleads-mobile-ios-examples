//
//  Copyright (C) 2025 Google, Inc.
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

#import <AppTrackingTransparency/AppTrackingTransparency.h>

@interface ATTSnippets : NSObject

@end

@implementation ATTSnippets

// [START request_idfa]
- (void)requestIDFA {
  if (@available(iOS 14, *)) {
    [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(
                           ATTrackingManagerAuthorizationStatus status){
        // Tracking authorization completed. Start loading ads here.
    }];
  }
}
// [END request_idfa]

@end
