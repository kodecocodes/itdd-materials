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

class LoginViewControllerTests: XCTestCase {
  var sut: LoginViewController!

  // 1
  override func setUpWithError() throws {
    try super.setUpWithError()
    sut = UIStoryboard(name: "Main", bundle: nil)
      .instantiateViewController(withIdentifier: "login")
    as? LoginViewController
    sut.api = UIApplication.appDelegate.api

    UIApplication.appDelegate.userId = nil
    sut.loadViewIfNeeded()
  }

  // 2
  override func tearDownWithError() throws {
    sut = nil
    UIApplication.appDelegate.userId = nil //do the "logout"
    try super.tearDownWithError()
  }

  func testSignIn_WithGoodCredentials_doesLogin() {
    // given
    sut.emailField.text = "agent@shield.org"
    sut.passwordField.text = "hailHydra"

    // when
    // 3
    let predicate = NSPredicate { _, _ -> Bool in
      UIApplication.appDelegate.userId != nil
    }
    let exp = expectation(for: predicate, evaluatedWith: sut, handler: nil)

    sut.signIn(sut.signInButton!)


    // then
    // 4
    wait(for: [exp], timeout: 5)
    XCTAssertNotNil(
      UIApplication.appDelegate.userId,
      "a successful login sets valid user id")
  }

  func testSignIn_WithBadCredentials_showsError() {
    // given
    sut.emailField.text = "bad@credentials.ca"
    sut.passwordField.text = "Shazam!"

    // when
    let predicate = NSPredicate { _, _ -> Bool in
      UIApplication.appDelegate.rootController?.presentedViewController != nil
    }
    let exp = expectation(for: predicate, evaluatedWith: sut, handler: nil)

    sut.signIn(sut.signInButton!)

    // then
    wait(for: [exp], timeout: 5)
    let presentedController = UIApplication.appDelegate.rootController?
      .presentedViewController as? ErrorViewController
    XCTAssertNotNil(
      presentedController,
      "should be showing an error controller")
    XCTAssertEqual(
      presentedController?.alertTitle,
      "Login Failed")
    XCTAssertEqual(
      presentedController?.subtitle,
      "Unauthorized")
  }
}
