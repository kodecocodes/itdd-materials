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

struct Event: Codable {
  var id: Int?
  var name: String
  var date: Date
  var type: String
  var duration: TimeInterval
}

extension Event: SQLiteModel {}
extension Event: Migration {}
extension Event: Content {}

struct SeedEvents: Migration {
  typealias Database = SQLiteDatabase

  static func prepare(on connection: SQLiteConnection) -> Future<Void> {
    return Event(id: 1, name: "Alien invasion", date: Date().at(8), type: "Appointment", duration: .hours(1)).create(on: connection)
      .and(Event(id: 2, name: "Interview with Hydra", date: Date().at(13, minutes: 30), type: "Appointment", duration: .hours(0.5)).create(on: connection))
      .and(Event(id: 3, name: "Panic attack", date: Date(timeIntervalSinceNow: .days(7)).at(10), type: "Meeting", duration: .hours(1)).create(on: connection))
      .transform(to: ())
  }

  static func revert(on connection: SQLiteConnection) -> Future<Void> {
    return .done(on: connection)
  }
}
