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
@testable import MyBiz

class CalendarModelTests: XCTestCase {

  var sut: CalendarModel!
  var mockAPI: MockAPI!

  override func setUp() {
    super.setUp()
    mockAPI = MockAPI()
    sut = CalendarModel(api: mockAPI)
  }

  override func tearDown() {
    sut = nil
    mockAPI = nil
    super.tearDown()
  }
  
  // MARK: - Birthdays
  
  func testModel_whenGivenEmployeeList_generatesBirthdayEvents() {
    // given
    let employees = mockEmployees()

    // when
    let events = sut.convertBirthdays(employees)

    // then
    let expectedEvents = mockBirthdayEvents()
    XCTAssertEqual(events, expectedEvents)
  }

  func testModel_whenBirthdaysLoaded_getsBirthdayEvents() {
    // given
    mockAPI.mockEmployees = mockEmployees()
    let exp = expectation(description: "birthdays loaded")

    // when
    var loadedEvents: [Event]?
    sut.getBirthdays { res in
      loadedEvents = try? res.get()
      exp.fulfill()
    }

    // then
    wait(for: [exp], timeout: 1)
    let expectedEvents = mockBirthdayEvents()
    XCTAssertEqual(loadedEvents, expectedEvents)
  }
  
  func testModel_whenGetOrgFails_returnsError() {
    // given
    let exp = expectation(description: "birthdays loaded")
    mockAPI.mockError = staticMockError
    
    // when
    var receivedError: Error?
    sut.getBirthdays { res in
      if case .failure(let error) = res {
        receivedError = error
      }
      exp.fulfill()
    }
    
    // then
    wait(for: [exp], timeout: 1)
    XCTAssertNotNil(receivedError)
  }
  
  // MARK: - Events
  
  func testModel_whenEventsLoaded_getsEvents() {
    // given
    let expectedEvents = mockEvents()
    mockAPI.mockEvents = expectedEvents
    let exp = expectation(description: "events loaded")

    // when
    var loadedEvents: [Event]?
    sut.getEvents { res in
      loadedEvents = try? res.get()
      exp.fulfill()
    }

    // then
    wait(for: [exp], timeout: 1)
    XCTAssertEqual(loadedEvents, expectedEvents)
  }
  
  func testModel_whenGetEventsFails_returnsError() {
    // given
    let exp = expectation(description: "events loaded")
    mockAPI.mockError = staticMockError
    
    // when
    var receivedError: Error?
    sut.getEvents { res in
      if case let .failure(error) = res {
        receivedError = error
      }
      exp.fulfill()
    }
    
    // then
    wait(for: [exp], timeout: 1)
    XCTAssertNotNil(receivedError)
  }
  
  // MARK: - Combined
  
  func testModel_whenGetAll_getsBirthdaysAndEvents() {
    // given
    let exp = expectation(description: "all loaded")
    mockAPI.mockEvents = mockEvents()
    mockAPI.mockEmployees = mockEmployees()
    let expectedEvents = mockAPI.mockEvents + mockBirthdayEvents()
    
    var loadedEvents: [Event]!
    sut.getAll { res in
      loadedEvents = try? res.get()
      exp.fulfill()
    }
    
    // then
    wait(for: [exp], timeout: 1)
    XCTAssertEqual(loadedEvents.sorted(), expectedEvents.sorted())
  }
}
