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

final class Event: Model, Content {
  static let schema = "events"

  @ID(key: .id)
  var id: UUID?

  @Field(key: "name")
  var name: String
  @Field(key: "date")
  var date: Date
  @Field(key: "type")
  var type: String
  @Field(key: "duration")
  var duration: TimeInterval

  init() {}

  init(id: UUID? = nil, name: String, date: Date, type: String, duration: TimeInterval) {
    self.id = id
    self.name = name
    self.date = date
    self.type = type
    self.duration = duration
  }
}

struct CreateEvents: Migration {
  func prepare(on database: Database) -> EventLoopFuture<Void> {
    database.schema(Event.schema)
      .id()
      .field("name", .string, .required)
      .field("date", .datetime, .required)
      .field("type", .string, .required)
      .field("duration", .double, .required)
      .create()
  }

  func revert(on database: Database) -> EventLoopFuture<Void> {
    database.schema(Announcement.schema).delete()
  }
}

struct SeedEvents: Migration {
  func prepare(on database: Database) -> EventLoopFuture<Void> {
    Event(name: "Alien invasion", date: Date().at(8), type: "Appointment", duration: .hours(1)).create(on: database)
      .and(Event(name: "Interview with Hydra", date: Date().at(13, minutes: 30), type: "Appointment", duration: .hours(0.5)).create(on: database))
      .and(Event(name: "Panic attack", date: Date(timeIntervalSinceNow: .days(7)).at(10), type: "Meeting", duration: .hours(1)).create(on: database))
      .transform(to: ())
  }

  func revert(on database: Database) -> EventLoopFuture<Void> {
    database.eventLoop.makeSucceededVoidFuture()
  }
}
