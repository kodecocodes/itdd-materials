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

@testable import DogPatch
import XCTest

class DogViewModelTests: XCTestCase {
 
  // MARK: - Instance Properties
  var cell: ListingTableViewCell!
  var dog: Dog!
  var sut: DogViewModel!
  
  // MARK: - Test Lifecycle
  override func setUp() {
    super.setUp()
    whenSUTSetFromDog()
  }
  
  override func tearDown() {
    dog = nil
    sut = nil
    super.tearDown()
  }
  
  // MARK: - Given
  func givenListingsTableViewCell() {
    let viewController = ListingsViewController.instanceFromStoryboard()
    viewController.loadViewIfNeeded()
    
    let tableView = viewController.tableView!
    cell = tableView.dequeueReusableCell(withIdentifier: ListingTableViewCell.identifier) as? ListingTableViewCell
  }
  
  // MARK: - When
  func whenConfigureListingsTableViewCell() {
    givenListingsTableViewCell()
    sut.configure(cell)
  }
  
  func whenSUTSetFromDog(id: String = "id",
                         sellerID: String = "sellerID",
                         about: String = "about",
                         birthday: Date = Date(timeIntervalSinceNow: -31536000) /* ~1 year*/,
                         breed: String = "breed",
                         breederRating: Double = 3.0,
                         cost: Decimal = 42.0,
                         created: Date = Date(timeIntervalSinceNow: -42.0),
                         imageURL: URL = URL(string: "http://example.com")!,
                         name: String = "name") {
    
    dog = Dog(id: id,
              sellerID: sellerID,
              about: about,
              birthday: birthday,
              breed: breed,
              breederRating: breederRating,
              cost: cost,
              created: created,
              imageURL: imageURL,
              name: name)
    
    sut = DogViewModel(dog: dog)
  }
      
  // MARK: - Init - Tests
  func test_initDog_setsDog() {
    XCTAssertEqual(sut.dog, dog)
  }
  
  func test_initDog_given1YearOld_setsAge() {  
    // when
    whenSUTSetFromDog(birthday: 1.year.pastDate)
    
    // then
    XCTAssertEqual(sut.age, "1 year old")
  }
  
  func test_initDog_given2YearsOld_setsAge() {
    // when
    whenSUTSetFromDog(birthday: 2.years.pastDate)
    
    // then
    XCTAssertEqual(sut.age, "2 years old")
  }
  
  func test_initDog_given1MonthOld_setsAge() {
    // when
    whenSUTSetFromDog(birthday: 1.month.pastDate)
    
    // then
    XCTAssertEqual(sut.age, "1 month old")
  }
  
  func test_initDog_given2MonthsOld_setsAge() {
    // when
    whenSUTSetFromDog(birthday: 2.months.pastDate)
    
    // then
    XCTAssertEqual(sut.age, "2 months old")
  }
  
  func test_initDog_given1WeekOld_setsAge() {
    // when
    whenSUTSetFromDog(birthday: 1.week.pastDate)
    
    // then
    XCTAssertEqual(sut.age, "1 week old")
  }
  
  func test_initDog_given2WeeksOld_setsAge() {
    // when
    whenSUTSetFromDog(birthday: 2.weeks.pastDate)
    
    // then
    XCTAssertEqual(sut.age, "2 weeks old")
  }
  
  func test_initDog_given1DayOld_setsAge() {
    // when
    whenSUTSetFromDog(birthday: 1.day.pastDate)
    
    // then
    XCTAssertEqual(sut.age, "1 day old")
  }
  
  func test_initDog_given2DaysOld_setsAge() {
    // when
    whenSUTSetFromDog(birthday: 2.days.pastDate)
    
    // then
    XCTAssertEqual(sut.age, "2 days old")
  }
  
  func test_initDog_given1HourOld_setsAge() {
    // when
    whenSUTSetFromDog(birthday: 1.hour.pastDate)
    
    // then
    XCTAssertEqual(sut.age, "1 hour old")
  }
  
  func test_initDog_given2HoursOld_setsAge() {
    // when
    whenSUTSetFromDog(birthday: 2.hour.pastDate)
    
    // then
    XCTAssertEqual(sut.age, "2 hours old")
  }
  
  func test_initDog_given1MinuteOld_setsAge() {
    // when
    whenSUTSetFromDog(birthday: 1.minute.pastDate)
    
    // then
    XCTAssertEqual(sut.age, "1 minute old")
  }
  
