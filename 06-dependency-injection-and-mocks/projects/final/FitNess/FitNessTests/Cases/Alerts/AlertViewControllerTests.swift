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

class AlertViewControllerTests: XCTestCase {

  var sut: AlertViewController!

  // MARK: - Test Lifecycle
  override func setUp() {
    super.setUp()
    let rvc = loadRootViewController()
    sut = rvc.alertController
    AlertCenter.instance.clearAlerts()
  }

  override func tearDown() {
    sut = nil
    AlertCenter.instance.clearAlerts()
    super.tearDown()
  }

  // MARK: - Given
  func givenAlreadyHasAlerts(count: Int) {
    for i in 1...count {
      let alert = Alert("alert \(i)")
      AlertCenter.instance.postAlert(alert: alert)
    }
  }

  // MARK: - Stacked Alert Frames
  func testValues_whenNoAlerts_doesNotHaveJustOneAlert() {
    // then
    let values = sut.calculateViewValues()
    XCTAssertFalse(values.justOneAlert)
  }

  func testValues_withOneAlert_isCorrectForOneView() {
    // given
    givenAlreadyHasAlerts(count: 1)

    // then
    let values = sut.calculateViewValues()
    XCTAssertTrue(values.justOneAlert)
    XCTAssertEqual(values.topAlertInset, 0)
    XCTAssertEqual(values.alertText, "alert 1")
  }

  func testValues_withTwoAlerts_isCorrectForAStackOfViews() {
    // given
    givenAlreadyHasAlerts(count: 2)

    // then
    let values = sut.calculateViewValues()
    XCTAssertFalse(values.justOneAlert)
    XCTAssertTrue(values.topAlertInset > 0)
    XCTAssertEqual(values.alertText, "alert 1")
  }

  // MARK: - Test Severity Colors
  func testColor_isGoodforGoodAlert() {
    // given
    let goodAlert = Alert("Something good", severity: .good)

    // when
    AlertCenter.instance.postAlert(alert: goodAlert)

    // then
    let values = sut.calculateViewValues()
    XCTAssertEqual(values.topColor, Alert.Severity.good.color)
  }

  func testColor_isBadforBadAlert() {
    // given
    let badAlert = Alert("Something bad", severity: .bad)

    // when
    AlertCenter.instance.postAlert(alert: badAlert)

    // then
    let values = sut.calculateViewValues()
    XCTAssertEqual(values.topColor, Alert.Severity.bad.color)
  }

  func testColor_withTwoAlerts_reflectsSeverity() {
    // given
    let goodAlert = Alert("Something good", severity: .good)
    let badAlert = Alert("Something bad", severity: .bad)

    // when
    AlertCenter.instance.postAlert(alert: goodAlert)
    AlertCenter.instance.postAlert(alert: badAlert)

    // then
    let values = sut.calculateViewValues()
    XCTAssertEqual(values.topColor, Alert.Severity.good.color)
    XCTAssertEqual(values.bottomColor, Alert.Severity.bad.color)
  }

  func testColor_whenTopCleared_reflectsNewTop() {
    // given
    let goodAlert = Alert("Something good", severity: .good)
    AlertCenter.instance.postAlert(alert: goodAlert)
    let badAlert = Alert("Something bad", severity: .bad)
    AlertCenter.instance.postAlert(alert: badAlert)

    // when
    AlertCenter.instance.clear(alert: goodAlert)

    // then
    let values = sut.calculateViewValues()
    XCTAssertEqual(values.topColor, Alert.Severity.bad.color)
    XCTAssertNil(values.bottomColor)
  }

  // MARK: - Alert Closing Tests
  func testClose_clearsAnAlert() {
    // given
    let alert = Alert("Achtung!")
    AlertCenter.instance.postAlert(alert: alert) //guaranteed to have 1 alert by AlertCenterTests.testPostOne_generatesANotification

    // when
    sut.closeAlert(sut as Any)

    // then
    XCTAssertEqual(AlertCenter.instance.alertCount, 0)
    XCTAssertNil(AlertCenter.instance.topAlert)
  }
}
