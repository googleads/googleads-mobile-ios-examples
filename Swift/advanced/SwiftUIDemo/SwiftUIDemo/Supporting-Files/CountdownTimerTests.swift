import Combine
import Foundation
import UIKit
import XCTest

final class CountdownTimerTests: XCTestCase {
  private var cancellables = Set<AnyCancellable>()

  override func tearDown() {
    cancellables.removeAll()
    super.tearDown()
  }

  func testInit_defaultsToFiveAndClampsNonPositiveValues() {
    let defaultTimer = CountdownTimer()
    XCTAssertEqual(defaultTimer.countdownTime, 5)
    XCTAssertEqual(defaultTimer.timeLeft, 5)
    XCTAssertFalse(defaultTimer.isComplete)

    let zeroTimer = CountdownTimer(0)
    XCTAssertEqual(zeroTimer.countdownTime, 1)
    XCTAssertEqual(zeroTimer.timeLeft, 1)

    let negativeTimer = CountdownTimer(-10)
    XCTAssertEqual(negativeTimer.countdownTime, 1)
    XCTAssertEqual(negativeTimer.timeLeft, 1)
  }

  func testStart_countsDownToZeroAndMarksComplete() {
    let center = NotificationCenter()
    let timer = CountdownTimer(2, notificationCenter: center, tickInterval: 0.02)
    let completed = expectation(description: "Timer completes")

    timer.$timeLeft
      .dropFirst()
      .sink { timeLeft in
        if timeLeft == 0 {
          completed.fulfill()
        }
      }
      .store(in: &cancellables)

    timer.start()
    wait(for: [completed], timeout: 2.0)

    XCTAssertEqual(timer.timeLeft, 0)
    XCTAssertTrue(timer.isComplete)
  }

  func testStart_restartsFromFullDurationWithoutDuplicateTimers() {
    let center = NotificationCenter()
    let timer = CountdownTimer(2, notificationCenter: center, tickInterval: 0.02)
    let completed = expectation(description: "Restarted timer completes")

    var observedValues = [Int]()
    timer.$timeLeft
      .dropFirst()
      .sink { timeLeft in
        observedValues.append(timeLeft)
        if timeLeft == 0 {
          completed.fulfill()
        }
      }
      .store(in: &cancellables)

    timer.start()
    timer.start()
    wait(for: [completed], timeout: 2.0)

    XCTAssertEqual(observedValues, [2, 2, 1, 0])
    XCTAssertTrue(timer.isComplete)
  }

  func testLifecycleNotifications_pauseOnBackgroundAndResumeOnForeground() {
    let center = NotificationCenter()
    let timer = CountdownTimer(2, notificationCenter: center, tickInterval: 0.02)
    let completed = expectation(description: "Timer completes after foreground resume")

    timer.$timeLeft
      .dropFirst()
      .sink { timeLeft in
        if timeLeft == 0 {
          completed.fulfill()
        }
      }
      .store(in: &cancellables)

    timer.start()
    center.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
    XCTAssertFalse(timer.isComplete)

    center.post(name: UIApplication.willEnterForegroundNotification, object: nil)
    wait(for: [completed], timeout: 2.0)
    XCTAssertTrue(timer.isComplete)
  }

  func testForegroundNotification_doesNotStartUnstartedTimer() {
    let center = NotificationCenter()
    let timer = CountdownTimer(1, notificationCenter: center, tickInterval: 0.02)

    center.post(name: UIApplication.willEnterForegroundNotification, object: nil)

    XCTAssertEqual(timer.timeLeft, 1)
    XCTAssertFalse(timer.isComplete)
  }

  func testDeinit_doesNotRetainTimerWhileActive() {
    let center = NotificationCenter()
    weak var weakTimer: CountdownTimer?

    autoreleasepool {
      let timer = CountdownTimer(5, notificationCenter: center, tickInterval: 0.02)
      weakTimer = timer
      timer.start()
      XCTAssertNotNil(weakTimer)
    }

    XCTAssertNil(weakTimer)
  }
}
