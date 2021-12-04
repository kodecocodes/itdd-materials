/// Copyright (c) 2021 Razeware LLC
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
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import XCTest
@testable import MyBiz

class CalendarViewControllerTests: XCTestCase {
  var sut: CalendarViewController!
  var mockAnalytics: MockAnalyticsAPI!
  var mockAPI: MockAPI!

  override func setUpWithError() throws {
    super.setUp()
    sut = UIStoryboard(name: "Main", bundle: nil)
      .instantiateViewController(withIdentifier: "Calendar")
    as? CalendarViewController

    mockAPI = MockAPI()
    sut.api = mockAPI

    mockAnalytics = MockAnalyticsAPI()
    sut.analytics = mockAnalytics

    sut.loadViewIfNeeded()
  }

  override func tearDownWithError() throws {
    mockAPI = nil
    mockAnalytics = nil
    sut = nil
    super.tearDown()
  }

  func testLoadEvents_getsBirthdays () {
    // given
    mockAPI.mockEmployees = mockEmployees()
    let expectedEvents = mockBirthdayEvents()

    // when
    let predicate = NSPredicate { _, _ -> Bool in
      !self.sut.events.isEmpty
    }
    let exp = expectation(for: predicate, evaluatedWith: sut, handler: nil)

    sut.loadEvents()

    // then
    wait(for: [exp], timeout: 2)
    XCTAssertEqual(sut.events, expectedEvents)
  }

  func testLoadEvents_getsBirthdaysAndEvents () {
    // given
    mockAPI.mockEmployees = mockEmployees()
    mockAPI.mockEvents = mockEvents()
    let expectedEvents = mockAPI.mockEvents + mockBirthdayEvents()

    // when
    let predicate = NSPredicate { _, _ -> Bool in
      !self.sut.events.isEmpty
    }
    let exp = expectation(for: predicate, evaluatedWith: sut, handler: nil)

    sut.loadEvents()

    // then
    wait(for: [exp], timeout: 2)
    XCTAssertEqual(sut.events, expectedEvents)
  }

  // MARK: - Analytics Tests
  func testController_whenShown_sendsAnalytics() {
    // when
    sut.viewWillAppear(true)

    // then
    XCTAssertTrue(mockAnalytics.reportSent)
  }
}
