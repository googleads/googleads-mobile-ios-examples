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

#import <GoogleMobileAds/GADAdFormat.h>
#import <GoogleMobileAds/GADRequest.h>

/// Configuration for preloading ads.
@interface GADPreloadConfiguration : NSObject

/// The ad unit ID.
@property(nonatomic, nonnull, readonly) NSString *adUnitID;

/// The GADRequest object.
@property(nonatomic, nonnull, readonly) GADRequest *request;

/// The format. Interstitial, rewarded, and app open ads are supported.
@property(nonatomic, readonly) GADAdFormat format;

/// The maximum amount of ads buffered for this configuration.
@property(nonatomic, readwrite) NSUInteger bufferSize;

/// Initializes a GADPreloadConfiguration with ad unit ID, request, and format.
- (nonnull instancetype)initWithAdUnitID:(nonnull NSString *)adUnitID
                                adFormat:(GADAdFormat)format
                                 request:(nonnull GADRequest *)request;

/// Initializes a GADPreloadConfiguration with ad unit ID, format, and default request object.
- (nonnull instancetype)initWithAdUnitID:(nonnull NSString *)adUnitID adFormat:(GADAdFormat)format;

@end
