// SampleConstants.h
// Copyright 2012 Google Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// These are sample ad units. You should define your own creatives
// under your own network when developing your applications.
#define kSampleAdUnitID @"/6253334/dfp_example_ad/banner";
#define kSampleMultipleAdSizesAdUnitID @"/6253334/dfp_example_ad/multisize";
#define kSampleAppEventsAdUnitID @"/6253334/dfp_example_ad/appevents";

// This app supports three samples: a simple banner, a multiple ad sizes
// example, and an app events example.
#define kSampleBanner 0
#define kSampleMultipleAdSizes 1
#define kSampleAppEvents 2

// Set the sample you want to run.  Choose from one of the constants above.
#define kSampleToRun kSampleBanner
