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

  override func setUp() {
    super.setUp()
    sut = AppModel()
  }

  override func tearDown() {
    AlertCenter.instance.clearAlerts()
    sut.stateChangedCallback = nil
    sut = nil
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
}
