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
import UIHelpers

class OrgTableViewController: UITableViewController {
  var api: API { return (UIApplication.shared.delegate as! AppDelegate).api }
  var analytics: AnalyticsAPI?

  var topEmployee = ""
  var org: [Employee] = []
  var rows: [(String, Int)] = []
  var expandedRows = Set<String>()
  let skin: Skin = .orgChart

  override func viewDidLoad() {
    super.viewDidLoad()
    Styler.shared.style(background: view, skin: skin)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    api.delegate = self
    api.getOrgChart()
    let report = Report.make(event: .orgChartShown, type: .screenView)
    analytics?.sendReport(report: report)
  }

  // MARK: - Table view data source
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return rows.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! OrgTableViewCell

    let (employee, level) = getEmploye(at: indexPath.row)
    var components = PersonNameComponents()
    components.givenName = employee.givenName
    components.familyName = employee.familyName
    let formatter = PersonNameComponentsFormatter()
    cell.nameLabel.text = formatter.string(from: components)
    cell.level = level
    let managerState = expandedRows.contains(employee.id) ? OrgTableViewCell.DisclosureState.open : .closed
    cell.state = employee.directReports.isEmpty ? .none : managerState

    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let (employee, level) = getEmploye(at: indexPath.row)
    guard !employee.directReports.isEmpty else { return }
    let cell = tableView.cellForRow(at: indexPath) as! OrgTableViewCell
    if expandedRows.contains(employee.id) {
      //collapse
      Logger.logDebug("collapsing \(employee.id)...")
      rows.removeSubrange((indexPath.row + 1)...(indexPath.row + employee.directReports.count))
      let indexPaths = (1...employee.directReports.count).map { IndexPath(item: indexPath.item + $0, section: 0) }
      tableView.deleteRows(at: indexPaths, with: .automatic)
      expandedRows.remove(employee.id)
      cell.state = .closed
    } else {
      //expand
      Logger.logDebug("expanding \(employee.id)...")
      let newPeople = employee.directReports.map { ($0, level + 1) }
      rows.insert(contentsOf: newPeople, at: indexPath.row + 1)
      let indexPaths = (1...employee.directReports.count).map { IndexPath(item: indexPath.item + $0, section: 0) }
      tableView.insertRows(at: indexPaths, with: .automatic)
      expandedRows.insert(employee.id)
      cell.state = .open
    }
  }

  func getEmploye(at row: Int) -> (Employee, Int) {
    let (id, level) = rows[row]
    let employee = org.first { $0.id == id }!
    return (employee, level)
  }

  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    Styler.shared.style(cell: cell, with: skin)
  }
}

// MARK: - APIDelegate

extension OrgTableViewController: APIDelegate {
  func eventsLoaded(events: [Event]) {}
  func eventsFailed(error: Error) {}
  func announcementsFailed(error: Error) {}
  func announcementsLoaded(announcements: [Announcement]) {}
  func productsLoaded(products: [Product]) {}
  func productsFailed(error: Error) {}
  func purchasesLoaded(purchases: [PurchaseOrder]) {}
  func purchasesFailed(error: Error) {}
  func userLoaded(user: UserInfo) {}
  func userFailed(error: Error) {}

  func orgLoaded(org: [Employee]) {
    if let ceo = org.first {
      topEmployee = ceo.id
      rows = [(topEmployee, 0)] + ceo.directReports.map { ($0, 1) }
      expandedRows.insert(topEmployee)
      self.org = org
    } else {
      rows = []
    }
    tableView.reloadData()
  }

  func orgFailed(error: Error) {
    showAlert(title: "Could not load org chart", subtitle: error.localizedDescription)
  }
}

extension OrgTableViewController: ReportSending {}
