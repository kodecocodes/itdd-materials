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
import Login
import UIHelpers

let userLoggedInNotification =
  Notification.Name("user logged in")
let userLoggedOutNotification =
  Notification.Name("user logged out")

enum UserNotificationKey: String {
  case userId
}

protocol APIDelegate: AnyObject {
  func announcementsFailed(error: Error)
  func announcementsLoaded(announcements: [Announcement])
  func orgLoaded(org: [Employee])
  func orgFailed(error: Error)
  func eventsLoaded(events: [Event])
  func eventsFailed(error: Error)
  func productsLoaded(products: [Product])
  func productsFailed(error: Error)
  func purchasesLoaded(purchases: [PurchaseOrder])
  func purchasesFailed(error: Error)
  func userLoaded(user: UserInfo)
  func userFailed(error: Error)
}

class API: LoginAPI {
  let server: String
  let session: URLSession

  weak var delegate: APIDelegate?
  var token: Token?

  init(server: String) {
    self.server = server
    session = URLSession(configuration: .default)
  }

  func login(
    username: String,
    password: String,
    completion: @escaping (Result<String, Error>) -> Void
  ) {
    let eventsEndpoint = server + "api/users/login"
    let eventsURL = URL(string: eventsEndpoint)!
    var urlRequest = URLRequest(url: eventsURL)
    urlRequest.httpMethod = "POST"
    let data = "\(username):\(password)".data(using: .utf8)!
    let basic = "Basic \(data.base64EncodedString())"
    urlRequest.addValue(basic, forHTTPHeaderField: "Authorization")
    let task = session.dataTask(with: urlRequest) { data, _, error in
      guard let data = data else {
        if error != nil {
          DispatchQueue.main.async {
            completion(.failure(error!))
          }
        }
        return
      }
      let decoder = JSONDecoder()
      if let token = try? decoder.decode(Token.self, from: data) {
        self.handleToken(token: token, completion: completion)
      } else {
        do {
          let error = try decoder.decode(APIError.self, from: data)
          DispatchQueue.main.async {
            completion(.failure(error))
          }
        } catch {
          DispatchQueue.main.async {
            completion(.failure(error))
          }
        }
      }
    }

    task.resume()
  }

  func handleToken(
    token: Token,
    completion: @escaping (Result<String, Error>) -> Void
  ) {
    self.token = token
    Logger.logDebug("user \(token.user.id)")
    DispatchQueue.main.async {
      let note = Notification(
        name: userLoggedInNotification,
        object: self,
        userInfo: [
          UserNotificationKey.userId: token.user.id.uuidString
        ])
      NotificationCenter.default.post(note)
      completion(.success(token.user.id.uuidString))
    }
  }

  func logout() {
    token = nil
    delegate = nil
    let note = Notification(name: userLoggedOutNotification)
    NotificationCenter.default.post(note)
  }

  //swiftlint:disable identifier_name
  func submitPO(po: PurchaseOrder) throws {
    let url = URL(string: server + "api/" + "purchases")!
    var request = URLRequest(url: url)
    if let token = token?.token {
      let bearer = "Bearer \(token)"
      request.addValue(bearer, forHTTPHeaderField: "Authorization")
    }
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpMethod = "POST"

    let coder = JSONEncoder()
    coder.dateEncodingStrategy = .iso8601
    let data = try coder.encode(po)
    request.httpBody = data
    let task = loadTask(
      request: request,
      success: self.poSuccess,
      failure: self.delegate?.purchasesFailed(error:))
    task.resume()
  }

  private func poSuccess(po: PurchaseOrder) {
    getPurchases()
  }

  private func request(_ endpoint: String) -> URLRequest {
    let url = URL(string: server + "api/" + endpoint)!
    var request = URLRequest(url: url)
    if let token = token?.token {
      let bearer = "Bearer \(token)"
      request.addValue(bearer, forHTTPHeaderField: "Authorization")
    }
    return request
  }

  func loadTask<T: Decodable>(
    request: URLRequest,
    success: ((T) -> Void)?,
    failure: ((Error) -> Void)?
  ) -> URLSessionTask {
    return session.dataTask(with: request) { data, _, error in
      guard let data = data else {
        if error != nil {
          DispatchQueue.main.async {
            failure?(error!)
          }
        }
        return
      }
      let decoder = JSONDecoder()
      decoder.dateDecodingStrategy = .iso8601
      if let items = try? decoder.decode(T.self, from: data) {
        DispatchQueue.main.async {
          success?(items)
        }
      } else {
        do {
          let error = try decoder.decode(APIError.self, from: data)
          DispatchQueue.main.async {
            failure?(error)
          }
        } catch {
          DispatchQueue.main.async {
            failure?(error)
          }
        }
      }
    }
  }

  func getAnnouncements() {
    let req = request("announcements")
    let task = loadTask(
      request: req,
      success: self.delegate?.announcementsLoaded(announcements:),
      failure: self.delegate?.announcementsFailed(error:))
    task.resume()
  }

  func getOrgChart() {
    let req = request("employees")
    let task = loadTask(
      request: req,
      success: self.delegate?.orgLoaded(org:),
      failure: self.delegate?.orgFailed(error:))
    task.resume()
  }

  func getEvents() {
    let req = request("events")
    let task = loadTask(
      request: req,
      success: self.delegate?.eventsLoaded(events:),
      failure: self.delegate?.eventsFailed(error:))
    task.resume()
  }

  func getProducts() {
    let req = request("products")
    let task = loadTask(
      request: req,
      success: self.delegate?.productsLoaded(products:),
      failure: self.delegate?.productsFailed(error:))
    task.resume()
  }

  func getPurchases() {
    let req = request("purchases")
    let task = loadTask(
      request: req,
      success: self.delegate?.purchasesLoaded(purchases:),
      failure: self.delegate?.purchasesFailed(error:))
    task.resume()
  }

  func getUserInfo(userID: String) {
    let req = request("users/\(userID)")
    let task = loadTask(
      request: req,
      success: self.delegate?.userLoaded(user:),
      failure: self.delegate?.userFailed(error:))
    task.resume()
  }
}
