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

class UserTests: XCTestCase, DecodableTestCase {
  
  // MARK: - Instance Properties
  var dictionary: NSDictionary!
  var sut: User!
  
  // MARK: - Test Lifecycle
  override func setUp() {
    super.setUp()
    try! givenSUTFromJSON()
  }
  
  override func tearDown() {
    dictionary = nil
    sut = nil
    super.tearDown()
  }
  
  // MARK: - Type Tests
  func test_conformsTo_Decodable() {
    XCTAssertTrue((sut as Any) is Decodable) // cast silences a warning
  }
  
  func test_conformsTo_Equatable() {
    XCTAssertEqual(sut, sut) // requires Equatable conformance
  }
  
  // MARK: - Decodable Tests
  func test_decodable_sets_id() throws {
    try XCTAssertEqualToAny(sut.id, dictionary["id"])
  }
  
  func test_decodable_sets_about() throws {
    try XCTAssertEqualToAny(sut.about, dictionary["about"])
  }
  
  func test_decodable_sets_email() throws {
    try XCTAssertEqualToAny(sut.email, dictionary["email"])
  }
  
  func test_decodable_sets_name() throws {
    try XCTAssertEqualToAny(sut.name, dictionary["name"])
  }
  
  func test_decodable_sets_profileImageURL() throws {
    try XCTAssertEqualToURL(sut.profileImageURL!, dictionary["profileImageURL"])
  }
  
  func test_decodable_sets_reviewCount() throws {
    try XCTAssertEqualToAny(sut.reviewCount, dictionary["reviewCount"])
  }
  
  func test_decodable_sets_reviewRatingAverage() throws {
    try XCTAssertEqualToAny(sut.reviewRatingAverage, dictionary["reviewRatingAverage"])
  }
}
