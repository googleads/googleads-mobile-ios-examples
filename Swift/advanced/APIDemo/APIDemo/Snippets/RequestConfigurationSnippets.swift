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

import GoogleMobileAds

private class RequestConfigurationSnippets {

  private func setTestDeviceIdentifiers() {
    // [START set_test_device_ids]
    let testDeviceIdentifiers = ["2077ef9a63d2b398840261c8221a0c9b"]
    MobileAds.shared.requestConfiguration.testDeviceIdentifiers = testDeviceIdentifiers
    // [END set_test_device_ids]
  }

  private func disablePublisherFirstPartyID() {
    // [START disable_publisher_first_party_id]
    // Disables Publisher first-party ID.
    MobileAds.shared.requestConfiguration.setPublisherFirstPartyIDEnabled(false)
    // [END disable_publisher_first_party_id]
  }

  private func setChildAgeTreatment() {
    // [START set_child_age_treatment]
    // Indicates that ad requests should have child age treatment.
    MobileAds.shared.requestConfiguration.ageRestrictedTreatment = .child
    // [END set_child_age_treatment]
  }

  private func setTeenAgeTreatment() {
    // [START set_teen_age_treatment]
    // Indicates that ad requests should have teen age treatment.
    MobileAds.shared.requestConfiguration.ageRestrictedTreatment = .teen
    // [END set_teen_age_treatment]
  }

  private func setUnspecifiedAgeTreatment() {
    // [START set_unspecified_age_treatment]
    // Indicates that ad requests should have unspecified age treatment.
    MobileAds.shared.requestConfiguration.ageRestrictedTreatment = .unspecified
    // [END set_unspecified_age_treatment]
  }
}
