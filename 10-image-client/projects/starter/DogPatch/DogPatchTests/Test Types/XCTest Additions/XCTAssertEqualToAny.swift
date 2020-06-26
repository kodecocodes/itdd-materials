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

import XCTest

public func XCTAssertEqualToAny<T: Equatable>(_ actual: @autoclosure () throws -> T,
                                              _ expected: @autoclosure () throws -> Any?,
                                              file: StaticString = #file,
                                              line: UInt = #line) throws {
  let actual = try actual()
  let expected = try XCTUnwrap(expected() as? T)
  XCTAssertEqual(actual, expected, file: file, line: line)
}

public func XCTAssertEqualToDate(_ actual: @autoclosure () throws -> Date,
                                 _ expected: @autoclosure () throws -> Any?,
                                 file: StaticString = #file,
                                 line: UInt = #line) throws {
  let actual = try actual()
  let value = try expected()
  let expected: Date
  if let value = value as? TimeInterval {
    expected = Date(timeIntervalSinceReferenceDate: value)
  } else {
    expected = try XCTUnwrap(value as? Date)
  }
  XCTAssertEqual(actual, expected, file: file, line: line)  
}

public func XCTAssertEqualToDecimal(_ actual: @autoclosure () throws -> Decimal,            
                                    _ expected: @autoclosure () throws -> Any?,
                                    file: StaticString = #file,
                                    line: UInt = #line) throws {

  let actual = try actual()
  let value = try XCTUnwrap(expected() as? Double)
  let expected = Decimal(value)
  
  XCTAssertEqual(actual, expected, file: file, line: line)
}

public func XCTAssertEqualToURL(_ actual: @autoclosure () throws -> URL,
                                _ expected: @autoclosure () throws -> Any?,
                                file: StaticString = #file,
                                line: UInt = #line) throws {

  let actual = try actual()
  let value = try XCTUnwrap(expected() as? String)
  let expected = try XCTUnwrap(URL(string: value))
  XCTAssertEqual(actual, expected, file: file, line: line)
}
