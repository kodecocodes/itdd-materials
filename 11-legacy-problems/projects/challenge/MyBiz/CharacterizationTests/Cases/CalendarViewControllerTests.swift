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

class CalendarViewControllerTests: XCTestCase {

  var sut: CalendarViewController!
  var mockAPI: MockAPI!

  override func setUp() {
    super.setUp()
    sut = UIStoryboard(name: "Main", bundle: nil)
      .instantiateViewController(withIdentifier: "Calendar") as? CalendarViewController

    mockAPI = MockAPI()
    sut.api = mockAPI

    sut.loadViewIfNeeded()
  }

  override func tearDown() {
    sut = nil
    mockAPI = nil
    super.tearDown()
  }
  
  func testLoadEvents_getsData() {
    // given
    let eventJson = """
    [{"name": "Alien invasion", "date": "2019-04-10T12:00:00+0000",
    "type": "Appointment", "duration": 3600.0},
     {"name": "Interview with Hydra", "date": "2019-04-10T17:30:00+0000",
    "type": "Appointment", "duration": 1800.0},
     {"name": "Panic attack", "date": "2019-04-17T14:00:00+0000",
    "type": "Meeting", "duration": 3600.0}]
    """
    let data = eventJson.data(using: .utf8)!
    let decoder: JSONDecoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    let expectedEvents = try! decoder.decode([Event].self, from: data)

    mockAPI.mockEvents = expectedEvents

    // when
    let exp = expectation(for: NSPredicate(block: { vc, _ -> Bool in
      return !(vc as! CalendarViewController).events.isEmpty
    }), evaluatedWith: sut, handler: nil)

    sut.loadEvents()

    // then
    wait(for: [exp], timeout: 1)
    XCTAssertEqual(sut.events, expectedEvents)
  }
}
