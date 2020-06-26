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

final class AnalyticsController: RouteCollection {

  func boot(router: Router) throws {
    let routes = router.grouped("api", "analytics")
    routes.get(use: getAllHandler) // unauthenticated for debug purposes

    let tokenAuthMiddleware = User.tokenAuthMiddleware()
    let guardAuthMiddleware = User.guardAuthMiddleware()
    let authGroup = routes.grouped(tokenAuthMiddleware, guardAuthMiddleware)
    authGroup.post(AECreateData.self, use: createHandler)
  }

  func getAllHandler(_ req: Request) throws -> Future<[AnalyticsEvent]> {
    return AnalyticsEvent.query(on: req).all()
  }

  func createHandler(_ req: Request, data: AECreateData) throws -> Future<AnalyticsEvent> {
    let user = try req.requireAuthenticated(User.self)
    let ae = AnalyticsEvent(id: nil, name: data.name, user: user.id!.uuidString, eventDate: Date(), recordedDate: data.recordedDate, type: data.type, duration: data.duration, device: data.device, os: data.os, appVersion: data.appVersion)
    return ae.save(on: req)
  }
}

struct AECreateData: Content {
  var name: String
  var recordedDate: Date
  var type: String
  var duration: TimeInterval?
  var device: String?
  var os: String?
  var appVersion: String?
}
