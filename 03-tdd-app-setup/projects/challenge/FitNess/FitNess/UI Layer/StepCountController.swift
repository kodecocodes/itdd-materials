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
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
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

<<<<<<< HEAD:03-tdd-app-setup/projects/starter/FitNess/FitNess/UI Layer/StepCountView.swift
struct StepCountView: View {
  @State var stepCountLabel = "Press Start"
  @State var steps = "Steps"
<<<<<<< HEAD
<<<<<<< HEAD:03-tdd-app-setup/projects/starter/FitNess/FitNess/UI Layer/StepCountView.swift
=======

  @ObservedObject var appModel = AppModel.instance
>>>>>>> d968637... reset for not swiftui:03-tdd-app-setup/projects/challenge/FitNess/FitNess/UI Layer/StepCountView.swift
=======
>>>>>>> d968637... reset for not swiftui

  var body: some View {
    VStack {
      Spacer()
        .frame(height: 120)
      Text(stepCountLabel)
        .font(Font.system(size: 37))
      Text(steps)
        .font(Font.system(size: 17))
      Spacer()
      ChaseView()
        .frame(height: 128)
      Spacer()
        .frame(height: 77)
<<<<<<< HEAD
<<<<<<< HEAD:03-tdd-app-setup/projects/starter/FitNess/FitNess/UI Layer/StepCountView.swift
      Button("Start", action: startStopPause)
=======
      Button(buttonTitle(), action: startStopPause)
>>>>>>> d968637... reset for not swiftui:03-tdd-app-setup/projects/challenge/FitNess/FitNess/UI Layer/StepCountView.swift
=======
      Button("Start", action: startStopPause)
>>>>>>> d968637... reset for not swiftui
      Spacer()
        .frame(height: 50)
=======
class StepCountController: UIViewController {
  @IBOutlet weak var stepCountLabel: UILabel!
  @IBOutlet var startButton: UIButton!
  @IBOutlet weak var chaseView: ChaseView!

  init() {
    // this is a cheat to simplify chapter 3, a proper way of getting an instance will be handled in chapter 4
    super.init(nibName: nil, bundle: nil)
    startButton = UIButton()
>>>>>>> 68f17d3... Revert "reset for not swiftui":03-tdd-app-setup/projects/challenge/FitNess/FitNess/UI Layer/StepCountController.swift
    }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

<<<<<<< HEAD:03-tdd-app-setup/projects/starter/FitNess/FitNess/UI Layer/StepCountView.swift
  func startStopPause() {
<<<<<<< HEAD
<<<<<<< HEAD:03-tdd-app-setup/projects/starter/FitNess/FitNess/UI Layer/StepCountView.swift
  }
}

=======
    appModel.start()
  }

  func buttonTitle() -> String {
    appModel.appState.nextStateButtonLabel
  }
}

>>>>>>> d968637... reset for not swiftui:03-tdd-app-setup/projects/challenge/FitNess/FitNess/UI Layer/StepCountView.swift
=======
=======
  override func viewDidLoad() {
    super.viewDidLoad()
    updateButton()
  }

  @IBAction func startStopPause(_ sender: Any?) {
    AppModel.instance.start()
    updateButton()
>>>>>>> 68f17d3... Revert "reset for not swiftui":03-tdd-app-setup/projects/challenge/FitNess/FitNess/UI Layer/StepCountController.swift
  }

  private func updateButton() {
    let title = AppModel.instance.appState.nextStateButtonLabel
    startButton.setTitle(title, for: .normal)
}
<<<<<<< HEAD

<<<<<<< HEAD:03-tdd-app-setup/projects/starter/FitNess/FitNess/UI Layer/StepCountView.swift
>>>>>>> d968637... reset for not swiftui
struct StepCountView_Previews: PreviewProvider {
  static var previews: some View {
    StepCountView()
=======
  @IBAction func startStopPause(_ sender: Any?) {
    AppModel.instance.start()
    
    updateButton()
>>>>>>> 68f17d3... Revert "reset for not swiftui":03-tdd-app-setup/projects/challenge/FitNess/FitNess/UI Layer/StepCountController.swift
  }
=======
>>>>>>> a782646... update challenge
}
