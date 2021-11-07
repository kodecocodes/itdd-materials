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

class PurchasesTableViewController: UITableViewController {
  var api: API { return (UIApplication.shared.delegate as! AppDelegate).api }

  var purchases: [PurchaseOrder] = []
  var products: [Product] = []

  let skin: Skin = .purchaseOrder

  override func viewDidLoad() {
    super.viewDidLoad()

    Styler.shared.style(background: view, skin: skin)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    api.delegate = self
    api.getProducts()
    api.getPurchases()
  }

  // MARK: - Table view data source
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return purchases.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PurchasesTableViewCell

    let item = purchases[indexPath.row]

    let dateFormatter = DateFormatter()
    dateFormatter.timeStyle = .none
    dateFormatter.dateStyle = .short

    let date = dateFormatter.string(from: item.purchaseDate!)
    let title = item.poNumber

    let cost: String
    if products.isEmpty {
      cost = "???"
    } else {
      let total = item.purchases.reduce(0) { _, purchase -> Double in
        if let product = products.first(where: { $0.productId == purchase.productId }) {
          return purchase.quantity * product.unitPrice
        }
        return 0
      }
      let numberFormatter = NumberFormatter()
      numberFormatter.numberStyle = .currency
      cost = numberFormatter.string(for: total)!
    }

    cell.dateLabel.text = date
    cell.titleLabel.text = title
    cell.costLabel.text = cost

    return cell
  }
}

// MARK: - APIDelegate

extension PurchasesTableViewController: APIDelegate {
  func eventsLoaded(events: [Event]) {}
  func eventsFailed(error: Error) {}
  func loginFailed(error: Error) {}
  func loginSucceeded(userId: String) {}
  func announcementsFailed(error: Error) {}
  func announcementsLoaded(announcements: [Announcement]) {}
  func orgFailed(error: Error) {}
  func orgLoaded(org: [Employee]) {}
  func userLoaded(user: UserInfo) {}
  func userFailed(error: Error) {}

  func productsLoaded(products: [Product]) {
    self.products = products
    tableView.reloadData()
  }

  func productsFailed(error: Error) {
    showAlert(title: "Could not load products", subtitle: error.localizedDescription)
  }

  func purchasesLoaded(purchases: [PurchaseOrder]) {
    self.purchases = purchases
    tableView.reloadData()
  }

  func purchasesFailed(error: Error) {
    showAlert(title: "Could not load purchase", subtitle: error.localizedDescription)
  }
}
