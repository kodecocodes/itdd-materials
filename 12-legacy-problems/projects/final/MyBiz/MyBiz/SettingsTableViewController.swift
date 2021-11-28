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
/// 
import UIKit

class SettingsTableViewController: UITableViewController {
  @IBOutlet weak var dayOfWeekSwitch: UISegmentedControl!

  var api: API { return (UIApplication.shared.delegate as! AppDelegate).api }
  var logoutTitle: String?

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    api.delegate = self
    if let userID = UIApplication.appDelegate.userId {
      api.getUserInfo(userID: userID)
    }

    dayOfWeekSwitch.selectedSegmentIndex = AppDelegate.configuration.firstDayOfWeek == .sunday ? 0 : 1
  }

  @IBAction func selectDayOfWeek(_ sender: UISegmentedControl) {
    var firstDay = DaysOfWeek.sunday
    if sender.selectedSegmentIndex == 1 {
      firstDay = .monday
    }
    UserDefaults.standard.set(firstDay.rawValue, forKey: "firstDayOfWeek")
    UserDefaults.standard.synchronize()
  }

  // MARK: - Table view data source
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch (indexPath.section, indexPath.row) {
    case (0, 0):
      logout()
    default:
      break
    }
  }

  private func logout() {
    api.logout()
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section == 0 {
      return logoutTitle
    }
    return nil
  }
}

// MARK: - APIDelegate

extension SettingsTableViewController: APIDelegate {
  func productsLoaded(products: [Product]) {}
  func productsFailed(error: Error) {}
  func purchasesLoaded(purchases: [PurchaseOrder]) {}
  func purchasesFailed(error: Error) {}
  func eventsLoaded(events: [Event]) {}
  func eventsFailed(error: Error) {}
  func orgLoaded(org: [Employee]) {}
  func orgFailed(error: Error) {}
  func loginFailed(error: Error) {}
  func loginSucceeded(userId: String) {}
  func announcementsFailed(error: Error) {}
  func announcementsLoaded(announcements: [Announcement]) {}

  func userLoaded(user: UserInfo) {
    logoutTitle = "Logged in as: \(user.username)"
    tableView.reloadData()
  }

  func userFailed(error: Error) {
    Logger.logError(error)
  }
}
