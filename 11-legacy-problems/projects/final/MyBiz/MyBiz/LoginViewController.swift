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

class LoginViewController: UIViewController {
  @IBOutlet weak var emailField: UITextField!
  @IBOutlet weak var passwordField: UITextField!
  @IBOutlet weak var signInButton: UIButton!

  var api: API { return (UIApplication.shared.delegate as! AppDelegate).api }
  let skin: Skin = .login

  override func viewDidLoad() {
    super.viewDidLoad()

    api.delegate = self
    Styler.shared.style(background: view, buttons: [signInButton], with: skin)
  }

  @IBAction func signIn(_ sender: Any) {
    guard let username = emailField.text,
      let password = passwordField.text else { return }
    guard username.isEmail && password.isValidPassword else {
      // a little client-side validation ;)
      showAlert(title: "Invalid Username or Password", subtitle: "Check the username or password")
      return
    }
    api.login(username: username, password: password)
  }
}

extension LoginViewController: APIDelegate {
  func eventsLoaded(events: [Event]) {}
  func eventsFailed(error: Error) {}
  func orgLoaded(org: [Employee]) {}
  func orgFailed(error: Error) {}
  func announcementsFailed(error: Error) {}
  func announcementsLoaded(announcements: [Announcement]) {}
  func productsLoaded(products: [Product]) {}
  func productsFailed(error: Error) {}
  func purchasesLoaded(purchases: [PurchaseOrder]) {}
  func purchasesFailed(error: Error) {}
  func userLoaded(user: UserInfo) {}
  func userFailed(error: Error) {}

  func loginFailed(error: Error) {
    showAlert(title: "Login Failed", subtitle: error.localizedDescription, type: .login, skin: .loginAlert)
  }

  func loginSucceeded(userId: String) {
    UIApplication.appDelegate.userId = userId
    if let tabController = storyboard?.instantiateViewController(withIdentifier: "tabController") {
      UIApplication.appDelegate.rootController = tabController
    }
  }
}
