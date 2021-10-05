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

extension TimeInterval {
  
  public var year: TimeInterval { return years }
  public var years: TimeInterval { return self * 366.days }
  
  public var month: TimeInterval { return months }
  public var months: TimeInterval { return self * 31.days }
  
  public var week: TimeInterval { return weeks }
  public var weeks: TimeInterval { return self * 7.days }
  
  public var day: TimeInterval { return days }
  public var days: TimeInterval { return self * 24.hours }
  
  public var hour: TimeInterval { return hours }
  public var hours: TimeInterval { return self * 60.minutes }
  
  public var minute: TimeInterval { return minutes }
  public var minutes: TimeInterval { return self * 60.seconds }
  
  public var second: TimeInterval { return seconds }
  public var seconds: TimeInterval { return self }
  
  public var pastDate: Date {
    return Date(timeIntervalSinceNow: -1 * self)
  }
}
