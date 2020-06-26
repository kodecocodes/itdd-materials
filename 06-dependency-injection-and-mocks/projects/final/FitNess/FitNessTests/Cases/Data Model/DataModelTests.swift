/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import XCTest
@testable import FitNess

class DataModelTests: XCTestCase {

  var sut: DataModel!

  override func setUp() {
    super.setUp()
    sut = DataModel()
  }

  override func tearDown() {
    sut = nil
    AlertCenter.instance.clearAlerts()
    super.tearDown()
  }

  // MARK: - Given
  func givenSomeProgress() {
    sut.goal = 1000
    sut.distance = 10
    sut.steps = 100
    sut.nessie.distance = 50
  }

  func givenExpectationForNotification(alert: Alert) -> XCTestExpectation {
    let exp = XCTNSNotificationExpectation(name: AlertNotification.name,
                                           object: AlertCenter.instance,
                                           notificationCenter: AlertCenter.instance.notificationCenter)
    exp.handler = alertHandler(alert)
    exp.expectedFulfillmentCount = 1
    exp.assertForOverFulfill = true
    return exp
  }

  // MARK: - Lifecycle
  func testModel_whenRestarted_goalIsUnset() {
    // given
    givenSomeProgress()

    // when
    sut.restart()

    // then
    XCTAssertNil(sut.goal)
  }

  func testModel_whenRestarted_stepsAreCleared() {
    // given
    givenSomeProgress()

    // when
    sut.restart()

    // then
    XCTAssertLessThanOrEqual(sut.steps, 0)
  }

  func testModel_whenRestarted_distanceIsCleared() {
    // given
    givenSomeProgress()

    // when
    sut.restart()

    // then
    XCTAssertEqual(sut.distance, 0)
  }

  func testModel_whenRestarted_nessieIsReset() {
    // given
    givenSomeProgress()

    // when
    sut.restart()

    // then
    XCTAssertEqual(sut.nessie.distance, 0)
  }

  // MARK: - Goal
  func testModel_whenStarted_goalIsNotReached() {
    XCTAssertFalse(sut.goalReached,
                   "goalReached should be false when the model is created")
  }

  func testModel_whenStepsReachGoal_goalIsReached() {
    // given
    sut.goal = 1000

    // when
    sut.steps = 1000

    // then
    XCTAssertTrue(sut.goalReached)
  }

  func testGoal_whenUserCaught_cannotBeReached() {
    //given goal should be reached
    sut.goal = 1000
    sut.steps = 1000

    // when caught by nessie
    sut.distance = 100
    sut.nessie.distance = 100

    // then
    XCTAssertFalse(sut.goalReached)
  }

  // MARK: - Nessie
  func testModel_whenStarted_userIsNotCaught() {
    XCTAssertFalse(sut.caught)
  }

  func testModel_whenUserAheadOfNessie_isNotCaught() {
    // given
    sut.distance = 1000
    sut.nessie.distance = 100

    // then
    XCTAssertFalse(sut.caught)
  }

  func testModel_whenNessieAheadofUser_isCaught() {
    // given
    sut.nessie.distance = 1000
    sut.distance = 100

    // then
    XCTAssertTrue(sut.caught)
  }

  // MARK: - Alerts
  func testWhenStepsHit25Percent_milestoneNotificationGenerated() {
    // given
    sut.goal = 400
    let exp = givenExpectationForNotification(alert: .milestone25Percent)
    // when
    sut.steps = 100
    // then
    wait(for: [exp], timeout: 1)
  }

  func testWhenStepsHit50Percent_milestoneNotificationGenerated() {
    // given
    sut.goal = 400
    let exp = givenExpectationForNotification(alert: .milestone50Percent)

    // when
    sut.steps = 200

    // then
    wait(for: [exp], timeout: 1)
  }

  func testWhenStepsHit75Percent_milestoneNotificationGenerated() {
    // given
    sut.goal = 400
    let exp = givenExpectationForNotification(alert: .milestone75Percent)

    // when
    sut.steps = 300

    // then
    wait(for: [exp], timeout: 1)
  }

  func testWhenStepsHit100Percent_milestoneNotificationGenerated() {
    // given
    sut.goal = 400
    let exp = givenExpectationForNotification(alert: .goalComplete)

    // when
    sut.steps = 400

    // then
    wait(for: [exp], timeout: 1)
  }

  func testWhenGoalReached_allMilestoneNotificationsSent() {
    // given
    sut.goal = 400
    let expectations = [
      givenExpectationForNotification(alert: .milestone25Percent),
      givenExpectationForNotification(alert: .milestone50Percent),
      givenExpectationForNotification(alert: .milestone75Percent),
      givenExpectationForNotification(alert: .goalComplete)
    ]

    // when
    sut.steps = 400

    // then
    wait(for: expectations, timeout: 1, enforceOrder: true)
  }

  func testWhenStepsIncreased_onlyOneMilestoneNotificationSent() {
    // given
    sut.goal = 10
    let expectations = [
      givenExpectationForNotification(alert: .milestone25Percent),
      givenExpectationForNotification(alert: .milestone50Percent),
      givenExpectationForNotification(alert: .milestone75Percent),
      givenExpectationForNotification(alert: .goalComplete)
    ]

    // clear out the alerts to simulate user interaction
    let alertObserver = AlertCenter.instance.notificationCenter
      .addObserver(forName: AlertNotification.name,
                   object: nil, queue: .main) { notification in
                    if let alert = notification.alert {
                      AlertCenter.instance.clear(alert: alert)
                    }
    }

    // when
    for step in 1...10 {
      self.sut.steps = step
      sleep(1)
    }

    // then
    wait(for: expectations, timeout: 20, enforceOrder: true)
    AlertCenter.instance.notificationCenter.removeObserver(alertObserver)
  }

  func testWhenNessieHalfway_warningNotificationGenerated() {
    // given
    sut.distance = 100
    let exp = givenExpectationForNotification(alert: .nessie50Percent)

    // when
    sut.updateNessie(distance: 50)

    // then
    wait(for: [exp], timeout: 1)
  }

  func testWhenNessieAlmostCaughtUp_warningNotificationGenerated() {
    // given
    sut.distance = 100
    let exp = givenExpectationForNotification(alert: .nessie90Percent)

    // when
    sut.updateNessie(distance: 90)

    // then
    wait(for: [exp], timeout: 1)
  }

  func testNessieCatchesUp_allNotificationsSent() {
    // given
    sut.distance = 80
    let expectations = [
      givenExpectationForNotification(alert: .nessie50Percent),
      givenExpectationForNotification(alert: .nessie90Percent),
      givenExpectationForNotification(alert: .caughtByNessie)
    ]

    // when
    sut.updateNessie(distance: 80)

    // then
    wait(for: expectations, timeout: 1, enforceOrder: true)
  }
}


