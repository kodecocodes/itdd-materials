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

// MARK: - Test Module
@testable import DogPatch

// MARK: - Collaborators

// MARK: - Test Support
import XCTest

class LogoNavigationItemTests: XCTestCase {
  
  // MARK: - Instance Variables
  var sut: LogoNavigationItem!
  
  // MARK: - Then
  func assertTitleViewSetToLogoImageView(line: UInt = #line) throws {
    let imageView = try XCTUnwrap(sut.titleView as? UIImageView, line: line)
    XCTAssertEqual(imageView.image, UIImage(named: "logo_dog_patch"), line: line)
  }
  
  // MARK: - Init Tests
  func test_initTitle_setsTitleView() throws {
    // when
    sut = LogoNavigationItem(title: "title")
    
    // then
    try assertTitleViewSetToLogoImageView()
  }
  
  func test_initCoder_setsTitleView() throws {
    // given
    let bundle = Bundle(for: LogoNavigationItemTests.self)
    let nib = UINib(nibName: "TestLogoNavigationBar", bundle: bundle)
    let navigationBar = try XCTUnwrap(nib.instantiate(withOwner: nil, options: nil).last as? UINavigationBar)
    
    // when
    sut = try XCTUnwrap(navigationBar.topItem as? LogoNavigationItem)
    
    // then
    try assertTitleViewSetToLogoImageView()
  }
}
