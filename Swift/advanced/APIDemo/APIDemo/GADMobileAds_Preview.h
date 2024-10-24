//
//  Copyright 2024 Google LLC
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

#import <GoogleMobileAds/GADMobileAds.h>
#import "GADPreloadConfiguration_Preview.h"
#import "GADPreloadEventDelegate_Preview.h"

@interface GADMobileAds ()

/// Starts preloading full screen ads from the configurations.
/// Ad loads and ad expiration events will be forwarded to the delegate provided.
- (void)preloadWithConfigurations:(nonnull NSArray<GADPreloadConfiguration *> *)configurations
                         delegate:(nonnull id<GADPreloadEventDelegate>)delegate;
@end
