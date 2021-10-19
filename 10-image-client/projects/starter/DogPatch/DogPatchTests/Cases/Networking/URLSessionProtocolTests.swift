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
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

@testable import DogPatch
import XCTest

class URLSessionProtocolTests: XCTestCase {
  var session: URLSession!
  var url: URL!
  
  override func setUp() {
    super.setUp()
    session = URLSession(configuration: .default)
    url = URL(string: "https://example.com")!
  }
  
  override func tearDown() {
    session = nil
    url = nil
    super.tearDown()
  }
  
  func test_URLSessionTask_conformsTo_URLSessionTaskProtocol() {
    // whe
    let task = session.dataTask(with: url)
    
    // then
    XCTAssertTrue((task as AnyObject) is URLSessionTaskProtocol)
  }
  
  func test_URLSession_conformsTo_URLSessionProtocol() {
    XCTAssertTrue((session as AnyObject) is URLSessionProtocol)
  }
  
  func test_URLSession_makeDataTask_createsTaskWithPassedInURL() {
    // when
    let task = session.makeDataTask(
      with: url,
      completionHandler: { _, _, _ in })
    as! URLSessionTask

    // then
    XCTAssertEqual(task.originalRequest?.url, url)
  }
  
  func test_URLSession_makeDataTask_createsTaskWithPassedInCompletion() {
    // given
    let expectation =
      expectation(description: "Completion should be called")

    // when
    let task = session.makeDataTask(
      with: url,
      completionHandler: { _, _, _ in expectation.fulfill() })
    as! URLSessionTask
    task.cancel()

    // then
    waitForExpectations(timeout: 0.2, handler: nil)
  }
}
