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

@testable import DogPatch
import XCTest

class UIViewController_StoryboardCreatableTests: XCTestCase {
  
  func test_storyboard_returnsExpected() {
    // when
    let storyboard = TestViewController.storyboard
    let viewController = storyboard.instantiateViewController(withIdentifier: "TestViewController")
    
    // then
    XCTAssertTrue(viewController is TestViewController)
  }
  
  func test_storyboardBundle_returnsExpected() {
    // given
    let expected = Bundle(for: TestViewController.self)
    
    // when
    let actual = TestViewController.storyboardBundle
    
    // then
    XCTAssertEqual(actual, expected)
  }
  
  func test_storyboardBundle_canBeOverriden() {
    // given
    class TestViewController: UIViewController {
      override class var storyboardBundle: Bundle? { return nil }
    }
    
    // when
    let actual = TestViewController.storyboardBundle
    
    // then
    XCTAssertNil(actual)
  }
  
  func test_storyboardName_returnsExpected() {
    // given
    let expected = "Main"
    
    // when
    let actual = TestViewController.storyboardName
    
    // then
    XCTAssertEqual(actual, expected)
  }
  
  func test_storyboardName_canBeOverriden() {
    // given
    let expected = "SomethingElse"
    class TestViewController: UIViewController {
      override class var storyboardName: String { return "SomethingElse" }
    }
    
    // when
    let actual = TestViewController.storyboardName
    
    // then
    XCTAssertEqual(actual, expected)
  }
  
  func test_storyboardIdentifier_returnsExpected() {
    // given
    let expected = "\(TestViewController.self)"
    
    // when
    let actual = TestViewController.storyboardIdentifier
    
    // then
    XCTAssertEqual(actual, expected)
  }
  
  func test_storyboardIdentifier_canBeOverriden() {
    // given
    let expected = "SomethingElse"
    class TestViewController: UIViewController {
      override class var storyboardIdentifier: String { return "SomethingElse" }
    }
    
    // when
    let actual = TestViewController.storyboardIdentifier
    
    // then
    XCTAssertEqual(actual, expected)
  }
  
  func test_instanceFromStoryboard_returnsExpected() {
    // when
    let actual = TestViewController.instanceFromStoryboard() as UIViewController
    
    // then
    XCTAssertTrue(actual is TestViewController)
  }
}
