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

import UserMessagingPlatform

private class UMPSnippets {

  // Example identifier.
  let consentSyncIdentifier = "12JD92JD8078S8J29SDOAKC0EF230337"

  func syncConsentIdentifier() {
    // [START sync_consent_identifier]
    let parameters = RequestParameters()
    // Sets the consent sync ID to sync the user consent status collected with the same ID.
    // parameters.consentSyncID = consentSyncIdentifier

    // Proceed with calling the UMP SDK as normal.
    ConsentInformation.shared.requestConsentInfoUpdate(with: parameters) { _ in
      // ...
    }
    // [END sync_consent_identifier]
  }
}
