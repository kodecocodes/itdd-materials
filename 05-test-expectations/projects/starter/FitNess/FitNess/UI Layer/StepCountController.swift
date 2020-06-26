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

import UIKit

extension AppState {
  var nextStateButtonLabel: String {
    switch self {
    case .notStarted:
      return "Start"
    case .inProgress:
      return "Pause"
    case .paused:
      return "Resume"
    case .caught:
      return "Try Again"
    case .completed:
      return "Start Over"
    }
  }
}

class StepCountController: UIViewController {
  @IBOutlet weak var stepCountLabel: UILabel!
  @IBOutlet var startButton: UIButton!
  @IBOutlet weak var chaseView: ChaseView!

  override func viewDidLoad() {
    super.viewDidLoad()

    updateUI()
  }

  func updateUI() {
    updateButton()
    updateChaseView()
  }

  private func updateButton() {
    let title = AppModel.instance.appState.nextStateButtonLabel
    startButton.setTitle(title, for: .normal)
  }

  // MARK: - UI Actions
  
  @IBAction func startStopPause(_ sender: Any?) {
    switch AppModel.instance.appState {
    case .notStarted:
      start()
    case .inProgress:
      AppModel.instance.pause()
    case .paused:
      start() 
    case .completed, .caught:
      AppModel.instance.restart()
    }
    
    updateUI()
  }

  private func start() {
    do {
      try AppModel.instance.start()
    } catch {
      showNeedGoalAlert()
    }
  }
  
  @IBAction func showSettings(_ sender: Any) {
    getGoalFromUser()
  }
}

// MARK: - Goal

extension StepCountController {
  func updateGoal(newGoal: Int) {
    AppModel.instance.dataModel.goal = newGoal
  }

  private func showNeedGoalAlert() {
    let alertController = UIAlertController(title: "Set a goal to start", message: nil, preferredStyle: .alert)
    let cancel = UIAlertAction(title: "Cancel", style: .cancel)
    let enterGoal = UIAlertAction(title: "Enter Goal", style: .default) { [weak self] action in
      self?.getGoalFromUser()
    }

    alertController.addAction(cancel)
    alertController.addAction(enterGoal)
    present(alertController, animated: true)
  }

  private func getGoalFromUser() {
    let alertController = UIAlertController(title: "What is your step goal?", message: nil, preferredStyle: .alert)
    alertController.addTextField { textField in
      textField.placeholder = "1000"
      textField.keyboardType = .numberPad
    }
    let action = UIAlertAction(title: "Done", style: .default) { [weak self] action in
      guard let textField = alertController.textFields?.first else { return }
      if let numberString = textField.text, let goal = Int(numberString) {
        self?.updateGoal(newGoal: goal)
      } else {
        self?.updateGoal(newGoal: 0)
      }
    }
    alertController.addAction(action)
    present(alertController, animated: true)
  }
}

// MARK: - Chase View
extension StepCountController {
  private func updateChaseView() {
    chaseView.state = AppModel.instance.appState
  }
}
