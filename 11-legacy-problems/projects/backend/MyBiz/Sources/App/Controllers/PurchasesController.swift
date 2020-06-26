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

final class PurchasesController: RouteCollection {
  
  func boot(router: Router) throws {
    let routes = router.grouped("api", "purchases")
    
    let tokenAuthMiddleware = User.tokenAuthMiddleware()
    let guardAuthMiddleware = User.guardAuthMiddleware()
    let authGroup = routes.grouped(tokenAuthMiddleware, guardAuthMiddleware)
    authGroup.get(use: getAllHandler)
    authGroup.post(POCreateData.self, use: createHandler)
  }
  
  func getAllHandler(_ req: Request) throws -> Future<[PurchaseOrder]> {
    return PurchaseOrder.query(on: req).all()
  }

  func createHandler(_ req: Request, data: POCreateData) throws -> Future<PurchaseOrder> {
    let user = try req.requireAuthenticated(User.self)
    let po = PurchaseOrder(id: nil, poNumber: data.poNumber, comment: data.comment, purchaser: user.id!.uuidString, purchaseDate: Date(), dueDate: data.dueDate, purchases: data.purchases)
    return po.save(on: req)
  }
}

struct POCreateData: Content {
  var poNumber: String
  var comment: String?
  var dueDate: Date?
  var purchases: [PurchaseOrder.Purchase]
}
