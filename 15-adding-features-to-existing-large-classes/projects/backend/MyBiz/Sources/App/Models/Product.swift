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
import Fluent

final class Product: Model, Content {
  static let schema = "products"

  @ID(key: .id)
  var id: UUID?

  @Field(key: "name")
  var name: String
  @Field(key: "unitPrice")
  var unitPrice: Double

  init() {}

  init(id: UUID? = nil, name: String, unitPrice: Double) {
    self.id = id
    self.name = name
    self.unitPrice = unitPrice
  }
}

struct CreateProducts: Migration {
  func prepare(on database: Database) -> EventLoopFuture<Void> {
    database.schema(Product.schema)
      .id()
      .field("name", .string, .required)
      .field("unitPrice", .double, .required)
      .create()
  }

  func revert(on database: Database) -> EventLoopFuture<Void> {
    database.schema(Product.schema).delete()
  }
}

let Moljnir = UUID(uuidString: "4270CFAB-2959-4308-A732-623A6D6F748F")!
let Shield = UUID(uuidString: "7F6F4B73-D231-438F-93DF-8816FE07E443")!
let Arrows = UUID(uuidString: "267F7506-3291-4261-A91C-26FDDE85E04E")!
struct SeedProducts: Migration {
  func prepare(on database: Database) -> EventLoopFuture<Void> {
    Product(name: "Exploding Arrows", unitPrice: 38.5).create(on: database)
      .and(Product(id: Arrows, name: "Electrical Arrows", unitPrice: 119.28).create(on: database))
      .and(Product(name: "Acid Arrow", unitPrice: 9.5).create(on: database))
      .and(Product(id: Moljnir, name: "Moljnir", unitPrice: 72000).create(on: database))
      .and(Product(id: Shield, name: "Shield", unitPrice: 1_200_837).create(on: database))
      .and(Product(name: "Web Slinger", unitPrice: 750).create(on: database))
      .and(Product(name: "Nanotech Armor", unitPrice: 650_888).create(on: database))
      .and(Product(name: "Metal Claws", unitPrice: 27_800).create(on: database))
      .and(Product(name: "Fortune Cookie 🥠", unitPrice: 0.5).create(on: database))
      .and(Product(name: "Blank Cassette", unitPrice: 45.66).create(on: database))
      .transform(to: ())
  }

  func revert(on database: Database) -> EventLoopFuture<Void> {
    database.eventLoop.makeSucceededVoidFuture()
  }
}
