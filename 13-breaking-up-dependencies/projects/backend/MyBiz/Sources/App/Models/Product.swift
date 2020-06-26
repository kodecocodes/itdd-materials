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

struct Product: Codable {
  var id: String?
  var name: String
  var unitPrice: Double
}

extension Product: SQLiteStringModel {}
extension Product: Migration {}
extension Product: Content {}

struct SeedProducts: Migration {
  typealias Database = SQLiteDatabase
  
  static func prepare(on connection: SQLiteConnection) -> Future<Void> {
    return Product(id: "210", name: "Exploding Arrows", unitPrice: 38.5).create(on: connection)
      .and(Product(id: "211", name: "Electrical Arrows", unitPrice: 119.28).create(on: connection))
      .and(Product(id: "212", name: "Acid Arrow", unitPrice: 9.5).create(on: connection))
      .and(Product(id: "8301", name: "Moljnir", unitPrice: 72000).create(on: connection))
      .and(Product(id: "1208", name: "Shield", unitPrice: 1_200_837).create(on: connection))
      .and(Product(id: "712", name: "Web Slinger", unitPrice: 750).create(on: connection))
      .and(Product(id: "2219", name: "Nanotech Armor", unitPrice: 650_888).create(on: connection))
      .and(Product(id: "945", name: "Metal Claws", unitPrice: 27_800).create(on: connection))
      .and(Product(id: "7", name: "Fortune Cookie 🥠", unitPrice: 0.5).create(on: connection))
      .and(Product(id: "42100", name: "Blank Cassette", unitPrice: 45.66).create(on: connection))
      .transform(to: ())
  }
  
  static func revert(on connection: SQLiteConnection) -> Future<Void> {
    return .done(on: connection)
  }
}
