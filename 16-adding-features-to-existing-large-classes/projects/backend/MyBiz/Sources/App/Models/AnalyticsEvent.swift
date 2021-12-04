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

final class AnalyticsEvent: Model, Content {
  static let schema = "analytics"
  
  @ID(key: .id)
  var id: UUID?

  @Field(key: "name")
  var name: String
  @Field(key: "user")
  var user: UUID
  @Field(key: "eventDate")
  var eventDate: Date
  @Field(key: "recordedDate")
  var recordedDate: Date
  @Field(key: "type")
  var type: String
  @Field(key: "duration")
  var duration: TimeInterval?
  @Field(key: "device")
  var device: String?
  @Field(key: "os")
  var os: String?
  @Field(key: "appVersion")
  var appVersion: String?

  init() {}

  init(id: UUID? = nil, name: String, user: UUID, eventDate: Date, recordedDate: Date, type: String, duration: TimeInterval? = nil, device: String? = nil, os: String? = nil, appVersion: String? = nil) {
    self.id = id
    self.name = name
    self.user = user
    self.eventDate = eventDate
    self.recordedDate = recordedDate
    self.type = type
    self.duration = duration
    self.device = device
    self.os = os
    self.appVersion = appVersion
  }
}

struct CreateAnalytics: Migration {
  func prepare(on database: Database) -> EventLoopFuture<Void> {
    database.schema(AnalyticsEvent.schema)
      .id()
      .field("name", .string, .required)
      .field("user", .uuid, .required)
      .field("eventDate", .datetime, .required)
      .field("recordedDate", .datetime, .required)
      .field("type", .string, .required)
      .field("duration", .double)
      .field("device", .string)
      .field("os", .string)
      .field("appVersion", .string)
      .create()
  }

  func revert(on database: Database) -> EventLoopFuture<Void> {
    database.schema(AnalyticsEvent.schema).delete()
  }
}
