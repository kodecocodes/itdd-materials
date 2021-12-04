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

class CreatePurachaseOrderTableViewController: UITableViewController {
  struct POInProgress {
    var poNumber: String = "0000001"
    var comment: String?
    var dueDate: Date?
    var purchases: [PurchaseOrder.Purchase] = []

    var purchaseOrder: PurchaseOrder? {
      return PurchaseOrder(
        id: nil,
        poNumber: poNumber,
        comment: comment,
        purchaser: UUID(uuidString: UIApplication.appDelegate.userId!)!,
        purchaseDate: nil,
        dueDate: dueDate,
        purchases: purchases)
    }
  }

  enum POError: LocalizedError {
    case invalidPONumber
    case exceedsMax
    case noItems
    case invalidDate

    var errorDescription: String? {
      switch  self {
      case .invalidPONumber:
        return "Must have a valid PO Number."
      case .noItems:
        return "Must have at least one item to buy."
      case .exceedsMax:
        return "PO exceeds max allowable expense."
      case .invalidDate:
        return "PO must be due in the future."
      }
    }
  }

  struct RowInfo {
    enum RowType {
      case textInput, stringValue
    }
    enum SelectionType {
      case datePicker, none
    }
    let label: String
    let type: RowType
    let value: (() -> String)?
    let selection: SelectionType
  }

  @IBOutlet var productHeaderView: UIView!

  lazy var rows = [
    RowInfo(
      label: "PO Number",
      type: .textInput,
      value: { self.poInProgress.poNumber },
      selection: .none),
    RowInfo(
      label: "Purchase Date",
      type: .stringValue,
      value: {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: Date())
      },
      selection: .none),
    RowInfo(
      label: "Comment",
      type: .textInput,
      value: { self.poInProgress.comment ?? "" },
      selection: .none),
    RowInfo(
      label: "Due Date",
      type: .stringValue,
      value: { () -> String in
        guard let date = self.poInProgress.dueDate else { return "-" }
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: date)
      },
      selection: .datePicker),
    RowInfo(
      label: "Total",
      type: .stringValue,
      value: {
        let priceFormatter = NumberFormatter()
        priceFormatter.numberStyle = .currency
        return priceFormatter.string(for: self.totalAmount)!
      },
      selection: .none)
  ]

  var api: API { return (UIApplication.shared.delegate as! AppDelegate).api }
  var products: [Product] = []

  var poInProgress = POInProgress()
  let skin: Skin = .purchaseOrder

  var totalAmount: Double {
    return poInProgress.purchases.reduce(0) { res, purchase -> Double in
      let product = products.first { product -> Bool in
        product.productId == purchase.productId
      }
      return res + purchase.quantity * product!.unitPrice
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    poInProgress = POInProgress()
    Styler.shared.style(background: view, with: skin)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    api.delegate = self
    api.getProducts()
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    super.prepare(for: segue, sender: sender)
    if let addToOrder = segue.destination as? AddToOrderTableViewController {
      var items: [Product: Double] = [:]
      poInProgress.purchases.forEach { purchase in
        if let product = products.first(where: { product -> Bool in
          product.productId == purchase.productId
        }) {
          items[product] = purchase.quantity
        }
      }
      addToOrder.productOrder = items
      addToOrder.products = products
      addToOrder.doneCallback = { updatedItems in
        self.poInProgress.purchases.removeAll()
        updatedItems.forEach { prod, quantity in
          self.poInProgress.purchases.append(PurchaseOrder.Purchase(productId: prod.productId, quantity: quantity))
        }
        self.tableView.reloadSections(IndexSet([1]), with: .automatic)
      }
    } else if let datePickingVC = segue.destination as? DateSelectingViewController {
      let date = poInProgress.dueDate ?? Date().addingTimeInterval(.days(7))
      datePickingVC.date = date
      datePickingVC.doneCallback = { updatedDate in
        self.poInProgress.dueDate = updatedDate
        self.tableView.reloadSections(IndexSet([0]), with: .automatic)
      }
    }
  }

  @IBAction func cancel(_ sender: Any) {
    dismiss(animated: true)
  }

  @IBAction func done(_ sender: Any) {
    do {
      //swiftlint:disable identifier_name
      if let po = poInProgress.purchaseOrder {
        try validatePO()
        api.delegate = self
        try api.submitPO(po: po)
      }
    } catch {
      showAlert(title: "Invalid PO", subtitle: error.localizedDescription)
    }
  }

  @IBAction func addProduct(_ sender: Any) {
    tableView.reloadData()
  }

  // MARK: - Validation

  func validatePO() throws {
    if poInProgress.poNumber.isEmpty {
      throw POError.invalidPONumber
    }
    if poInProgress.purchases.isEmpty {
      throw POError.noItems
    }
    if totalAmount > AppDelegate.configuration.rules.maxPOExpense {
      throw POError.exceedsMax
    }
    if let date = poInProgress.dueDate, date < Date() {
      throw POError.invalidDate
    }
  }

  // MARK: - Table view data source

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0:
      return rows.count
    case 1:
      return poInProgress.purchases.count
    default:
      fatalError("too many sections")
    }
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch indexPath.section {
    case 0:
      let rowInfo = rows[indexPath.row]
      switch rowInfo.type {
      case .stringValue:
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath)
        let nameLabel = cell.contentView.viewWithTag(1) as! UILabel
        nameLabel.text = rowInfo.label

        let valueLabel = cell.contentView.viewWithTag(2) as! UILabel
        valueLabel.text = rowInfo.value?()

        return cell
      case .textInput:
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextCell", for: indexPath)
        let label = cell.contentView.viewWithTag(1) as! UILabel
        label.text = rowInfo.label

        let textField = cell.contentView.viewWithTag(2) as! UITextField
        textField.text = rowInfo.value?() ?? ""

        return cell
      }
    case 1:
      let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath)

      let purchase = poInProgress.purchases[indexPath.row]
      let product = products.first { product -> Bool in
        product.productId == purchase.productId
      }
      let count = purchase.quantity

      let nameLabel = cell.contentView.viewWithTag(1) as! UILabel
      nameLabel.text = (product?.productName ?? "???") + " (\(count))"

      let priceFormatter = NumberFormatter()
      priceFormatter.numberStyle = .currency

      let costLabel = cell.contentView.viewWithTag(2) as! UILabel
      if let cost = product?.unitPrice {
        costLabel.text = priceFormatter.string(for: count * cost)
      } else {
        costLabel.text = "???"
      }

      return cell
    default:
      fatalError("too many sections")
    }
  }

  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard section == 1 else { return nil }
    return productHeaderView
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard indexPath.section == 0 else { return }
    let rowInfo = rows[indexPath.row]
    switch rowInfo.selection {
    case .datePicker:
      performSegue(withIdentifier: "showDate", sender: tableView)
    case .none:
      break
    }
  }
}

// MARK: - Textfield Delegate
extension CreatePurachaseOrderTableViewController: UITextFieldDelegate {
}

// MARK: - APIDelegate

extension CreatePurachaseOrderTableViewController: APIDelegate {
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

  func purchasesLoaded(purchases: [PurchaseOrder]) {
    dismiss(animated: true)
  }
  func purchasesFailed(error: Error) {
    showAlert(title: "Could not save purchase", subtitle: error.localizedDescription)
  }

  func productsLoaded(products: [Product]) {
    self.products = products
    tableView.reloadData()
  }

  func productsFailed(error: Error) {
    showAlert(title: "Could not load products", subtitle: error.localizedDescription)
  }
}
