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

class DogTests: XCTestCase, DecodableTestCase {
  
  // MARK: - Instance Properties
  var dictionary: NSDictionary!
  var sut: Dog!
  
  // MARK: - Test Lifecyle
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
  
  // MARK: - Decodable - Test
  func test_decodable_sets_id() throws {
    try XCTAssertEqualToAny(sut.id, dictionary["id"])
  }
  
  func test_decodable_sets_sellerID() throws {
    try XCTAssertEqualToAny(sut.sellerID, dictionary["sellerID"])
  }
  
  func test_decodable_sets_birthday() throws {
    try XCTAssertEqualToDate(sut.birthday, dictionary["birthday"])
  }
  
  func test_decodable_sets_breed() throws {
    try XCTAssertEqualToAny(sut.breed, dictionary["breed"])
  }
  
  func test_decodable_sets_breederRating() throws {
    try XCTAssertEqualToAny(sut.breederRating, dictionary["breederRating"])
  }
  
  func test_decodable_sets_cost() throws {    
    try XCTAssertEqualToDecimal(sut.cost, dictionary["cost"])
  }
  
  func test_decodable_sets_created() throws {
    try XCTAssertEqualToDate(sut.created, dictionary["created"])
  }
  
  func test_decodable_sets_imageURL() throws {
    try XCTAssertEqualToURL(sut.imageURL, dictionary["imageURL"])
  }
  
  func test_decodable_sets_name() throws {
    try XCTAssertEqualToAny(sut.name, dictionary["name"])
  }
}
