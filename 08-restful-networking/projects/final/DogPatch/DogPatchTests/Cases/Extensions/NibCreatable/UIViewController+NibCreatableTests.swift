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

class UIViewController_NibCreatableTests: XCTestCase {
  
  func test_nib_returnsExpected() throws {
    // given
    let nib = TestViewController.nib
    
    // when
    let view = nib.instantiate(withOwner: nil, options: nil).last
    
    // then
    XCTAssertNotNil(view)
  }
  
  func test_nibName_returnsExpected() {
    // given
    let expected = "\(TestViewController.self)"
    
    // when
    let actual = TestViewController.nibName
    
    // then
    XCTAssertEqual(actual, expected)
  }
  
  func test_nibName_canBeOverriden() {
    // given
    let expected = "SomethingElse"
    class TestViewController: UIViewController {
      override class var nibName: String { return "SomethingElse" }
    }
    
    // when
    let actual = TestViewController.nibName
    
    // then
    XCTAssertEqual(actual, expected)
  }
  
  func test_nibBundle_returnsExpected() {
    // given
    let expected = Bundle(for: TestViewController.self)
    
    // when
    let actual = TestViewController.nibBundle
    
    // then
    XCTAssertEqual(actual, expected)
  }
  
  func test_nibBundle_canBeOverridden() {
    // given
    class TestViewController: UIViewController {
      override class var nibBundle: Bundle? { return nil }
    }
    
    // when
    let actual = TestViewController.nibBundle
    
    // then
    XCTAssertNil(actual)
  }
  
  func test_instanceFromNib_returnsExpected() {
    // when
    let actual = TestViewController.instanceFromNib() as UIViewController
    
    // then    
    XCTAssertTrue(actual is TestViewController)
  }
}
