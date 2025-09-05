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

private class ReduceFirstImpressionLatencySnippets: UIViewController {

  func initializeForInitialAd() {

    // [START reduce_first_impression_latency]
    Task {
      // Create TaskGroup to manage a race between
      // SDK initialization and a 5 second timer.
      await withTaskGroup(of: Void.self) { group in

        // Create a task to initialize the MobileAds SDK.
        group.addTask {
          await withCheckedContinuation { continuation in
            MobileAds.shared.start { _ in
              // SDK initialization finished, resume the continuation.
              // This will not stop the SDK's internal initialization process.
              continuation.resume()
            }
          }
        }

        // Create a cancellable task which is a 5 second timer.
        group.addTask {
          do {
            // Sleep for 5 seconds. This delay *is* cancellable.
            try await Task.sleep(nanoseconds: 5 * 1_000_000_000)
          } catch {
            // cancelAll() will stop this task and throw CancellationError.
            // This happens if the SDK initialization completes first.
          }
        }

        // Wait for either task to complete.
        await group.next()

        // Cancel the timer task if the SDK initialized first.
        group.cancelAll()
      }

      // Load an ad once after task group finishes.
      await self.loadAd()

      // [END reduce_first_impression_latency]
    }
  }

  private func loadAd() async {
    // TODO: Load an ad
  }

}
