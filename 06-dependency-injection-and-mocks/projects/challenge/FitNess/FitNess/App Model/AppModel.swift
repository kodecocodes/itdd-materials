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

import Foundation
import CoreMotion

class AppModel {

  static let instance = AppModel()
  static var pedometerFactory: (() -> Pedometer) = {
    #if targetEnvironment(simulator)
    return SimulatorPedometer()
    #else
    return CMPedometer()
    #endif
  }

  let dataModel = DataModel()

  var pedometer: Pedometer

  private(set) var appState: AppState = .notStarted {
    didSet {
      stateChangedCallback?(self)
    }
  }

  var stateChangedCallback: ((AppModel) -> ())?

  init(pedometer: Pedometer = pedometerFactory()) {
    self.pedometer = pedometer
  }
  
  // MARK: - App Lifecycle
  func start() throws {
    guard dataModel.goal != nil else {
      throw AppError.goalNotSet
    }
    guard pedometer.pedometerAvailable else {
      AlertCenter.instance.postAlert(alert: .noPedometer)
      return
    }
    guard !pedometer.permissionDeclined else {
      AlertCenter.instance.postAlert(alert: .notAuthorized)
      return
    }
    appState = .inProgress
    startPedometer()
    dataModel.nessie.startSwimming()
  }

  func pause() {
    appState = .paused
    dataModel.nessie.stopSwimming()
    pedometer.pause()
  }

  func restart() {
    appState = .notStarted
    dataModel.nessie.stopSwimming()
    dataModel.restart()
  }

  func setCaught() throws {
    guard dataModel.caught else {
      throw AppError.invalidState
    }

    dataModel.nessie.stopSwimming()
    pedometer.pause()

    appState = .caught
  }

  func setCompleted() throws {
    guard dataModel.goalReached else {
      throw AppError.invalidState
    }

    dataModel.nessie.stopSwimming()
    appState = .completed
  }
}

// MARK: - Pedometer
extension AppModel {
  func startPedometer() {
    pedometer.start(dataUpdates: handleData,
                    eventUpdates: handleEvents)
  }

  func handleData(data: PedometerData?, error: Error?) {
    if let data = data {
      dataModel.steps += data.steps
      dataModel.distance += data.distanceTravelled
    } else if let error = error {
      print("error: \(error.localizedDescription)")
      AlertCenter.instance.postAlert(alert: .dataAlert)
    }
  }

  func handleEvents(error: Error?) {
    if let error = error {
      let alert = error.is(CMErrorMotionActivityNotAuthorized)
        ? .notAuthorized : Alert(error.localizedDescription)
      AlertCenter.instance.postAlert(alert: alert)
    }
  }
}