  func test_initDog_given2MinutesOld_setsAge() {
    // when
    whenSUTSetFromDog(birthday: 2.minutes.pastDate)
    
    // then
    XCTAssertEqual(sut.age, "2 minutes old")
  }
  
  func test_initDog_given1SecondOld_setsAge() {
    // when
    whenSUTSetFromDog(birthday: 1.second.pastDate)
    
    // then
    XCTAssertEqual(sut.age, "1 second old")
  }
  
  func test_initDog_given2SecondsOld_setsAge() {
    // when
    whenSUTSetFromDog(birthday: 2.seconds.pastDate)
    
    // then
    XCTAssertEqual(sut.age, "2 seconds old")
  }
  
  func test_initDog_setsBreed() {
    XCTAssertEqual(sut.breed, dog.breed)
  }
  
  func test_initDog_givenBreederRatingLessThan1Point5_setsBreederRatingImage() {
    // given
    whenSUTSetFromDog(breederRating: 1.49)
    
    // then
    XCTAssertEqual(sut.breederRatingImage, UIImage(named: "star_rating_1")!)
  }
  
  func test_initDog_givenBreederRatingBetween_1Point5To2_setsBreederRatingImage() {
    // given
    whenSUTSetFromDog(breederRating: 1.99)
    
    // then
    XCTAssertEqual(sut.breederRatingImage, UIImage(named: "star_rating_1.5")!)
  }
  
  func test_initDog_givenBreederRatingBetween_2To2Point5_setsBreederRatingImage() {
    // given
    whenSUTSetFromDog(breederRating: 2.49)
    
    // then
    XCTAssertEqual(sut.breederRatingImage, UIImage(named: "star_rating_2")!)
  }
  
  func test_initDog_givenBreederRatingBetween_2Point5To3_setsBreederRatingImage() {
    // given
    whenSUTSetFromDog(breederRating: 2.99)
    
    // then
    XCTAssertEqual(sut.breederRatingImage, UIImage(named: "star_rating_2.5")!)
  }
  
  func test_initDog_givenBreederRatingBetween_3To3Point5_setsBreederRatingImage() {
    // given
    whenSUTSetFromDog(breederRating: 3.49)
    
    // then
    XCTAssertEqual(sut.breederRatingImage, UIImage(named: "star_rating_3")!)
  }
  
  func test_initDog_givenBreederRatingBetween_3Point5To4_setsBreederRatingImage() {
    // given
    whenSUTSetFromDog(breederRating: 3.99)
    
    // then
    XCTAssertEqual(sut.breederRatingImage, UIImage(named: "star_rating_3.5")!)
  }
  
  func test_initDog_givenBreederRatingBetween_4To4Point5_setsBreederRatingImage() {
    // given
    whenSUTSetFromDog(breederRating: 4.49)
    
    // then
    XCTAssertEqual(sut.breederRatingImage, UIImage(named: "star_rating_4")!)
  }
  
  func test_initDog_givenBreederRatingBetween_4Point5To5_setsBreederRatingImage() {
    // given
    whenSUTSetFromDog(breederRating: 4.99)
    
    // then
    XCTAssertEqual(sut.breederRatingImage, UIImage(named: "star_rating_4.5")!)
  }
  
  func test_initDog_givenBreederRatingEqualTo5_setsBreederRatingImage() {
    // given
    whenSUTSetFromDog(breederRating: 5.0)
    
    // then
    XCTAssertEqual(sut.breederRatingImage, UIImage(named: "star_rating_5")!)
  }
  
  func test_initDog_givenBreederRatingGreaterThan5_setsBreederRatingImage() {
    // given
    whenSUTSetFromDog(breederRating: 5.1)
    
    // then
    XCTAssertEqual(sut.breederRatingImage, UIImage(named: "star_rating_5")!)
  }
  
  func test_initDog_setsCost() {
    // when
    whenSUTSetFromDog(cost: 42.42)
    
    // when
    XCTAssertEqual(sut.cost, "$ 42.42")
  }
  
  func test_initDog_givenCreated1YearAgo_setsCreated() {
    // given
    whenSUTSetFromDog(created: 1.year.pastDate)
    
    // then
    XCTAssertEqual(sut.created, "1 year ago")
  }
  
  func test_initDog_givenCreated2YearsAgo_setsCreated() {
    // given
    whenSUTSetFromDog(created: 2.year.pastDate)
    
    // then
    XCTAssertEqual(sut.created, "2 years ago")
  }
  
