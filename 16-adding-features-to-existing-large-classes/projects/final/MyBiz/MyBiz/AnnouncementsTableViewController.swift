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
import UIHelpers

class AnnouncementsTableViewController: UITableViewController {
  var api: API { return (UIApplication.shared.delegate as! AppDelegate).api }
  var analytics: AnalyticsAPI?
  var announcements: [Announcement] = []

  let skin: Skin = .announcements

  override func viewDidLoad() {
    super.viewDidLoad()
    Styler.shared.style(background: view, skin: skin)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    api.delegate = self
    api.getAnnouncements()

    let screenReport = Report(
      name: AnalyticsEvent.announcementsShown.rawValue,
      recordedDate: Date(),
      type: AnalyticsType.screenView.rawValue,
      duration: nil,
      device: UIDevice.current.model,
      os: UIDevice.current.systemVersion,
      appVersion: Bundle.main
        .object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String)
    analytics?.sendReport(report: screenReport)
  }

  // MARK: - Table view data source
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return announcements.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    let announcement = announcements[indexPath.row]
    cell.textLabel?.text = announcement.message
    cell.backgroundColor = .clear
    return cell
  }

  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    Styler.shared.style(cell: cell, with: skin)
  }
}

// MARK: - APIDelegate

extension AnnouncementsTableViewController: APIDelegate {
  func productsLoaded(products: [Product]) {}
  func productsFailed(error: Error) {}
  func purchasesLoaded(purchases: [PurchaseOrder]) {}
  func purchasesFailed(error: Error) {}
  func eventsLoaded(events: [Event]) {}
  func eventsFailed(error: Error) {}
  func orgLoaded(org: [Employee]) {}
  func orgFailed(error: Error) {}
  func userLoaded(user: UserInfo) {}
  func userFailed(error: Error) {}

  func announcementsFailed(error: Error) {
    showAlert(title: "Could not load announcements", subtitle: error.localizedDescription)
  }

  func announcementsLoaded(announcements: [Announcement]) {
    self.announcements = announcements
    tableView.reloadData()
  }
}

extension AnnouncementsTableViewController: ReportSending {}
