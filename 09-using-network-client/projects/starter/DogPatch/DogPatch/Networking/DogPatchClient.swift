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
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation

class DogPatchClient {
  
  let baseURL: URL
  let session: URLSessionProtocol
  let responseQueue: DispatchQueue?

  init(baseURL: URL,
       session: URLSessionProtocol,
       responseQueue: DispatchQueue?) {
    self.baseURL = baseURL
    self.session = session
    self.responseQueue = responseQueue
  }
  
  func getDogs(completion: @escaping
    ([Dog]?, Error?) -> Void) -> URLSessionTaskProtocol {    
    let url = URL(string: "dogs", relativeTo: baseURL)!
    let task = session.makeDataTask(with: url) { [weak self]
      data, response, error in
      guard let self = self else { return }
      guard let response = response as? HTTPURLResponse,
        response.statusCode == 200,
        error == nil,
        let data = data else {
          self.dispatchResult(error: error, completion: completion)
          return
      }
      let decoder = JSONDecoder()
      do {
        let dogs = try decoder.decode([Dog].self, from: data)
        self.dispatchResult(models: dogs, completion: completion)
      } catch {
        self.dispatchResult(error: error, completion: completion)
      }
    }
    task.resume()
    return task
  }
  
  private func dispatchResult<Type>(
    models: Type? = nil,
    error: Error? = nil,
    completion: @escaping (Type?, Error?) -> Void) {
    guard let responseQueue = responseQueue else {
      completion(models, error)
      return
    }
    responseQueue.async {
      completion(models, error)
    }
  }
}
