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

extension API: AnalyticsAPI {
  func sendReport(report: Report) {
    try? logAnalytics(analytics: report) { _ in }
  }
}

extension API {
  // 1
  func logAnalytics(
    analytics: Report,
    completion: @escaping (Result<Report, Error>) -> Void
  ) throws {
    // 2
    let url = URL(string: server + "api/analytics")!
    var request = URLRequest(url: url)
    if let token = token?.token {
      let bearer = "Bearer \(token)"
      request.addValue(
        bearer,
        forHTTPHeaderField: "Authorization")
    }
    request.addValue(
      "application/json",
      forHTTPHeaderField: "Content-Type")
    request.httpMethod = "POST"

    let coder = JSONEncoder()
    coder.dateEncodingStrategy = .iso8601
    let data = try coder.encode(analytics)
    request.httpBody = data

    // 3
    sender.send(
      request: request,
      success: { savedEvent in
        completion(.success(savedEvent))
      },
      failure: { error in
        completion(.failure(error))
      })
  }
}
