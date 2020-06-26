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

class AlertViewController: UIViewController {

  struct ViewValues {
    let alertText: String?
    let justOneAlert: Bool
    let topAlertInset: CGFloat
    let topColor: UIColor?
    let bottomColor: UIColor?
  }

  @IBOutlet weak var mainAlertView: UIView!
  @IBOutlet weak var secondaryAlertView: UIView!
  @IBOutlet weak var alertLabel: UILabel!

  @IBOutlet weak var mainBottom: NSLayoutConstraint!
  @IBOutlet weak var mainTrailing: NSLayoutConstraint!

  override func viewDidLoad() {
    super.viewDidLoad()

    mainAlertView.layer.borderWidth = 1
    secondaryAlertView.layer.borderWidth = 1

    AlertCenter.listenForAlerts { center in
      self.updateForAlert()
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    updateForAlert()
  }

  func calculateViewValues() -> ViewValues {
    let justOneAlert = AlertCenter.instance.alertCount == 1
    let mainInset: CGFloat = justOneAlert ? 0 : 8
    let topColor = AlertCenter.instance.topAlert?.severity.color
    let alertText = AlertCenter.instance.topAlert?.text
    let bottomColor = AlertCenter.instance.nextUp?.severity.color

    return ViewValues(alertText: alertText, justOneAlert: justOneAlert, topAlertInset: mainInset, topColor: topColor, bottomColor: bottomColor)
  }

  func updateForAlert() {
    guard AlertCenter.instance.alertCount > 0 else {
      (parent as? RootViewController)?.hideShowAlert()
      return
    }
    let values = calculateViewValues()
    alertLabel.text = values.alertText
    mainAlertView.backgroundColor = values.topColor
    mainBottom.constant = values.topAlertInset
    mainTrailing.constant = values.topAlertInset

    secondaryAlertView.isHidden = values.justOneAlert
    secondaryAlertView.backgroundColor = values.bottomColor
  }

  @IBAction func closeAlert(_ sender: Any) {
    if let top = AlertCenter.instance.topAlert {
      AlertCenter.instance.clear(alert: top)
      updateForAlert()
    }
  }
}

extension Alert.Severity {
  var color: UIColor {
    switch self {
    case .bad:
      return UIColor(named: "BadAlertColor")!
    case .good:
      return UIColor(named: "GoodAlertColor")!
    }
  }
}
