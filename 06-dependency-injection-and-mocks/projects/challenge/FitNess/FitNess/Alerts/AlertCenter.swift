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

class AlertCenter {
  static var instance = AlertCenter()

  // MARK: - Alert Queue
  private var alertQueue: [Alert] = []

  var alertCount: Int {
    return alertQueue.count
  }

  var topAlert: Alert? {
    return alertQueue.first
  }

  var nextUp: Alert? {
    return alertQueue.count >= 2 ? alertQueue[1] : nil
  }

  // MARK: - Lifecycle
  init(center: NotificationCenter = .default) {
    self.notificationCenter = center
  }

  // MARK: - Notifications
  let notificationCenter: NotificationCenter

  func postAlert(alert: Alert) {
    guard !alertQueue.contains(alert) else { return }

    alertQueue.append(alert)
    let notification = Notification(name: AlertNotification.name,
                                    object: self,
                                    userInfo: [AlertNotification.Keys.alert: alert])
     notificationCenter.post(notification)
  }

  // MARK: - Alert Handling
  func clear(alert: Alert) {
    if let index = alertQueue.firstIndex(of: alert) {
      alertQueue.remove(at: index)
    }
  }

  func clearAlerts() {
    alertQueue.removeAll()
  }
}

// MARK: - Class Helpers
extension AlertCenter {

  class func listenForAlerts(_ callback: @escaping (AlertCenter) -> ()) {
    instance.notificationCenter
      .addObserver(forName: AlertNotification.name,
                   object: instance, queue: .main) { _ in
      callback(instance)
    }
  }
}

