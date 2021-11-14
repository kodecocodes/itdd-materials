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
import Login

class AppDelegateTests: XCTestCase {

  var sut: AppDelegate!

  override func setUp() {
    super.setUp()
    sut = AppDelegate()
    sut.window = UIApplication.shared.windows.first
    _ = sut.application(UIApplication.shared, didFinishLaunchingWithOptions: nil)
  }

  override func tearDown() {
    sut = nil
    super.tearDown()
  }

  func testAppDelegate_whenLoggedIn_hasUserId() {
    // given
    let note = Notification(name: UserLoggedInNotification, userInfo: [UserNotificationKey.userId: "testUser"])
    let exp = expectation(forNotification: UserLoggedInNotification, object: nil)

    // when
    DispatchQueue.main.async {
      NotificationCenter.default.post(note)
    }

    // then
    wait(for: [exp], timeout: 1)
    XCTAssertEqual(sut.userId, "testUser")
  }

  func testAppDelegate_whenLoggedOut_loginScreenShown() {
    // given
    let note = Notification(name: UserLoggedOutNotification)
    let exp = expectation(forNotification: UserLoggedOutNotification, object: nil)

    // when
    DispatchQueue.main.async {
      NotificationCenter.default.post(note)
    }

    // then
    wait(for: [exp], timeout: 1)
    let topController = sut.window?.rootViewController
    XCTAssertNotNil(topController)
    XCTAssertTrue(topController is LoginViewController)
  }
}
