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

import Vapor
import FluentSQLite

struct PurchaseOrder: Codable {
  struct Purchase: Codable {
    let productId: String
    let quantity: Double
  }

  var id: Int?
  var poNumber: String
  var comment: String?
  var purchaser: String
  var purchaseDate: Date
  var dueDate: Date?
  var purchases: [Purchase]
}

extension PurchaseOrder: SQLiteModel {}
extension PurchaseOrder: Migration {}
extension PurchaseOrder: Content {}
extension PurchaseOrder: Parameter {}

struct SeedPurchases: Migration {
  typealias Database = SQLiteDatabase
  
  static func prepare(on connection: SQLiteConnection) -> Future<Void> {
    return PurchaseOrder(id: 1, poNumber: "88616",
                         comment: "For Assembly", purchaser: "BlackWidow",
                         purchaseDate: Date(), dueDate: nil,
                         purchases: [PurchaseOrder.Purchase(productId: "8301", quantity: 1), PurchaseOrder.Purchase(productId: "1208", quantity: 1)]).create(on: connection)
      .and(PurchaseOrder(id: 2, poNumber: "88617",
                         comment: nil, purchaser: "BlackWidow",
                         purchaseDate: Date(), dueDate: Date(timeIntervalSinceNow: .days(7)),
                         purchases: [PurchaseOrder.Purchase(productId: "210", quantity: 400)]).create(on: connection))
      .transform(to: ())
  }
  
  static func revert(on connection: SQLiteConnection) -> Future<Void> {
    return .done(on: connection)
  }
}
