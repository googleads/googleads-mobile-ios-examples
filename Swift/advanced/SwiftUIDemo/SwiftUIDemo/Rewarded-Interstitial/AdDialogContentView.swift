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
