import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
  router.get("hello") { req in
    return "Welcome to MyBiz!"
  }
  
  let eventsController = EventsController()
  let employeesController = EmployeesController()
  let usersController = UsersController()
  let announcementsController = AnnouncementsController()
  let productsControlller = ProductsController()
  let purchasesController = PurchasesController()
  
  try router.register(collection: eventsController)
  try router.register(collection: employeesController)
  try router.register(collection: usersController)
  try router.register(collection: announcementsController)
  try router.register(collection: productsControlller)
  try router.register(collection: purchasesController)
}
