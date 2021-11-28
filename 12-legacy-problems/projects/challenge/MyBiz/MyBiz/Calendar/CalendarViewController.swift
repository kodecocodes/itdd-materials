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

import UIKit

class CalendarViewController: UIViewController {
  @IBOutlet weak var calendarView: JTAppleCalendarView!

  var api: API = UIApplication.appDelegate.api
  var model: CalendarModel!
  var events: [Event] = []

  override func viewDidLoad() {
    super.viewDidLoad()
    calendarView.scrollingMode = .stopAtEachCalendarFrame
    model = CalendarModel(api: api)
  }

  func loadEvents() {
    model.getAll { [weak self] result in
      switch result {
      case .success(let events):
        self?.events = events
        self?.calendarView.reloadData()
      case .failure(let error):
        self?.showAlert(title: "Could not load events", subtitle: error.localizedDescription)
      }
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    loadEvents()
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard segue.identifier == "dayDetails",
      let state = sender as? CellState,
      let destination = segue.destination as? DayDetailTableViewController else {
        return
    }

    let daysEvents = events.filter { Calendar.current.isDate(state.date, equalTo: $0.date, toGranularity: .day) }
    destination.events = daysEvents
  }
}

extension CalendarViewController: JTAppleCalendarViewDataSource {
  func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
    let startDate = Date(timeIntervalSinceNow: -.days(60))
    let endDate = Date(timeIntervalSinceNow: .days(90))
    let firstDayOfWeek = AppDelegate.configuration.firstDayOfWeek
    return ConfigurationParameters(startDate: startDate, endDate: endDate, firstDayOfWeek: firstDayOfWeek)
  }
}

extension CalendarViewController: JTAppleCalendarViewDelegate {
  func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
    let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "dateCell", for: indexPath) as! CalendarCell
    configureCell(view: cell, cellState: cellState)
    return cell
  }

  func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
    configureCell(view: cell, cellState: cellState)
  }

  func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
    let hasEvent = events.contains { event in
      Calendar.current.isDate(cellState.date, equalTo: event.date, toGranularity: .day)
    }

    guard hasEvent else { return }
    performSegue(withIdentifier: "dayDetails", sender: cellState)
  }

  func configureCell(view: JTAppleCell?, cellState: CellState) {
    guard let cell = view as? CalendarCell  else { return }
    cell.dateLabel.text = cellState.text
    let components = Calendar.current.dateComponents([.month, .day], from: cellState.date)
    if components.day == 1 && cellState.dateBelongsTo == .thisMonth {
      let formatter = DateFormatter()
      formatter.dateFormat = "MMMM"
      cell.monthName = formatter.string(from: cellState.date)
    } else {
      cell.monthName = nil
    }
    handleCellTextColor(cell: cell, cellState: cellState)
    handleCellEvents(cell: cell, cellState: cellState)
  }

  func handleCellTextColor(cell: CalendarCell, cellState: CellState) {
    if cellState.dateBelongsTo == .thisMonth {
      cell.dateLabel.textColor = UIColor.black
    } else {
      cell.dateLabel.textColor = UIColor.gray
    }
  }

  func handleCellEvents(cell: CalendarCell, cellState: CellState) {
    let hasEvent = events.contains { event in
      Calendar.current.isDate(cellState.date, equalTo: event.date, toGranularity: .day)
    }
    cell.hasEvent = hasEvent
  }
}
