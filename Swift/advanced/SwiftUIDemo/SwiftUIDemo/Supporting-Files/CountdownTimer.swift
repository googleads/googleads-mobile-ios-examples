import Combine
import Foundation
import UIKit

/// Manages a countdown timer that pauses when the app enters the background and resumes on return.
final class CountdownTimer: ObservableObject {
  private static let defaultCountdownTime = 5
  private static let minimumCountdownTime = 1
  private static let defaultTickInterval: TimeInterval = 1.0

  /// Remaining seconds in the current countdown.
  @Published private(set) var timeLeft: Int

  /// Total duration in seconds for each countdown run.
  let countdownTime: Int

  /// Whether the countdown has reached zero.
  var isComplete: Bool {
    countdownState == .ended
  }

  private var timerSubscriptions = Set<AnyCancellable>()
  private var applicationSubscriptions = Set<AnyCancellable>()
  private var countdownState = CountdownState.notStarted
  private let tickInterval: TimeInterval

  private enum CountdownState {
    case notStarted
    case active
    case paused
    case ended
  }

  /// Creates a countdown timer with the given duration.
  ///
  /// - Parameters:
  ///   - countdownTime: Duration in seconds. Values less than `1` are clamped to `1`.
  ///   - notificationCenter: Notification center used to observe app lifecycle transitions.
  ///   - tickInterval: Interval in seconds between countdown ticks.
  init(
    _ countdownTime: Int = defaultCountdownTime,
    notificationCenter: NotificationCenter = .default,
    tickInterval: TimeInterval = defaultTickInterval
  ) {
    let clampedTime = max(countdownTime, Self.minimumCountdownTime)
    self.countdownTime = clampedTime
    self.timeLeft = clampedTime
    self.tickInterval = max(tickInterval, 0.01)

    notificationCenter
      .publisher(for: UIApplication.didEnterBackgroundNotification)
      .sink { [weak self] _ in
        guard let self else { return }
        self.pause()
      }
      .store(in: &applicationSubscriptions)

    notificationCenter
      .publisher(for: UIApplication.willEnterForegroundNotification)
      .sink { [weak self] _ in
        guard let self, self.countdownState == .paused else { return }
        self.resumeTimer()
        self.countdownState = .active
      }
      .store(in: &applicationSubscriptions)
  }

  /// Starts or restarts the countdown from `countdownTime`.
  func start() {
    timeLeft = countdownTime
    resumeTimer()
    countdownState = .active
  }

  /// Pauses an active countdown until the app returns to the foreground or `start()` is called.
  func pause() {
    guard countdownState == .active else { return }

    timerSubscriptions.removeAll()
    countdownState = .paused
  }

  private func decrementTimeLeft() {
    guard countdownState == .active else { return }

    timeLeft = max(timeLeft - 1, 0)
    if timeLeft == 0 {
      timerSubscriptions.removeAll()
      countdownState = .ended
    }
  }

  private func resumeTimer() {
    timerSubscriptions.removeAll()
    Timer.publish(every: tickInterval, on: .main, in: .common)
      .autoconnect()
      .sink { [weak self] _ in
        guard let self else { return }
        self.decrementTimeLeft()
      }
      .store(in: &timerSubscriptions)
  }
}
