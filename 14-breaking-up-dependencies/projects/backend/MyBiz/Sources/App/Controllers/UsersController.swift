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
import Crypto

struct UserSignup: Content {
  let username: String
  let password: String
  let name: String
}

struct NewSession: Content {
  let token: String
  let user: User.Public
}

extension UserSignup: Validatable {
  static func validations(_ validations: inout Validations) {
    validations.add("username", as: String.self, is: !.empty)
    validations.add("name", as: String.self, is: !.empty)
    validations.add("password", as: String.self, is: .count(6...))
  }
}

struct UserController: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    let usersRoute = routes.grouped("api", "users")
    usersRoute.post("signup", use: create)

    let tokenProtected = usersRoute.grouped(Token.authenticator())
    tokenProtected.get("me", use: getMyOwnUser)

    let passwordProtected = usersRoute.grouped(User.authenticator())
    passwordProtected.post("login", use: login)
  }

  fileprivate func create(req: Request) throws -> EventLoopFuture<NewSession> {
    try UserSignup.validate(content: req)
    let userSignup = try req.content.decode(UserSignup.self)
    let user = try User.create(from: userSignup)
    var token: Token!

    guard let newToken = try? user.createToken(source: .signup) else {
      return req.eventLoop.future(error: Abort(.internalServerError))
    }
    token = newToken

    return user.save(on: req.db).flatMap {
      return token.save(on: req.db)
        .flatMapThrowing {
          NewSession(token: token.value, user: try user.asPublic())
        }
    }
  }

  fileprivate func login(req: Request) throws -> EventLoopFuture<NewSession> {
    let user = try req.auth.require(User.self)
    let token = try user.createToken(source: .login)

    return token.save(on: req.db).flatMapThrowing {
      NewSession(token: token.value, user: try user.asPublic())
    }
  }

  func getMyOwnUser(req: Request) throws -> User.Public {
    try req.auth.require(User.self).asPublic()
  }
}
