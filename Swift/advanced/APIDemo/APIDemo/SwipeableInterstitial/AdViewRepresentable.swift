//
//  Copyright 2026 Google LLC
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

import SwiftUI
import UIKit

@available(iOS 17.0, *)
struct AdViewRepresentable: UIViewRepresentable {
  let adView: UIView

  func makeUIView(context: Context) -> UIView {
    let container = UIView()
    container.backgroundColor = .black
    return container
  }

  func updateUIView(_ uiView: UIView, context: Context) {
    guard adView.superview !== uiView else { return }

    adView.removeFromSuperview()
    uiView.addSubview(adView)
    adView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      adView.topAnchor.constraint(equalTo: uiView.topAnchor),
      adView.bottomAnchor.constraint(equalTo: uiView.bottomAnchor),
      adView.leadingAnchor.constraint(equalTo: uiView.leadingAnchor),
      adView.trailingAnchor.constraint(equalTo: uiView.trailingAnchor),
    ])
  }
}
