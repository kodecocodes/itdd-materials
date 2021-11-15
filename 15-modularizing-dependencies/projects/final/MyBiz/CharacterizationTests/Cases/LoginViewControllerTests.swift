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
@testable import Login
@testable import UIHelpers

class LoginViewControllerTests: XCTestCase {
  var sut: LoginViewController!
  var api: SpyAPI!

  override func setUpWithError() throws {
    try super.setUpWithError()
    sut = UIStoryboard(name: "Main", bundle: nil)
      .instantiateViewController(withIdentifier: "login")
    as? LoginViewController
    UIApplication.appDelegate.userId = nil

    api = SpyAPI(api: UIApplication.appDelegate.api)
    sut.api = api

    sut.loadViewIfNeeded()
  }

  override func tearDownWithError() throws {
    sut = nil
    api = nil
    UIApplication.appDelegate.userId = nil //do the "logout"
    try super.tearDownWithError()
  }

  func givenGoodLogin() {
    sut.emailField.text = "agent@shield.org"
    sut.passwordField.text = "hailHydra"
  }

  func whenSignIn() {
    sut.signIn(sut.signInButton!)
  }

  // MARK: - Tests
  func testSignIn_WithGoodCredentials_doesLogin() {
    // given
    givenGoodLogin()

    // when
    let predicate = NSPredicate { _, _ -> Bool in
      UIApplication.appDelegate.userId != nil
    }
    let exp = expectation(for: predicate, evaluatedWith: sut, handler: nil)

    whenSignIn()

    // then
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

    whenSignIn()

    // then
    wait(for: [exp], timeout: 5)
    let root = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController
    let presentedController = root?.presentedViewController as? ErrorViewController
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

  func testSignIn_withGoodCredentials_callsLogin() {
    // given
    givenGoodLogin()

    // when
    whenSignIn()

    // then
    XCTAssertTrue(api.loginCalled)
  }

  func testSignIn_withInvalidEmail_doesNotCallLogin() {
    // given
    sut.emailField.text = "pizza" //bad
    sut.passwordField.text = "hailHydra" //good

    // when
    whenSignIn()

    // then
    XCTAssertFalse(api.loginCalled)
  }

  func testSignIn_withInvalidPassowerd_doesNotCallLogin() {
    // given
    sut.emailField.text = "agend@shield.org" //good
    sut.passwordField.text = "1" //bad

    // when
    whenSignIn()

    // then
    XCTAssertFalse(api.loginCalled)
  }
}
