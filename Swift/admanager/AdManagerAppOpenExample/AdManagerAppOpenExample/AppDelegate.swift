//
//  Copyright 2021 Google LLC
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return true
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    let rootViewController = application.windows.first(
      where: { $0.isKeyWindow })?.rootViewController
    if let rootViewController = rootViewController {
      // Do not show app open ad if the current view controller is SplashViewController.
      if rootViewController is SplashViewController {
        return
      }
      AppOpenAdManager.shared.showAdIfAvailable(viewController: rootViewController)
    }
  }
}
