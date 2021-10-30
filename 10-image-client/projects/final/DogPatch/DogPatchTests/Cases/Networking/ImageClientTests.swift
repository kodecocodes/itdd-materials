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

class ImageClientTests: XCTestCase {
    
  var mockSession: MockURLSession!
  var sut: ImageClient!
  var service: ImageService {
    return sut as ImageService
  }
  var url: URL!
  
  var receivedTask: MockURLSessionTask?
  var receivedError: Error?
  var receivedImage: UIImage?
  var expectedImage: UIImage!
  var expectedError: NSError!
  
  var imageView: UIImageView!
  
  // MARK: - Test Lifecycle
  override func setUp() {
    super.setUp()
    mockSession = MockURLSession()
    url = URL(string: "https://example.com/image")!
    imageView = UIImageView()
    sut = ImageClient(responseQueue: nil,
                      session: mockSession)
  }
  
  override func tearDown() {
    mockSession = nil
    url = nil
    sut = nil
    receivedTask = nil
    receivedError = nil
    receivedImage = nil
    expectedImage = nil
    expectedError = nil
    imageView = nil
    super.tearDown()
  }
  
  // MARK: - Given
  func givenExpectedImage() {
    expectedImage = UIImage(named: "happy_dog")!
  }
  
  func givenExpectedError() {
    expectedError = NSError(domain: "com.example",
    code: 42,
    userInfo: nil)
  }
  
  // MARK: - When
  func whenDownloadImage(
    image: UIImage? = nil, error: Error? = nil) {
          
      receivedTask = sut.downloadImage(fromURL: url) { image, error in
          self.receivedImage = image
          self.receivedError = error
      } as? MockURLSessionTask
      
      guard let receivedTask = receivedTask else {
        return
      }
      if let image = image {
        receivedTask.completionHandler(
          image.pngData(), nil, nil)
        
      } else if let error = error {
        receivedTask.completionHandler(nil, nil, error)
      }
  }
  
  func whenSetImage() {
    givenExpectedImage()
    sut.setImage(on: imageView, fromURL: url, withPlaceholder: nil)
    receivedTask = sut.cachedTaskForImageView[imageView]
      as? MockURLSessionTask
    receivedTask?.completionHandler(
      expectedImage.pngData(), nil, nil)
  }
  
  // MARK: - Then
  func verifyDownloadImageDispatched(image: UIImage? = nil,
                                     error: Error? = nil,
                                     line: UInt = #line) {
    mockSession.givenDispatchQueue()
    sut = ImageClient(responseQueue: .main,
                      session: mockSession)
    
    var receivedThread: Thread!
    let expectation = self.expectation(
      description: "Completion wasn't called")
    
    // when
    let dataTask =
      sut.downloadImage(fromURL: url) { _, _ in
        receivedThread = Thread.current
        expectation.fulfill()
      } as! MockURLSessionTask
    dataTask.completionHandler(image?.pngData(), nil, error)
    
    // then
    waitForExpectations(timeout: 0.2)
    XCTAssertTrue(receivedThread.isMainThread, line: line)
  }
  
  // MARK: - Static Properties - Tests
  func test_shared_setsResponseQueue() {
    XCTAssertEqual(ImageClient.shared.responseQueue, .main)
  }
  
  func test_shared_setsSession() {
    XCTAssertTrue(ImageClient.shared.session === URLSession.shared)
  }
  
  // MARK: - Object Lifecycle - Tests
  func test_init_setsCachedImageForURL() {
    XCTAssertTrue(sut.cachedImageForURL.isEmpty)
  }
  
  func test_init_setsCachedTaskForImageView() {
    XCTAssertTrue(sut.cachedTaskForImageView.isEmpty)
  }
    
  func test_init_setsResponseQueue() {
    XCTAssertTrue(sut.responseQueue === nil)
  }
  
  func test_init_setsSession() {
    XCTAssertTrue(sut.session === mockSession)
  }
  
  // MARK: - ImageService - Tests
  func test_conformsTo_ImageService() {
    XCTAssertTrue((sut as AnyObject) is ImageService)
  }
  
  func test_imageService_declaresDownloadImage() {
    _ = service.downloadImage(fromURL:url) { _, _ in }
  }
  
  func test_imageService_declaresSetImageOnImageView() {
    // given
    let imageView = UIImageView()
    let placeholder = UIImage(named: "image_placeholder")!
    
    // then
    service.setImage(on: imageView,
                     fromURL: url,
                     withPlaceholder: placeholder)
  }
  
