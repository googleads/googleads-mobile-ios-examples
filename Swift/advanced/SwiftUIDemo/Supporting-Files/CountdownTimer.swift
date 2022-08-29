import Combine
import SwiftUI

class CountdownTimer: ObservableObject {
  @Published var timeLeft: Int
  private(set) var countdownTime: Int
  private var timerSubscriptions = Set<AnyCancellable>()
  private var applicationSubscriptions = Set<AnyCancellable>()
  private var countdownState = CountdownState.notStarted

  private enum CountdownState: Int {
    case notStarted
    case active
    case paused
    case ended
  }

  var isComplete: Bool {
    return countdownState == .ended
  }

  init(_ countdownTime: Int = 5) {
    self.countdownTime = max(countdownTime, 1)
    self.timeLeft = max(countdownTime, 1)

    NotificationCenter
      .Publisher(
        center: .default,
        name: UIApplication.didEnterBackgroundNotification
      )
      .sink { [weak self] _ in
        guard let self = self else { return }

        self.pause()
      }
      .store(in: &applicationSubscriptions)

    NotificationCenter
      .Publisher(
        center: .default,
        name: UIApplication.willEnterForegroundNotification
      )
      .sink { [weak self] _ in
        guard let self = self, self.countdownState == .paused else { return }

        self.resumeTimer()
        self.countdownState = .active
      }
      .store(in: &applicationSubscriptions)
  }

  func start() {
    timeLeft = countdownTime
    resumeTimer()
    countdownState = .active
  }

  func pause() {
    guard countdownState == .active else { return }

    timerSubscriptions.removeAll()
    countdownState = .paused
  }

  private func decrementTimeLeft() {
    timeLeft -= 1
    if timeLeft <= 0 {
      timerSubscriptions.removeAll()
      countdownState = .ended
    }
  }

  private func resumeTimer() {
    Timer.publish(every: 1.0, on: .main, in: .common)
      .autoconnect()
      .sink { _ in
        self.decrementTimeLeft()
      }
      .store(in: &timerSubscriptions)
  }
}
