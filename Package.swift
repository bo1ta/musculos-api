// swift-tools-version:5.10
import PackageDescription

let package = Package(
  name: "Musculos",
  platforms: [
    .macOS(.v13),
  ],
  dependencies: [
    // 💧 A server-side Swift web framework.
    .package(url: "https://github.com/vapor/vapor.git", from: "4.92.4"),
    // 🗄 An ORM for SQL and NoSQL databases.
    .package(url: "https://github.com/vapor/fluent.git", from: "4.9.0"),
    // 🐘 Fluent driver for Postgres.
    .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.8.0"),
    // 🍃 An expressive, performant, and extensible templating language built for Swift.
    .package(url: "https://github.com/vapor/leaf.git", from: "4.3.0"),
    .package(url: "https://github.com/vapor/jwt.git", from: "5.0.0-beta"),
    .package(url: "https://github.com/vapor/apns.git", from: "4.0.0"),
  ],
  targets: [
    .executableTarget(
      name: "App",
      dependencies: [
        .product(name: "Fluent", package: "fluent"),
        .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
        .product(name: "Leaf", package: "leaf"),
        .product(name: "Vapor", package: "vapor"),
        .product(name: "JWT", package: "jwt"),
        .product(name: "VaporAPNS", package: "apns"),
      ],
      swiftSettings: swiftSettings,
      linkerSettings: [.unsafeFlags(
        [
          "-Xlinker",
          "-interposable",
        ],
        .when(
          platforms: [.macOS],
          configuration: .debug))]),
    .testTarget(
      name: "AppTests",
      dependencies: [
        .target(name: "App"),
        .product(name: "XCTVapor", package: "vapor"),
      ],
      swiftSettings: swiftSettings),
  ])

var swiftSettings: [SwiftSetting] { [
  .enableUpcomingFeature("DisableOutwardActorInference"),
  .enableExperimentalFeature("StrictConcurrency"),
] }