  func test_downloadImage_createsExpectedTask() {
    // when
    whenDownloadImage()
            
    // then
    XCTAssertEqual(receivedTask?.url, url)
  }
  
  func test_downloadImage_callsResumeOnTask() {
    // when
    whenDownloadImage()

    // then
    XCTAssertTrue(receivedTask?.calledResume ?? false)
  }
  
  func test_downloadImage_givenImage_callsCompletionWithImage() {
    // given
    givenExpectedImage()

    // when
    whenDownloadImage(image: expectedImage)

    // then
    XCTAssertEqual(expectedImage.pngData(),
                   receivedImage?.pngData())
  }
  
  func test_downloadImage_givenError_callsCompletionWithError() {
    // given
    givenExpectedError()

    // when
    whenDownloadImage(error: expectedError)

    // then
    XCTAssertEqual(expectedError, receivedError as NSError?)
  }
  
  func test_downloadImage_givenImage_dispatchesToResponseQueue() {
    // given
    givenExpectedImage()

    // then
    verifyDownloadImageDispatched(image: expectedImage)
  }
  
  func test_downloadImage_givenError_dispatchesToResponseQueue() {
    // given
    givenExpectedError()

    // then
    verifyDownloadImageDispatched(error: expectedError)
  }
  
  func test_downloadImage_givenImage_cachesImage() {
    // given
    givenExpectedImage()
    
    // when
    whenDownloadImage(image: expectedImage)
    
    // then
    XCTAssertEqual(sut.cachedImageForURL[url]?.pngData(),
                   expectedImage.pngData())
  }
  
  func test_downloadImage_givenCachedImage_returnsNilDataTask() {
    // given
    givenExpectedImage()
    
    // when
    whenDownloadImage(image: expectedImage)
    whenDownloadImage(image: expectedImage)
    
    // then
    XCTAssertNil(receivedTask)
  }
  
  func test_downloadImage_givenCachedImage_callsCompletionWithImage() {
    // given
    givenExpectedImage()
    
    // when
    whenDownloadImage(image: expectedImage)
    receivedImage = nil
    
    whenDownloadImage(image: expectedImage)
    
    // then
    XCTAssertEqual(expectedImage.pngData(),
                   receivedImage?.pngData())
  }
  
  func test_setImageOnImageView_cancelsExistingDataTask() {
    // given
    let task = MockURLSessionTask(completionHandler: { _, _, _ in },
                                  url: url,
                                  queue: nil)
    sut.cachedTaskForImageView[imageView] = task
    
    // when
    sut.setImage(on: imageView, fromURL: url, withPlaceholder: nil)

    // then
    XCTAssertTrue(task.calledCancel)
  }
  
  func test_setImageOnImageView_setsPlaceholderOnImageView() {
    // given
    givenExpectedImage()

    // when
    sut.setImage(on: imageView,
                 fromURL: url,
                 withPlaceholder: expectedImage)

    // then
    XCTAssertEqual(imageView.image?.pngData(),
                   expectedImage.pngData())
  }
  
  func test_setImageOnImageView_cachesTask() {
    // when
    sut.setImage(on: imageView,
                 fromURL: url,
                 withPlaceholder: nil)
    
    // then
    receivedTask = sut.cachedTaskForImageView[imageView]
      as? MockURLSessionTask
    XCTAssertEqual(receivedTask?.url, url)
  }
  
  func test_setImageOnImageView_onCompletionRemovesCachedTask() {
    // when
    whenSetImage()

    // then
    XCTAssertNil(sut.cachedTaskForImageView[imageView])
  }
  
  func test_setImageOnImageView_onCompletionSetsImage() {
    // when
    whenSetImage()

    // then
    XCTAssertEqual(imageView.image?.pngData(),
                   expectedImage.pngData())
  }
  
  func test_setImageOnImageView_givenError_doesnSetImage() {
    // given
    givenExpectedImage()
    givenExpectedError()
    
    // when
    sut.setImage(on: imageView,
                 fromURL: url,
                 withPlaceholder: expectedImage)
    receivedTask = sut.cachedTaskForImageView[imageView]
      as? MockURLSessionTask
    receivedTask?.completionHandler(nil, nil, expectedError)
    
    // then
    XCTAssertEqual(imageView.image?.pngData(),
                   expectedImage.pngData())
  }
}
