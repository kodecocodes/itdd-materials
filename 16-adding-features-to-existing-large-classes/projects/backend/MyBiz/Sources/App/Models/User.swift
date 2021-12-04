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

import Foundation
import Vapor
import Fluent

final class User: Model {
  static let schema = "users"

  struct Public: Content {
    let username: String
    let id: UUID
  }

  @ID(key: .id)
  var id: UUID?

  @Field(key: "name")
  var name: String
  @Field(key: "username")
  var username: String
  @Field(key: "passwordHash")
  var passwordHash: String

  init() {}

  init(id: UUID? = nil, name: String, username: String, passwordHash: String) {
    self.id = id
    self.name = name
    self.username = username
    self.passwordHash = passwordHash
  }
}

extension User {
  static func create(from userSignup: UserSignup) throws -> User {
    User(name: userSignup.name, username: userSignup.username, passwordHash: try Bcrypt.hash(userSignup.password))
  }

  func createToken(source: SessionSource) throws -> Token {
    let calendar = Calendar(identifier: .gregorian)
    let expiryDate = calendar.date(byAdding: .year, value: 1, to: Date())
    return try Token(userId: requireID(),
      token: [UInt8].random(count: 16).base64, source: source, expiresAt: expiryDate)
  }

  func asPublic() throws -> Public {
    Public(username: username,
           id: try requireID())
  }
}

extension User: ModelAuthenticatable {
  static let usernameKey = \User.$username
  static let passwordHashKey = \User.$passwordHash

  func verify(password: String) throws -> Bool {
    try Bcrypt.verify(password, created: self.passwordHash)
  }
}

struct CreateUsers: Migration {
  func prepare(on database: Database) -> EventLoopFuture<Void> {
    database.schema(User.schema)
      .field("id", .uuid, .identifier(auto: true))
      .field("username", .string, .required)
      .unique(on: "username")
      .field("name", .string, .required)
      .field("passwordHash", .string, .required)
      .create()
  }

  func revert(on database: Database) -> EventLoopFuture<Void> {
    database.schema(User.schema).delete()
  }
}

struct SeedUsers: Migration {
  func prepare(on database: Database) -> EventLoopFuture<Void> {
    let password = try? Bcrypt.hash("hailHydra")
    guard let hashedPassword = password else {
      fatalError("Failed to create admin user")
    }
    let user = User(name: "Agent", username: "agent@shield.org", passwordHash: hashedPassword)
    return user.create(on: database)
      .transform(to: ())
  }

  func revert(on database: Database) -> EventLoopFuture<Void> {
    database.eventLoop.makeSucceededVoidFuture()
  }

}
