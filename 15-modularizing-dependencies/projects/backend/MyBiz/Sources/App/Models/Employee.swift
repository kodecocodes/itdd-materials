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
import Foundation

final class Employee: Model, Content {
  static let schema = "employees"

  @ID(key: .id)
  var id: UUID?

  @Field(key: "givenName")
  var givenName: String
  @Field(key: "familyName")
  var familyName: String
  @Field(key: "location")
  var location: String
  @Field(key: "manager")
  var manager: UUID?
  @Field(key: "directReports")
  var directReports: [UUID]
  @Field(key: "birthday")
  var birthday: String

  init() {}

  init(id: UUID? = nil, givenName: String, familyName: String, location: String, manager: UUID?, directReports: [UUID], birthday: String) {
    self.id = id
    self.givenName = givenName
    self.familyName = familyName
    self.location = location
    self.manager = manager
    self.directReports = directReports
    self.birthday = birthday
  }
}

struct CreateEmployees: Migration {
  func prepare(on database: Database) -> EventLoopFuture<Void> {
    database.schema(Employee.schema)
      .id()
      .field("givenName", .string, .required)
      .field("familyName", .string, .required)
      .field("location", .string, .required)
      .field("manager", .uuid)
      .field("directReports", .array, .required)
      .field("birthday", .string, .required)
      .create()
  }

  func revert(on database: Database) -> EventLoopFuture<Void> {
    database.schema(Employee.schema).delete()
  }
}

let BlackWidow = UUID(uuidString: "8803F62C-67F3-4A6E-AA0F-EBFE3FF4F08B")!
struct SeedEmployees: Migration {
  func prepare(on database: Database) -> EventLoopFuture<Void> {
    let nf = UUID()
    let pc = UUID()
    let cd = UUID()
    let o = UUID()
    let wm = UUID()
    let s = UUID()

    return Employee(id: nf,  givenName: "Nick", familyName: "Fury", location: "Unknown", manager: nil, directReports: [BlackWidow,pc,cd], birthday: "05-04-1963").create(on: database)
      .and(Employee(id: BlackWidow, givenName: "Natasha", familyName: "Romanoff", location: "Voromir", manager: nf, directReports: [o, wm], birthday: "10-22-1984").create(on: database))
      .and(Employee(id: pc, givenName: "Phil", familyName: "Coulson", location: "DC", manager: nf, directReports: [], birthday: "04-08-1964").create(on: database))
      .and(Employee(id: o, givenName: "", familyName: "Okoye", location: "Wakanda", manager: BlackWidow, directReports: [], birthday: "10-01-1998").create(on: database))
      .and(Employee(id: wm, givenName: "James", familyName: "Rhodes", location: "DC", manager: BlackWidow, directReports: [], birthday: "10-08-1968").create(on: database))
      .and(Employee(id: cd, givenName: "Carol", familyName: "Danvers", location: "Space", manager: nf, directReports: [s], birthday: "03-01-1968").create(on: database))
      .and(Employee(id: s, givenName: "Monica", familyName: "Rambeau", location: "New York", manager: cd, directReports: [], birthday: "10-18-1982").create(on: database))
      .transform(to: ())
  }

  func revert(on database: Database) -> EventLoopFuture<Void> {
    database.eventLoop.makeSucceededVoidFuture()
  }
}
