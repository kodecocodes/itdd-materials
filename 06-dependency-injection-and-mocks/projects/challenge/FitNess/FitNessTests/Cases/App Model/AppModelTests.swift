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

import XCTest
@testable import FitNess

class AppModelTests: XCTestCase {

  var sut: AppModel!
  var mockPedometer: MockPedometer!

  override func setUp() {
    super.setUp()
    mockPedometer = MockPedometer()
    sut = AppModel(pedometer: mockPedometer)
  }

  override func tearDown() {
    sut.stateChangedCallback = nil
    mockPedometer = nil
    sut = nil
    AlertCenter.instance.clearAlerts()
    super.tearDown()
  }

  // MARK: - Given
  func givenGoalSet() {
    sut.dataModel.goal = 1000
  }

  func givenInProgress() {
    givenGoalSet()
    try! sut.start()
  }

  func givenPaused() {
    givenInProgress()
    sut.pause()
  }

  func givenCompleteReady() {
    sut.dataModel.setToComplete()
  }

  func givenCaughtReady() {
    sut.dataModel.setToCaught()
  }

  // MARK: - Lifecycle
  func testAppModel_whenInitialized_isInNotStartedState() {
    let initialState = sut.appState
    XCTAssertEqual(initialState, AppState.notStarted)
  }

  // MARK: - Start
  func testAppModel_whenStarted_isInInProgressState() {
    // given
    givenGoalSet()
    
    // when started
    try? sut.start()

    // then it is in inProgress
    let newState = sut.appState
    XCTAssertEqual(newState, AppState.inProgress)
  }

  func testModelWithNoGoal_whenStarted_throwsError() {
    XCTAssertThrowsError(try sut.start())
  }

  func testStart_withGoalSet_doesNotThrow() {
    // given
    givenGoalSet()

    // then
    XCTAssertNoThrow(try sut.start())
  }

  // MARK: - Pause
  func testAppModel_whenPaused_isInPausedState() {
    // given
    givenInProgress()

    // when
    sut.pause()

    // then
    XCTAssertEqual(sut.appState, .paused)
  }

  // MARK: - Terminal States
  func testModel_whenCompleted_isInCompletedState() {
    // given
    givenCompleteReady()

    // when
    try? sut.setCompleted()

    // then
    XCTAssertEqual(sut.appState, .completed)
  }

  func testModelNotCompleteReady_whenCompleted_throwsError() {
    XCTAssertThrowsError(try sut.setCompleted())
  }

  func testModelCompleteReady_whenCompleted_doesNotThrow() {
    // given
    givenCompleteReady()

    // then
    XCTAssertNoThrow(try sut.setCompleted())
  }

  func testModel_whenCaught_isInCaughtState() {
    // given
    givenCaughtReady()

    // when started
    try? sut.setCaught()

    // then
    XCTAssertEqual(sut.appState, .caught)
  }

  func testModelNotCaughtReady_whenCaught_throwsError() {
    XCTAssertThrowsError(try sut.setCaught())
  }

  func testModelCaughtReady_whenCaught_doesNotThrow() {
    // given
    givenCaughtReady()

    // then
    XCTAssertNoThrow(try sut.setCaught())
  }

  // MARK: - Restart
  func testAppModel_whenReset_isInNotStartedState() {
    // given
    givenInProgress()

    // when
    sut.restart()

    // then
    XCTAssertEqual(sut.appState, .notStarted)
  }

  func testAppModel_whenRestarted_restartsDataModel() {
    // given
    givenInProgress()

    // when
    sut.restart()

    // then
    XCTAssertNil(sut.dataModel.goal)
  }

  // MARK: - State Changes
  func testAppModel_whenStateChanges_executesCallback() {
    // given
    givenInProgress()
    var observedState = AppState.notStarted

    let expected = expectation(description: "callback happened")
    sut.stateChangedCallback = { model in
      observedState = model.appState
      expected.fulfill()
    }

    // when
    sut.pause()

    // then
    wait(for: [expected], timeout: 1)
    XCTAssertEqual(observedState, .paused)
  }
  
