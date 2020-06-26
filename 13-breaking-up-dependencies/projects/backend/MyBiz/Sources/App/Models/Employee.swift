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

struct Employee: Codable {
  var id: String?
  var givenName: String
  var familyName: String
  var location: String
  var manager: String?
  var directReports: [String]
  var birthday: String
}

extension Employee: SQLiteStringModel {}
extension Employee: Migration {}
extension Employee: Content {}

struct SeedEmployees: Migration {
  typealias Database = SQLiteDatabase

  static func prepare(on connection: SQLiteConnection) -> Future<Void> {
    return  Employee(id: "1",  givenName: "Nick", familyName: "Fury", location: "Unknown", manager: nil, directReports: ["BlackWidow","Coulson","CaptainMarvel"], birthday: "05-04-1963").create(on: connection)
    .and(Employee(id: "BlackWidow", givenName: "Natasha", familyName: "Romanoff", location: "Voromir", manager: "1", directReports: ["Okoye", "WarMachine"], birthday: "10-22-1984").create(on: connection))
    .and(Employee(id: "Coulson", givenName: "Phil", familyName: "Coulson", location: "DC", manager: "1", directReports: [], birthday: "04-08-1964").create(on: connection))
    .and(Employee(id: "Okoye", givenName: "", familyName: "Okoye", location: "Wakanda", manager: "BlackWidow", directReports: [], birthday: "10-01-1998").create(on: connection))
    .and(Employee(id: "WarMachine", givenName: "James", familyName: "Rhodes", location: "DC", manager: "BlackWidow", directReports: [], birthday: "10-08-1968").create(on: connection))
    .and(Employee(id: "CaptainMarvel", givenName: "Carol", familyName: "Danvers", location: "Space", manager: "1", directReports: ["Spectrum"], birthday: "03-01-1968").create(on: connection))
    .and(Employee(id: "Spectrum", givenName: "Monica", familyName: "Rambeau", location: "New York", manager: "CaptainMarvel", directReports: [], birthday: "10-18-1982").create(on: connection))
    .transform(to: ())
  }

  static func revert(on connection: SQLiteConnection) -> Future<Void> {
    return .done(on: connection)
  }
}