  func test_initDog_givenCreated1MonthAgo_setsCreated() {
    // given
    whenSUTSetFromDog(created: 1.month.pastDate)
    
    // then
    XCTAssertEqual(sut.created, "1 month ago")
  }
  
  func test_initDog_givenCreated2MonthsAgo_setsCreated() {
    // given
    whenSUTSetFromDog(created: 2.months.pastDate)
    
    // then
    XCTAssertEqual(sut.created, "2 months ago")
  }
  
  func test_initDog_givenCreated1WeekAgo_setsCreated() {
    // given
    whenSUTSetFromDog(created: 1.week.pastDate)
    
    // then
    XCTAssertEqual(sut.created, "1 week ago")
  }
  
  func test_initDog_givenCreated2WeeksAgo_setsCreated() {
    // given
    whenSUTSetFromDog(created: 2.weeks.pastDate)
    
    // then
    XCTAssertEqual(sut.created, "2 weeks ago")
  }
  
  func test_initDog_givenCreated1DayAgo_setsCreated() {
    // given
    whenSUTSetFromDog(created: 1.day.pastDate)
    
    // then
    XCTAssertEqual(sut.created, "1 day ago")
  }
  
  func test_initDog_givenCreated2DaysAgo_setsCreated() {
    // given
    whenSUTSetFromDog(created: 2.days.pastDate)
    
    // then
    XCTAssertEqual(sut.created, "2 days ago")
  }
  
  func test_initDog_givenCreated1HourAgo_setsCreated() {
    // given
    whenSUTSetFromDog(created: 1.hour.pastDate)
    
    // then
    XCTAssertEqual(sut.created, "1 hour ago")
  }
  
  func test_initDog_givenCreated2HoursAgo_setsCreated() {
    // given
    whenSUTSetFromDog(created: 2.hours.pastDate)
    
    // then
    XCTAssertEqual(sut.created, "2 hours ago")
  }
  
  func test_initDog_givenCreated1MinuteAgo_setsCreated() {
    // given
    whenSUTSetFromDog(created: 1.minute.pastDate)
    
    // then
    XCTAssertEqual(sut.created, "1 minute ago")
  }
  
  func test_initDog_givenCreated2MinutesAgo_setsCreated() {
    // given
    whenSUTSetFromDog(created: 2.minutes.pastDate)
    
    // then
    XCTAssertEqual(sut.created, "2 minutes ago")
  }
  
  func test_initDog_givenCreated1SecondAgo_setsCreated() {
    // given
    whenSUTSetFromDog(created: 1.second.pastDate)
    
    // then
    XCTAssertEqual(sut.created, "1 second ago")
  }
  
  func test_initDog_givenCreated2SecondsAgo_setsCreated() {
    // given
    whenSUTSetFromDog(created: 2.seconds.pastDate)
    
    // then
    XCTAssertEqual(sut.created, "2 seconds ago")
  }
  
  func test_initDog_setsImageURL() {
    XCTAssertEqual(sut.imageURL, dog.imageURL)
  }
  
  func test_initDog_setsName() {
    XCTAssertEqual(sut.name, dog.name)
  }
  
  // MARK: - Cell Configuration - Tests
  func test_configureCell_setsAgeLabelText() {
    // when
    whenConfigureListingsTableViewCell()
    
    // then
    XCTAssertEqual(cell.ageLabel.text, sut.age)
  }
  
  func test_configureCell_setsBreedLabelText() {
    // when
    whenConfigureListingsTableViewCell()
    
    // then
    XCTAssertEqual(cell.breedLabel.text, sut.breed)
  }
  
  func test_configureCell_setsCreatedLabelText() {
    // when
    whenConfigureListingsTableViewCell()
    
    // then
    XCTAssertEqual(cell.createdLabel.text, sut.created)
  }
  
  func test_configureCell_setsNameLabelText() {
    // when
    whenConfigureListingsTableViewCell()
    
    // then
    XCTAssertEqual(cell.nameLabel.text, sut.name)
  }
  
  func test_configureCell_setsCostLabelText() {
    // when
    whenConfigureListingsTableViewCell()
    
    // then
    XCTAssertEqual(cell.costLabel.text, sut.cost)
  }
  
  func test_configureCell_setsBreederRatingImageViewImage() {
    // when
    whenConfigureListingsTableViewCell()
    
    // then
    XCTAssertEqual(cell.breederRatingImageView.image, sut.breederRatingImage)
  }
}
