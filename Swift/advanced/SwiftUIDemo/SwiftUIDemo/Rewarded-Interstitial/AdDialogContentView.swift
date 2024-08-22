//
//  Copyright 2022 Google LLC
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

struct AdDialogContentView: View {
  @StateObject private var countdownTimer = CountdownTimer()
  @Binding var isPresenting: Bool
  @Binding var countdownComplete: Bool

  var body: some View {
    ZStack {
      Color.gray
        .opacity(0.75)
        .ignoresSafeArea(.all)

      dialogBody
        .background(Color.white)
        .padding()
    }
  }

  var dialogBody: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("Watch an ad for 10 more coins.")

      Text("Video starting in \(countdownTimer.timeLeft)...")
        .foregroundColor(.gray)

      HStack {
        Spacer()
        Button {
          isPresenting = false
        } label: {
          Text("No thanks")
            .bold()
            .foregroundColor(.red)
        }
      }
    }
    .onAppear {
      countdownComplete = false
    }
    .onChange(
      of: isPresenting,
      perform: { newValue in
        newValue ? countdownTimer.start() : countdownTimer.pause()
      }
    )
    .onChange(
      of: countdownTimer.isComplete,
      perform: { newValue in
        if newValue {
          countdownComplete = true
          isPresenting = false
        }
      }
    )
    .padding()
  }
}

struct AdDialogContentView_Previews: PreviewProvider {
  static var previews: some View {
    AdDialogContentView(isPresenting: .constant(true), countdownComplete: .constant(false))
  }
}