  // MARK: - Pedometer
  func testAppModel_whenStarted_startsPedometer() {
    //given
    givenGoalSet()

    // when
    try! sut.start()

    // then
    XCTAssertTrue(mockPedometer.started)
  }

  func testPedometerNotAvailable_whenStarted_doesNotStart() {
    // given
    givenGoalSet()
    mockPedometer.pedometerAvailable = false

    // when
    try! sut.start()

    // then
    XCTAssertEqual(sut.appState, .notStarted)
  }

  func testPedometerNotAvailable_whenStarted_generatesAlert() {
    // given
    givenGoalSet()
    mockPedometer.pedometerAvailable = false
    let exp = expectation(forNotification: AlertNotification.name, object: nil, handler: alertHandler(.noPedometer))

    // when
    try! sut.start()

    // then
    wait(for: [exp], timeout: 1)
  }

  func testPedometerNotAuthorized_whenStarted_doesNotStart() {
    // given
    givenGoalSet()
    mockPedometer.permissionDeclined = true

    // when
    try! sut.start()

    // then
    XCTAssertEqual(sut.appState, .notStarted)
  }

  func testPedometerNotAuthorized_whenStarted_generatesAlert() {
    // given
    givenGoalSet()
    mockPedometer.permissionDeclined = true
    let exp = expectation(forNotification: AlertNotification.name, object: nil, handler: alertHandler(.notAuthorized))

    // when
    try! sut.start()

    // then
    wait(for: [exp], timeout: 1)
  }

  func testAppModel_whenDeniedAuthAfterStart_generatesAlert() {
    // given
    givenGoalSet()
    mockPedometer.error = MockPedometer.notAuthorizedError
    let exp = expectation(forNotification: AlertNotification.name,
                          object: nil,
                          handler: alertHandler(.notAuthorized))

    // when
    try! sut.start()

    // then
    wait(for: [exp], timeout: 1)
  }
  
  func testModel_whenPedometerUpdates_errorGeneratesAlert() {
    // given
    givenInProgress()

    mockPedometer.error = MockPedometer.dataError
    let exp = expectation(forNotification: AlertNotification.name, object: nil, handler: alertHandler(.dataAlert))


    // when
    mockPedometer.sendData(nil)

    // then
    wait(for: [exp], timeout: 1)
  }

  func testModel_whenPedometerUpdates_updatesDataModel() {
    // given
    givenInProgress()
    let data = MockData(steps: 100, distanceTravelled: 10)

    // when
    mockPedometer.sendData(data)

    // then
    XCTAssertEqual(sut.dataModel.steps, 100)
    XCTAssertEqual(sut.dataModel.distance, 10)
  }

  func testModel_whenPaused_pausesPedometer() {
    // given
    givenInProgress()

    // when
    sut.pause()

    // then
    XCTAssertEqual(mockPedometer.pauseCalled, 1)
  }

  // MARK: - Nessie

  func testNessie_whenAppModelPaused_isSleeping() {
    // given
    givenInProgress()

    // when
    sut.pause()

    // then
    XCTAssertTrue(sut.dataModel.nessie.isSleeping)
  }

  func testNessie_whenAppModelRestarted_isNotSleeping() {
    // given
    givenPaused()

    // when
    try! sut.start()

    // then
    XCTAssertFalse(sut.dataModel.nessie.isSleeping)
  }

  func testAppModel_whenCaught_stopsNessie() {
    // given
    givenInProgress()
    givenCaughtReady()

    // when
    sut.setToCaught()

    // then
    XCTAssertTrue(sut.dataModel.nessie.isSleeping)
  }

  func testAppModel_whenComplete_stopsNessie() {
    // given
    givenInProgress()
    givenCompleteReady()

    // when
    sut.setToComplete()

    // then
    XCTAssertTrue(sut.dataModel.nessie.isSleeping)
  }

}
