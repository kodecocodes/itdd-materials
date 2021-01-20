// swift-tools-version:4.0
import PackageDescription

let package = Package(
  name: "MyBiz",
  products: [
    .library(name: "MyBiz", targets: ["App"]),
  ],
  dependencies: [
    // 💧 A server-side Swift web framework.
    .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
    
    // 🔵 Swift ORM (queries, models, relations, etc) built on SQLite 3.
    .package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0"),
    // 👤 Authentication and Authorization framework for Fluent.
    .package(url: "https://github.com/vapor/auth.git", from: "2.0.0")
  ],
  targets: [
    .target(name: "App", dependencies: ["FluentSQLite", "Authentication", "Vapor"]),
    .target(name: "Run", dependencies: ["App"]),
  ]
)

