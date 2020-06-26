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

class AlertCenterTests: XCTestCase {

  var sut: AlertCenter!

  override func setUp() {
    super.setUp()
    sut = AlertCenter()
  }

  override func tearDown() {
    AlertCenter.instance.clearAlerts()
    sut = nil
    super.tearDown()
  }

  // MARK: - Given
  @discardableResult
  func givenHasAnAlertAlready() -> Alert {
    let alert = Alert("pre-populated alert")
    sut.postAlert(alert: alert)
    return alert
  }

  func givenAlreadyHasAlerts(count: Int) {
    for i in 1...count {
      let alert = Alert("alert \(i)")
      sut.postAlert(alert: alert)
    }
    XCTAssertEqual(sut.alertCount, count)
  }

  // MARK: - Computed Variable Tests
  func testNextUp_withNoAlerts_isNil() {
    XCTAssertNil(sut.nextUp)
  }

  func testNextUp_withOneAlert_isNil() {
    // given
    givenAlreadyHasAlerts(count: 1)

    // then
    XCTAssertNil(sut.nextUp)
  }

  func testNextUp_withTwoAlerts_isTheSecond() {
    // given
    givenAlreadyHasAlerts(count: 2)

    //then
    XCTAssertEqual(sut.nextUp?.text, "alert 2")
  }

  func testNextUp_withThreeAlerts_isStilTheSecond() {
    // given
    givenAlreadyHasAlerts(count: 3)

    //then
    XCTAssertEqual(sut.nextUp?.text, "alert 2")
  }

  func testNextUp_withThreeAlerts_isTheThirdAfterClearing() {
    // given
    givenAlreadyHasAlerts(count: 3)

    // when
    sut.clear(alert: sut.topAlert!)

    //then
    XCTAssertEqual(sut.nextUp?.text, "alert 3")
  }

  // MARK: - Posting Notifications
  func testPostOne_generatesANotification() {
    // given
    let exp = expectation(forNotification: AlertNotification.name,
                          object: sut,
                          handler: nil)
    let alert = Alert("this is an alert")

    // when
    sut.postAlert(alert: alert)

    // then
    wait(for: [exp], timeout: 1)
  }

  func testPostingTwoAlerts_generatesTwoNotifications() {
    //given
    let exp = expectation(forNotification: AlertNotification.name,
                           object: sut,
                           handler: nil)
    exp.expectedFulfillmentCount = 2
    let alert1 = Alert("this is the first alert")
    let alert2 = Alert("this is the second alert")

    // when
    sut.postAlert(alert: alert1)
    sut.postAlert(alert: alert2)

    // then
    wait(for: [exp], timeout: 1)
  }

  func testPostDouble_generatesOnlyOneNotification() {
    //given
    let exp = expectation(forNotification: AlertNotification.name,
                          object: sut,
                          handler: nil)
    exp.expectedFulfillmentCount = 2
    exp.isInverted = true
    let alert = Alert("this is an alert")

    // when
    sut.postAlert(alert: alert)
    sut.postAlert(alert: alert)

    // then
    wait(for: [exp], timeout: 1)
  }

  // MARK: - Alert Count
  func testWhenInitialized_AlertCountIsZero() {
    XCTAssertEqual(sut.alertCount, 0)
  }

  func testWhenAlertPosted_CountIsIncreased() {
    // given
    let alert = Alert("An alert")

    // when
    sut.postAlert(alert: alert)

    // then
    XCTAssertEqual(sut.alertCount, 1)
  }

  func testWhenCleared_CountIsZero() {
    // given
    let alert = Alert("An alert")
    sut.postAlert(alert: alert)

    // when
    sut.clearAlerts()

    // then
    XCTAssertEqual(sut.alertCount, 0)
  }

  // MARK: - Notification Contents
  func testNotification_whenPosted_containsAlertObject() {
    // given
    let alert = Alert("test contents")
    let exp = expectation(forNotification: AlertNotification.name,
                          object: sut, handler: nil)

    var postedAlert: Alert?
    sut.notificationCenter.addObserver(forName: AlertNotification.name,
                                       object: sut, queue: nil)
    { notification in
      postedAlert = notification.alert
    }

    // when
    sut.postAlert(alert: alert)

    // then
    wait(for: [exp], timeout: 1)
    XCTAssertNotNil(postedAlert, "should have an sent an alert")
    XCTAssertEqual(alert, postedAlert, "should have sent the original alert")
  }

  // MARK: - Clearing Individual Alerts
  func testWhenCleared_alertIsRemoved() {
    // given
    let alert = givenHasAnAlertAlready()

    // when
    sut.clear(alert: alert)

    // then
    XCTAssertEqual(sut.alertCount, 0)
  }

  func testClearingAlert_notInQueue_doesNotChangeQueue() {
    // given
    givenHasAnAlertAlready()
    let alertNotInQueue = Alert("not posted")

    // when
    sut.clear(alert: alertNotInQueue)

    // then
    XCTAssertEqual(sut.alertCount, 1)
  }

  func testClearingAlertTwice_doesNotCrash() {
    // given
    let alert = givenHasAnAlertAlready()

    // when
    sut.clear(alert: alert)
    sut.clear(alert: alert)

    // then
    XCTAssertEqual(sut.alertCount, 0)
  }
}
