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

class RootViewControllerTests: XCTestCase {

  var sut: RootViewController!
  
  override func setUp() {
    super.setUp()
    sut = loadRootViewController()
    sut.reset()
    AlertCenter.instance.clearAlerts()
  }
  
  override func tearDown() {
    sut = nil
    AlertCenter.instance.clearAlerts()
    super.tearDown()
  }
  
  // MARK: - Alert Container
  func testWhenLoaded_noAlertsAreShown() {
    XCTAssertEqual(AlertCenter.instance.alertCount, 0)
    XCTAssertTrue(sut.alertContainer.isHidden)
  }

  func testWhenAlertsPosted_alertContainerIsShown() {
    // given
    let exp = expectation(forNotification: AlertNotification.name,
                          object: nil, handler: nil)
    let alert = Alert("show the container")

    // when
    AlertCenter.instance.postAlert(alert: alert)

    // then
    wait(for: [exp], timeout: 1)
    XCTAssertFalse(sut.alertContainer.isHidden)
  }
}
