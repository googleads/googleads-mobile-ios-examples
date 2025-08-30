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

private class ReduceFirstImpressionLatency: UIViewController {

  // [START reduce_first_impression_latency]

  func initializeForInitialAd() {

    // Create TaskGroup to init MobileAds SDK and set up a timer
    Task {
      await withTaskGroup(of: Void.self) { group in

        group.addTask {
          // (init-task) Fire & Forget, Initialize the MobileAds SDK
          await withCheckedContinuation { continuation in
            MobileAds.shared.start { _ in
              // group.cancelAll() will not affect MobileAds SDK initialization
              continuation.resume()
            }
          }
        }

        group.addTask {
          // (timer-task) Cancellable, wait for 5 seconds.
          do {
            try await Task.sleep(nanoseconds: 5 * 1_000_000_000)
          } catch {
            // cancelAll() will stop this task and throw CancellationError.
          }
        }

        // Wait for either task to complete.
        await group.next()

        // Finish & attempt to cancel all pending tasks. (only timer-task)
        group.cancelAll()
      }

      // Load an ad once after task group finishes.
      await self.loadAd()
    }
  }

  private func loadAd() async {
    // TODO: Load an ad
  }

  // [END reduce_first_impression_latency]

}
