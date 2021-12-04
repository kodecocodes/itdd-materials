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

class CalendarModel {
  let api: API
  var birthdayCallback: ((Result<[Event], Error>) -> Void)?
  var eventsCallback: ((Result<[Event], Error>) -> Void)?

  init(api: API) {
    self.api = api
  }

  func convertBirthdays(_ employees: [Employee]) -> [Event] {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = Employee.birthdayFormat
    return employees.compactMap {
      if let dayString = $0.birthday,
        let day = dateFormatter.date(from: dayString),
        let nextBirthday = day.next() {
        let title = $0.displayName + " Birthday"
        return Event(
          name: title,
          date: nextBirthday,
          type: .birthday,
          duration: 0)
      }
      return nil
    }
  }

  func getBirthdays(completion: @escaping (Result<[Event], Error>) -> Void) {
    birthdayCallback = completion
    api.delegate = self
    api.getOrgChart()
  }

  func getEvents(completion: @escaping (Result<[Event], Error>) -> Void) {
    eventsCallback = completion
    api.delegate = self
    api.getEvents()
  }

  func getAll(completion: @escaping (Result<[Event], Error>) -> Void) {
    getEvents { firstResult in
      self.getBirthdays { secondResult in
        switch (firstResult, secondResult) {
        case let (.success(events1), .success(events2)):
          completion(.success(events1 + events2))
        case (.failure, _):
          completion(firstResult)
        default:
          completion(secondResult)
        }
      }
    }
  }
}

extension CalendarModel: APIDelegate {
  func orgLoaded(org: [Employee]) {
    let birthdays = convertBirthdays(org)
    birthdayCallback?(.success(birthdays))
    birthdayCallback = nil
  }

  func orgFailed(error: Error) {
    birthdayCallback?(.failure(error))
    birthdayCallback = nil
  }

  func eventsLoaded(events: [Event]) {
    eventsCallback?(.success(events))
    eventsCallback = nil
  }

  func eventsFailed(error: Error) {
    eventsCallback?(.failure(error))
    eventsCallback = nil
  }

  func loginFailed(error: Error) {}
  func loginSucceeded(userId: String) {}
  func announcementsFailed(error: Error) {}
  func announcementsLoaded(announcements: [Announcement]) {}
  func productsLoaded(products: [Product]) {}
  func productsFailed(error: Error) {}
  func purchasesLoaded(purchases: [PurchaseOrder]) {}
  func purchasesFailed(error: Error) {}
  func userLoaded(user: UserInfo) {}
  func userFailed(error: Error) {}
}
