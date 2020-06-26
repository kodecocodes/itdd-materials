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

import UIKit

class DogViewModel {
  
  // MARK: - Static Properties
  static let costFormmater: NumberFormatter = {
    let numberFormmater = NumberFormatter()
    numberFormmater.numberStyle = .decimal
    numberFormmater.maximumFractionDigits = 2
    return numberFormmater
  }()
  
  // MARK: - Instance Properties
  let dog: Dog
  
  let age: String
  let breed: String
  let breederRatingImage: UIImage
  let cost: String
  var created: String
  var imageURL: URL
  var name: String
  
  // MARK: - Object Lifecycle
  init(dog: Dog) {
    self.dog = dog
    self.age = DogViewModel.age(dog)
    self.breed = dog.breed
    self.breederRatingImage = DogViewModel.breederRatingImage(dog)
    self.cost = "$ \(DogViewModel.cost(dog))"
    self.created = DogViewModel.created(dog)
    self.imageURL = dog.imageURL
    self.name = dog.name
  }
  
  private static func breederRatingImage(_ dog: Dog) -> UIImage {
    let name: String
    switch dog.breederRating {
    case    ..<1.5: name = "star_rating_1"
    case 1.5..<2.0: name = "star_rating_1.5"
    case 2.0..<2.5: name = "star_rating_2"
    case 2.5..<3.0: name = "star_rating_2.5"
    case 3.0..<3.5: name = "star_rating_3"
    case 3.5..<4.0: name = "star_rating_3.5"
    case 4.0..<4.5: name = "star_rating_4"
    case 4.5..<5.0: name = "star_rating_4.5"
    case    5.0...: name = "star_rating_5"
    default:        name = "star_rating_1"
    }
    return UIImage(named: name)!
  }
  
  private static func cost(_ dog: Dog) -> String {
    let numberFormmater = NumberFormatter()
    numberFormmater.numberStyle = .decimal
    numberFormmater.maximumFractionDigits = 2
    return costFormmater.string(for: dog.cost)!
  }
  
  private static func created(_ dog: Dog) -> String {
    let format = NSLocalizedString("%@ ago", comment: "Formatted Date: XYZ ago")
    let dateString = self.dateString(dog.created)
    return String(format: format, dateString)
  }
  
  private static func age(_ dog: Dog) -> String {
    let format = NSLocalizedString("%@ old", comment: "Formatted Date String: XYZ old")
    let dateString = self.dateString(dog.birthday)
    return String(format: format, dateString)
  }
  
  private static func dateString(_ date: Date) -> String {
    let calendar = Calendar.current
    let dateFormatter = DateComponentsFormatter()
    dateFormatter.unitsStyle = .full
    dateFormatter.maximumUnitCount = 1
    dateFormatter.calendar = calendar
    let dateComponents = calendar.dateComponents([.year, .month, .weekOfMonth, .day, .hour, .minute, .second],
                                                 from: date, to: Date())
    if let years = dateComponents.year, years > 0 {
      dateFormatter.allowedUnits = [.year]
    } else if let months = dateComponents.month, months > 0 {
      dateFormatter.allowedUnits = [.month]
    } else if let weeks = dateComponents.weekOfMonth, weeks > 0 {
      dateFormatter.allowedUnits = [.weekOfMonth]
    } else if let days = dateComponents.day, days > 0 {
      dateFormatter.allowedUnits = [.day]
    } else if let hours = dateComponents.hour, hours > 0 {
      dateFormatter.allowedUnits = [.hour]
    } else if let minutes = dateComponents.minute, minutes > 0 {
      dateFormatter.allowedUnits = [.minute]
    } else {
      dateFormatter.allowedUnits = [.second]
    }
    return dateFormatter.string(from: date, to: Date())!
  }
  
  // MARK: - Cell Configuration
  func configure(_ cell: ListingTableViewCell) {
    cell.ageLabel.text = age
    cell.breedLabel.text = breed
    cell.createdLabel.text = created
    cell.nameLabel.text = name
    cell.costLabel.text = cost
    cell.breederRatingImageView.image = breederRatingImage
  }
}

// MARK: - Equatable
extension DogViewModel: Equatable {
  static func == (lhs: DogViewModel, rhs: DogViewModel) -> Bool {
    return lhs.dog == rhs.dog
  }
}
