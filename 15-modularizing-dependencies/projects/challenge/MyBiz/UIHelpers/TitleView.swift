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
import UIKit

class TitleView: UIView {
  var title: String = "Welcome to MyBiz!" {
    didSet {
      setNeedsDisplay()
    }
  }

  override func draw(_ rect: CGRect) {
    super.draw(rect)
    let side = min((rect.height - 20) / 2.0, 100.0)
    let y = (rect.height - side * 1.5) / 2.0
    let redRect = CGRect(x: 12, y: y, width: side, height: side)
    let blueRect = CGRect(
      x: redRect.minX + side * 0.25,
      y: redRect.minY + side * 0.25,
      width: side,
      height: side).integral
    let yellowRect = CGRect(
      x: blueRect.minX + side * 0.25,
      y: blueRect.minY + side * 0.25,
      width: side,
      height: side).integral

    UIColor.white.setStroke()
    let lineWidth: CGFloat = 2

    let yellow = UIBezierPath(rect: yellowRect)
    yellow.lineWidth = lineWidth
    UIColor.bizYellow.setFill()
    yellow.fill()
    yellow.stroke()

    let blue = UIBezierPath(rect: blueRect)
    blue.lineWidth = lineWidth
    UIColor.bizPurple.setFill()
    blue.fill()
    blue.stroke()

    let red = UIBezierPath(rect: redRect)
    red.lineWidth = lineWidth
    UIColor.bizPink.setFill()
    red.fill()
    red.stroke()

    let textX = yellowRect.maxX + 8
    let textHeight: CGFloat = 32
    let textY = (rect.height - textHeight) / 2.0
    let textWidth = rect.width - textX
    let titleRect = CGRect(x: textX, y: textY, width: textWidth, height: textHeight)
    let font = UIFont.preferredFont(forTextStyle: .title1)
    (title as NSString).draw(in: titleRect, withAttributes: [NSAttributedString.Key.font: font])
  }
}
