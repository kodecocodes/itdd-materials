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

class AddToOrderTableViewController: UITableViewController {
  var api: API { return (UIApplication.shared.delegate as! AppDelegate).api }
  let skin: Skin = .purchaseOrder

  var products: [Product] = []
  var productOrder: [Product: Double] = [:]
  var doneCallback: (([Product: Double]) -> Void)?

  override func viewDidLoad() {
    super.viewDidLoad()
    Styler.shared.style(background: view, with: skin)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    doneCallback?(productOrder)
  }

  // MARK: - Table view data source

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return products.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! AddProductTableViewCell
    let product = products[indexPath.row]
    let priceFormatter = NumberFormatter()
    priceFormatter.numberStyle = .currency
    cell.nameLabel.text = product.productName

    let count = productOrder[product] ?? 0
    let totalPrice = Double(max(count, 1)) * product.unitPrice
    cell.priceLabel.text = priceFormatter.string(for: totalPrice)

    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .none
    cell.countLabel.text = numberFormatter.string(for: count)!
    cell.countStepper.tag = indexPath.row
    cell.countStepper.value = Double(count)
    cell.countStepper.addTarget(
      self,
      action: #selector(AddToOrderTableViewController.updateCount(_:)),
      for: .valueChanged)

    return cell
  }

  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    Styler.shared.style(cell: cell, with: skin)
  }

  @objc func updateCount(_ sender: UIStepper) {
    let index = sender.tag
    let product = products[index]
    productOrder[product] = sender.value
    tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
  }
}
