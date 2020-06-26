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

class UIView_ApplyShaddowTests: XCTestCase {
  
  // MARK: - Instance Properties
  var sut: UIView!
  
  // MARK: - Test Lifecycle
  override func setUp() {
    super.setUp()
    sut = UIView()
  }
  
  // MARK: - Tests
  func test_applyShadow_setsBorderColor() throws {
    // given
    sut.layer.borderColor = nil
    
    // when
    sut.applyShadow()
    
    // then
    XCTAssertNotNil(sut.layer.borderColor)
  }
  
  func test_applyShadow_setsBorderWidth() {
    // given
    sut.layer.borderWidth = 0.0
    
    // when
    sut.applyShadow()
    
    // then
    XCTAssertGreaterThan(sut.layer.borderWidth, 0.0)
  }
  
  func test_applyShaddow_setsMasksToBounds() {
    // given
    sut.layer.masksToBounds = true
    
    // when
    sut.applyShadow()
    
    // then
    XCTAssertFalse(sut.layer.masksToBounds)
  }
  
  func test_applyShadow_setsShadowOffset() {
    // given
    let expected = CGSize(width: 3.0, height: 3.0)
    sut.layer.shadowOffset = CGSize(width: 42.0, height: 42.0)
    
    // when
    sut.applyShadow(shadowOffset: expected)
    let actual = sut.layer.shadowOffset
    
    // then
    XCTAssertEqual(actual, expected)
  }
  
  func test_applyShadow_setsShadowOpacity() {
    // given
    sut.layer.shadowOpacity = 0.0
    
    // when
    sut.applyShadow()
    
    // then
    XCTAssertGreaterThan(sut.layer.shadowOpacity, 0.0)
  }
  
  func test_applyShadow_setsShadowRadius() {
    // given
    let expected: CGFloat = 5.0
    sut.layer.shadowRadius = 42.0
    
    // when
    sut.applyShadow(shadowRadius: expected)
    let actual = sut.layer.shadowRadius
    
    // then
    XCTAssertEqual(actual, expected)
  }
}
