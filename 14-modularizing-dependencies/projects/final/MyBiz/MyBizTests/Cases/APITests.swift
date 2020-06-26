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

class APITests: XCTestCase {

  var sut: API!

  override func setUp() {
    super.setUp()
    sut = MockAPI()
  }

  override func tearDown() {
    sut = nil
    super.tearDown()
  }

  func givenLoggedIn() {
    sut.token = Token(token: "Nobody", userID: UUID())
  }

  func testAPI_whenLogout_generatesANotification() {
    // given
    givenLoggedIn()
    let exp = expectation(forNotification:
      UserLoggedOutNotification, object: nil)

    // when
    sut.logout()

    // then
    wait(for: [exp], timeout: 1)
    XCTAssertNil(sut.token)
  }

  func testAPI_whenLogin_generatesANotification() {
    // given
    var userInfo: [AnyHashable: Any]?
    let exp = expectation(
      forNotification: UserLoggedInNotification,
      object: nil) { note in
        userInfo = note.userInfo
        return true
    }

    // when
    sut.login(username: "test", password: "test") { _ in }

    // then
    wait(for: [exp], timeout: 1)
    let userId = userInfo?[UserNotificationKey.userId]
    XCTAssertNotNil(userId,
                    "the log in notification should also have a user id")
  }
}
