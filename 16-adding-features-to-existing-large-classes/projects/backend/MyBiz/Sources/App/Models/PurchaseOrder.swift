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

import Vapor
import Fluent

final class PurchaseOrder: Model, Content {
  static let schema = "purchases"

  struct Purchase: Codable {
    let productId: UUID
    let quantity: Double
  }

  @ID(key: .id)
  var id: UUID?

  @Field(key: "poNumber")
  var poNumber: String
  @Field(key: "comment")
  var comment: String?
  @Field(key: "purchaser")
  var purchaser: UUID
  @Field(key: "purchaseDate")
  var purchaseDate: Date
  @Field(key: "dueDate")
  var dueDate: Date?
  @Field(key: "purchases")
  var purchases: [Purchase]

  init() {}

  init(id: UUID? = nil, poNumber: String, comment: String?, purchaser: UUID, purchaseDate: Date, dueDate: Date?, purchases: [Purchase]) {
    self.id = id
    self.poNumber = poNumber
    self.comment = comment
    self.purchaser = purchaser
    self.purchaseDate = purchaseDate
    self.dueDate = dueDate
    self.purchases = purchases
  }
}

struct CreatePurchases: Migration {
  func prepare(on database: Database) -> EventLoopFuture<Void> {
    database.schema(PurchaseOrder.schema)
      .id()
      .field("poNumber", .string, .required)
      .field("comment", .string)
      .field("purchaser", .uuid, .required)
      .field("purchaseDate", .datetime, .required)
      .field("dueDate", .datetime)
      .field("purchases", .array, .required)
      .create()
  }

  func revert(on database: Database) -> EventLoopFuture<Void> {
    database.schema(PurchaseOrder.schema).delete()
  }
}

struct SeedPurchases: Migration {
  func prepare(on database: Database) -> EventLoopFuture<Void> {
    PurchaseOrder(poNumber: "88616",
                  comment: "For Assembly",
                  purchaser: BlackWidow,
                  purchaseDate: Date(),
                  dueDate: nil,
                  purchases: [PurchaseOrder.Purchase(productId: Moljnir, quantity: 1), PurchaseOrder.Purchase(productId: Shield, quantity: 1)]).create(on: database)
      .and(PurchaseOrder(poNumber: "88617",
                         comment: nil,
                         purchaser: BlackWidow,
                         purchaseDate: Date(),
                         dueDate: Date(timeIntervalSinceNow: .days(7)),
                         purchases: [PurchaseOrder.Purchase(productId: Arrows, quantity: 400)]).create(on: database))
      .transform(to: ())
  }

  func revert(on database: Database) -> EventLoopFuture<Void> {
    database.eventLoop.makeSucceededVoidFuture()
  }
}
