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

struct POCreateData: Content {
  var poNumber: String
  var comment: String?
  var dueDate: Date?
  var purchases: [PurchaseOrder.Purchase]
}

final class PurchasesController: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    let routes = routes.grouped("api", "purchases")

    let tokenProtected = routes.grouped(Token.authenticator(), Token.guardMiddleware())
    tokenProtected.get(use: getAllHandler)
    tokenProtected.post(use: create)
  }

  private func getAllHandler(_ req: Request) throws -> EventLoopFuture<[PurchaseOrder]> {
    return PurchaseOrder.query(on: req.db).all()
  }

  private func create(req: Request) throws -> EventLoopFuture<PurchaseOrder> {
    print("here")
    let user = try req.auth.require(User.self)
    print(user)
    do {
    let _ = try req.content.decode(POCreateData.self)
    } catch {
      print(error)
    }
    print ("pd")
    let data = try req.content.decode(POCreateData.self)
    print("data")
    let po = PurchaseOrder(poNumber: data.poNumber,
                           comment: data.comment,
                           purchaser: user.id!,
                           purchaseDate: Date(),
                           dueDate: data.dueDate,
                           purchases: data.purchases)
    return po.save(on: req.db).map { po }
  }
}


//final class PurchasesController: RouteCollection {
//  
//  func boot(router: Router) throws {
//    let routes = router.grouped("api", "purchases")
//    
//    let tokenAuthMiddleware = User.tokenAuthMiddleware()
//    let guardAuthMiddleware = User.guardAuthMiddleware()
//    let authGroup = routes.grouped(tokenAuthMiddleware, guardAuthMiddleware)
//    authGroup.get(use: getAllHandler)
//    authGroup.post(POCreateData.self, use: createHandler)
//  }
//  
//  func getAllHandler(_ req: Request) throws -> Future<[PurchaseOrder]> {
//    return PurchaseOrder.query(on: req).all()
//  }
//
//  func createHandler(_ req: Request, data: POCreateData) throws -> Future<PurchaseOrder> {
//    let user = try req.requireAuthenticated(User.self)
//    let po = PurchaseOrder(id: nil, poNumber: data.poNumber, comment: data.comment, purchaser: user.id!.uuidString, purchaseDate: Date(), dueDate: data.dueDate, purchases: data.purchases)
//    return po.save(on: req)
//  }
//}
//
