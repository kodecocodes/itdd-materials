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

class DogPatchClientTests: XCTestCase {
  
  var baseURL: URL!
  var mockSession: MockURLSession!
  var sut: DogPatchClient!
  
  var getDogsURL: URL {
    return URL(string: "dogs", relativeTo: baseURL)!
  }
 
  override func setUp() {
    super.setUp()
    baseURL = URL(string: "https://example.com/api/v1/")!
    mockSession = MockURLSession()
    sut = DogPatchClient(baseURL: baseURL,
                         session: mockSession,
                         responseQueue: nil)
  }

  override func tearDown() {
    baseURL = nil
    mockSession = nil
    sut = nil
    super.tearDown()
  }
  
  func whenGetDogs(
    data: Data? = nil,
    statusCode: Int = 200,
    error: Error? = nil) ->
    (calledCompletion: Bool, dogs: [Dog]?, error: Error?) {
      
      let response = HTTPURLResponse(url: getDogsURL,
                                     statusCode: statusCode,
                                     httpVersion: nil,
                                     headerFields: nil)
      
      var calledCompletion = false
      var receivedDogs: [Dog]? = nil
      var receivedError: Error? = nil
      
      let mockTask = sut.getDogs() { dogs, error in
        calledCompletion = true
        receivedDogs = dogs
        receivedError = error as NSError?
        } as! MockURLSessionTask
      
      mockTask.completionHandler(data, response, error)
      return (calledCompletion, receivedDogs, receivedError)
  }
  
  func verifyGetDogsDispatchedToMain(data: Data? = nil,
                                     statusCode: Int = 200,
                                     error: Error? = nil,
                                     line: UInt = #line) {
    
    mockSession.givenDispatchQueue()
    sut = DogPatchClient(baseURL: baseURL,
                         session: mockSession,
                         responseQueue: .main)
    
    let expectation = self.expectation(
      description: "Completion wasn't called")
    
    // when
    var thread: Thread!
    let mockTask = sut.getDogs() { dogs, error in
      thread = Thread.current
      expectation.fulfill()
      } as! MockURLSessionTask
    
    let response = HTTPURLResponse(url: getDogsURL,
                                   statusCode: statusCode,
                                   httpVersion: nil,
                                   headerFields: nil)
    mockTask.completionHandler(data, response, error)
    
    // then
    waitForExpectations(timeout: 0.2) { _ in
      XCTAssertTrue(thread.isMainThread, line: line)
    }
  }
  
  func test_conformsTo_DogPatchService() {
    XCTAssertTrue((sut as AnyObject) is DogPatchService)
  }
  
  func test_dogPatchService_declaresGetDogs() {
    // given
    let service = sut as DogPatchService

    // then
    _ = service.getDogs() { _, _ in }
  }
  
  func test_shared_setsBaseURL() {
    // given
    let baseURL = URL(
      string: "https://dogpatchserver.herokuapp.com/api/v1/")!
    
    // then
    XCTAssertEqual(DogPatchClient.shared.baseURL, baseURL)
  }
  
  func test_shared_setsSession() {
    XCTAssertTrue(
      DogPatchClient.shared.session === URLSession.shared)
  }
  
  func test_shared_setsResponseQueue() {
    XCTAssertEqual(DogPatchClient.shared.responseQueue, .main)
  }
  
  func test_init_sets_baseURL() {
    XCTAssertEqual(sut.baseURL, baseURL)
  }
  
  func test_init_sets_session() {    
    XCTAssertTrue(sut.session === mockSession)
  }
  
  func test_init_sets_responseQueue() {
    // given
    let responseQueue = DispatchQueue.main
    
    // when
    sut = DogPatchClient(baseURL: baseURL,
                         session: mockSession,
                         responseQueue: responseQueue)
    
    // then
    XCTAssertEqual(sut.responseQueue, responseQueue)
  }
  
  func test_getDogs_callsExpectedURL() {
    // when
    let mockTask = sut.getDogs() { _, _ in }
      as! MockURLSessionTask
    
    // then
    XCTAssertEqual(mockTask.url, getDogsURL)
  }
  
  func test_getDogs_callsResumeOnTask() {
    // when
    let mockTask = sut.getDogs() { _, _ in }
      as! MockURLSessionTask
    
    // then
    XCTAssertTrue(mockTask.calledResume)
  }
  
  func test_getDogs_givenResponseStatusCode500_callsCompletion() {
    // when
    let result = whenGetDogs(statusCode: 500)

    // then
    XCTAssertTrue(result.calledCompletion)
    XCTAssertNil(result.dogs)
    XCTAssertNil(result.error)
  }
  
  func test_getDogs_givenError_callsCompletionWithError() throws {
    // given
    let expectedError = NSError(domain: "com.DogPatchTests",
                                code: 42)

    // when
    let result = whenGetDogs(error: expectedError)

    // then
    XCTAssertTrue(result.calledCompletion)
    XCTAssertNil(result.dogs)

    let actualError = try XCTUnwrap(result.error as NSError?)
    XCTAssertEqual(actualError, expectedError)
  }
  
  func test_getDogs_givenValidJSON_callsCompletionWithDogs() throws {
      // given
      let data =
        try Data.fromJSON(fileName: "GET_Dogs_Response")
      
      let decoder = JSONDecoder()
      let dogs = try decoder.decode([Dog].self, from: data)
      
      // when
      let result = whenGetDogs(data: data)
      
      // then
      XCTAssertTrue(result.calledCompletion)
      XCTAssertEqual(result.dogs, dogs)
      XCTAssertNil(result.error)
  }
  
  func test_getDogs_givenInvalidJSON_callsCompletionWithError()
    throws {
    // given
    let data = try Data.fromJSON(
      fileName: "GET_Dogs_MissingValuesResponse")
    
    var expectedError: NSError!
    let decoder = JSONDecoder()
    do {
      _ = try decoder.decode([Dog].self, from: data)
    } catch {
      expectedError = error as NSError
    }
    
    // when
    let result = whenGetDogs(data: data)
    
    // then
    XCTAssertTrue(result.calledCompletion)
    XCTAssertNil(result.dogs)
    
    let actualError = try XCTUnwrap(result.error as NSError?)
    XCTAssertEqual(actualError.domain, expectedError.domain)
    XCTAssertEqual(actualError.code, expectedError.code)
  }
  
  func test_getDogs_givenHTTPStatusError_dispatchesToResponseQueue() {
    verifyGetDogsDispatchedToMain(statusCode: 500)
  }
  
  func test_getDogs_givenError_dispatchesToResponseQueue() {
    // given
    let error = NSError(domain: "com.DogPatchTests", code: 42)

    // then
    verifyGetDogsDispatchedToMain(error: error)
  }
  
  func test_getDogs_givenGoodResponse_dispatchesToResponseQueue()
    throws {
    // given
    let data = try Data.fromJSON(
      fileName: "GET_Dogs_Response")
    
    // then
    verifyGetDogsDispatchedToMain(data: data)
  }
  
  func test_getDogs_givenInvalidResponse_dispatchesToResponseQueue()
    throws {
      // given
      let data = try Data.fromJSON(
        fileName: "GET_Dogs_MissingValuesResponse")
      
      // then
      verifyGetDogsDispatchedToMain(data: data)
  }
}
