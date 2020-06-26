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

class ListingsViewControllerTests: XCTestCase {
  
  // MARK: - Instance Properties
  var sut: ListingsViewController!
  var partialMock: PartialMockListingsViewController {
    return sut as! PartialMockListingsViewController
  }
  
  // MARK: - Test Lifecycle
  override func setUp() {
    super.setUp()
    sut = ListingsViewController.instanceFromStoryboard()
    sut.loadViewIfNeeded()
  }
  
  override func tearDown() {
    sut = nil
    super.tearDown()
  }
  
  // MARK: - Given
  func givenPartialMock() {
    sut = PartialMockListingsViewController()
    sut.loadViewIfNeeded()
  }
  
  func givenViewModels(count: Int = 3) {
    guard count > 0 else {
      sut.viewModels = []
      return
    }
    sut.viewModels = givenDogs(count: count).map { DogViewModel(dog: $0) }
  }
  
  func givenMockViewModels(count: Int = 3) {
    guard count > 0 else {
      sut.viewModels = []
      return
    }
    sut.viewModels = givenDogs(count: count).map { MockDogViewModel(dog: $0) }
  }
  
  func givenDogs(count: Int = 3) -> [Dog] {
    return (1 ... count).map { i in
      let dog = Dog(
        id: "id_\(i)",
        sellerID: "sellderID_\(i)",
        about: "about_\(i)",
        birthday: Date(timeIntervalSinceNow: -1 * Double(i).years),
        breed: "breed_\(i)",
        breederRating: Double(i % 5),
        cost: Decimal(i * 100),
        created: Date(timeIntervalSinceNow: -1 * Double(i).hours),
        imageURL: URL(string: "http://example.com/\(i)")!,
        name: "name_\(i)")
      return dog
    }
  }
  
  // MARK: - When
  func whenDequeueTableViewCells() -> [UITableViewCell] {
    return (0 ..< sut.viewModels.count).map { i in
      let indexPath = IndexPath(row: i, section: 0)
      return sut.tableView(sut.tableView, cellForRowAt: indexPath)
    }
  }
  
  // MARK: - Outlets - Tests
  func test_tableView_onSet_registersErrorTableViewCell() {
    // when
    let cell = sut.tableView.dequeueReusableCell(
      withIdentifier: ErrorTableViewCell.identifier)
    
    // then
    XCTAssertTrue(cell is ErrorTableViewCell)
  }
  
  // MARK: - Instance Properties - Tests
  func test_viewModels_setToEmptyArray() {
    XCTAssertEqual(sut.viewModels.count, 0)
  }
  
  // MARK: - View Life Cycle - Tests
  func test_viewDidLoad_setsRefreshControlAttributedTitle() throws {
    // when
    sut.viewDidLoad()
    
    // then
    let refreshControl = try XCTUnwrap(sut.tableView.refreshControl)
    XCTAssertEqual(refreshControl.attributedTitle, NSAttributedString(string: "Loading..."))
  }
  
  func test_viewDidLoad_setsRefreshControlTarget() throws {
    // when
    sut.viewDidLoad()
    
    // then
    let refreshControl = try XCTUnwrap(sut.tableView.refreshControl)
    
    XCTAssertEqual(refreshControl.allTargets.count, 1)
    let target = try XCTUnwrap(refreshControl.allTargets.first as? ListingsViewController)
    XCTAssertTrue(sut === target)
  }
  
  func test_viewDidLoad_setsRefreshControlAction() throws {
    // when
    sut.viewDidLoad()
    
    // then
    let refreshControl = try XCTUnwrap(sut.tableView.refreshControl)
    let target = try XCTUnwrap(refreshControl.allTargets.first as? ListingsViewController)
    let actions = refreshControl.actions(forTarget: target, forControlEvent: .valueChanged)
    let selector = try XCTUnwrap(actions?.first)
    XCTAssertEqual(actions?.count, 1)
    XCTAssertEqual(Selector(selector), #selector(ListingsViewController.refreshData))
  }
  
  func test_viewWillAppear_calls_refreshData() {
    // given
    givenPartialMock()
    let expectation = self.expectation(description: "Expected refreshData to be called")
    partialMock.onRefreshData = {
      expectation.fulfill()
    }
    
    // when
    sut.viewWillAppear(true)
    
    // then
    waitForExpectations(timeout: 0.0)
  }
  
  // MARK: - UITableViewDataSource Tests
  func test_tableView_numberOfRowsInSection_givenIsRefreshing_returns0() {
    // given
    let expected = 0
    sut.tableView.refreshControl!.beginRefreshing()
    
    // when
    let actual = sut.tableView(sut.tableView, numberOfRowsInSection: 0)
    
    // then
    XCTAssertEqual(actual, expected)
  }

  func test_tableView_numberOfRowsInSection_givenHasViewModels_returnsViewModelsCount() {
    // given
    let expected = 3
    givenViewModels(count: expected)
    
    // when
    let actual = sut.tableView(sut.tableView, numberOfRowsInSection: 0)
    
    // then
    XCTAssertEqual(actual, expected)
  }

  func test_tableView_numberOfRowsInSection_givenNoViewModels_returns1() {
    // given
    let expected = 1
    
    // when
    let actual = sut.tableView(sut.tableView, numberOfRowsInSection: 0)
    
    // then
    XCTAssertEqual(actual, expected)
  }
  
  func test_tableViewCellForRowAt_givenNoViewModelsSet_returns_ErrorTableViewCell() {
    // given
    givenViewModels(count: 0)
    
    // when
    let indexPath = IndexPath(row: 0, section: 0)
    let cell = sut.tableView(sut.tableView, cellForRowAt: indexPath)
    
    // then
    XCTAssertTrue(cell is ErrorTableViewCell)
  }
  
  func test_tableViewCellForRowAt_givenViewModelsSet_returnsListingTableViewCells() {
    // given
    givenViewModels()
    
    // when
    let cells = whenDequeueTableViewCells()
    
    // then
    for cell in cells {
      XCTAssertTrue(cell is ListingTableViewCell)
    }
  }
  
  func test_tableViewCellForRowAt_givenViewModelsSet_configuresTableViewCells() throws {
    // given
    givenMockViewModels()
    
    // when
    let cells = try XCTUnwrap(whenDequeueTableViewCells() as? [ListingTableViewCell])
    
    // then
    for i in 0 ..< sut.viewModels.count {
      let cell = cells[i]
      let viewModel = sut.viewModels[i] as! MockDogViewModel
      XCTAssertTrue(viewModel.configuredCell === cell) // pointer equality
    }
  }
}

// MARK: - Mocks
extension ListingsViewControllerTests {
  
  class MockDogViewModel: DogViewModel {
    var configuredCell: ListingTableViewCell?
    override func configure(_ cell: ListingTableViewCell) {
      self.configuredCell = cell
    }
  }
  
  class PartialMockListingsViewController: ListingsViewController {
    
    override func loadView() {
      super.loadView()
      tableView = UITableView()
    }
    
    var onRefreshData: (()->Void)? = nil
    override func refreshData() {
      guard let onRefreshData = onRefreshData else {
        super.refreshData()
        return
      }
      onRefreshData()
    }
  }
}
