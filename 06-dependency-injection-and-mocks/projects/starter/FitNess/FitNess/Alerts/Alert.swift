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

// note: no AlertTests because alert is a pure data object
class Alert {

  enum Severity { case good, bad }

  let text: String
  let severity: Severity
  var cleared: Bool = false


  init(_ text: String, severity: Severity = .bad) {
    self.text = text
    self.severity = severity
  }
}

extension Alert {
  static var caughtByNessie = Alert("Caught By Nessie!")
  static var reachedGoal = Alert("You reached your goal!", severity: .good)
  static var noPedometer = Alert("Pedometer is not available. You won't be able to use this app.")
  static var notAuthorized = Alert("Motion recording has been blocked. Fix in Settings")
  static var milestone25Percent = Alert("You are 25% to goal. Keep going!", severity: .good)
  static var milestone50Percent = Alert("Woohoo! You're halfway there!", severity: .good)
  static var milestone75Percent = Alert("Almost there, you can do it!", severity: .good)
  static var goalComplete = Alert("Amazing, you did it! Have some 🥧.", severity: .good)
  static var nessie50Percent = Alert("Nessie catching up halfway 🦕.")
  static var nessie90Percent = Alert("Nessie almost has you 🦕!")
}

extension Alert: Equatable {
  static func == (lhs: Alert, rhs: Alert) -> Bool {
    return lhs.text == rhs.text
  }
}

extension Alert: CustomStringConvertible {
  var description: String {
    return "Alert: '\(text)'"
  }
}
