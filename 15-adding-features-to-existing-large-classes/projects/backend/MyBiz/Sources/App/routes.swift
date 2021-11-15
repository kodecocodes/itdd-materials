import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        return "It works!"
    }

    app.get("hello") { req -> String in
        return "Hello, world!"
    }

  try app.register(collection: AnnouncementsController())
  try app.register(collection: UserController())
  try app.register(collection: EmployeesController())
  try app.register(collection: EventsController())
  try app.register(collection: ProductsController())
  try app.register(collection: PurchasesController())
  try app.register(collection: AnalyticsController())
}
