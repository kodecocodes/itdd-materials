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

class ImageClientTests: XCTestCase {
    
  var mockSession: MockURLSession!
  var sut: ImageClient!
  var service: ImageService {
    return sut as ImageService
  }
  var url: URL!
  
  var receivedDataTask: MockURLSessionDataTask!
  var receivedError: Error!
  var receivedImage: UIImage!
  
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
    receivedDataTask = nil
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
    receivedDataTask = sut.downloadImage(
        fromURL: url) { image, error in
          self.receivedImage = image
          self.receivedError = error
      } as? MockURLSessionDataTask
      if let receivedDataTask = receivedDataTask {
        if let image = image {
          receivedDataTask.completionHandler(image.pngData(), nil, nil)
          
        } else if let error = error {
          receivedDataTask.completionHandler(nil, nil, error)
        }
      }
  }
  
  func whenSetImage() {
    givenExpectedImage()
    sut.setImage(on: imageView, fromURL: url, withPlaceholder: nil)
    receivedDataTask = sut.cachedTaskForImageView[imageView]
      as? MockURLSessionDataTask
    receivedDataTask.completionHandler(
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
      } as! MockURLSessionDataTask
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
    XCTAssertEqual(ImageClient.shared.session, .shared)
  }
  
  // MARK: - Object Lifecycle - Tests  
  func test_init_setsCachedImageForURL() {
    XCTAssertEqual(sut.cachedImageForURL, [:])
  }
  
  func test_init_setsCachedTaskForImageView() {
    XCTAssertEqual(sut.cachedTaskForImageView, [:])
  }
  
  func test_init_setsResponseQueue() {
    XCTAssertEqual(sut.responseQueue, nil)
  }
  
  func test_init_setsSession() {
    XCTAssertEqual(sut.session, mockSession)
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
  
  func test_downloadImage_createsExpectedDataTask() {
    // when
    whenDownloadImage()
            
    // then
    XCTAssertEqual(receivedDataTask.url, url)
  }
  
  func test_downloadImage_callsResumeOnDataTask() {
    // when
    whenDownloadImage()

    // then
    XCTAssertTrue(receivedDataTask.calledResume)
  }
  
  func test_downloadImage_givenImage_callsCompletionWithImage() {
    // given
    givenExpectedImage()

    // when
    whenDownloadImage(image: expectedImage)

    // then
    XCTAssertEqual(expectedImage.pngData(), receivedImage.pngData())
  }
  
  func test_downloadImage_givenError_callsCompletionWithError() {
    // given
    givenExpectedError()
    
    // when
    whenDownloadImage(error: expectedError)
    
    // then
    XCTAssertEqual(receivedError as NSError, expectedError)
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
    XCTAssertNil(receivedDataTask)
  }
  
  func test_downloadImage_givenCachedImage_callsCompletionWithImage() {
    // given
    givenExpectedImage()
    
    // when
    whenDownloadImage(image: expectedImage)
    receivedImage = nil
    
    whenDownloadImage(image: expectedImage)
    
    // then
    XCTAssertEqual(receivedImage.pngData(),
                   expectedImage.pngData())
  }
  
  func test_setImageOnImageView_cancelsExistingDataTask() {
    // given
    let dataTask = MockURLSessionDataTask(completionHandler: { _, _, _ in },
                                          url: url,
                                          queue: nil)
    sut.cachedTaskForImageView[imageView] = dataTask
    
    // when
    sut.setImage(on: imageView, fromURL: url, withPlaceholder: nil)

    // then
    XCTAssertTrue(dataTask.calledCancel)
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
  
  func test_setImageOnImageView_cachesDownloadTask() {
    // when
    sut.setImage(on: imageView,
                 fromURL: url,
                 withPlaceholder: nil)
    
    // then
    receivedDataTask = sut.cachedTaskForImageView[imageView]
      as? MockURLSessionDataTask
    XCTAssertEqual(receivedDataTask?.url, url)
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
    receivedDataTask = sut.cachedTaskForImageView[imageView]
      as? MockURLSessionDataTask
    receivedDataTask.completionHandler(nil, nil, expectedError)
    
    // then
    XCTAssertEqual(imageView.image?.pngData(),
                   expectedImage.pngData())
  }
}
