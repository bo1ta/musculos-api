import NIOSSL
import Fluent
import FluentPostgresDriver
import Leaf
import Vapor
import JWT

public func configure(_ app: Application) async throws {
  // uncomment to serve files from /Public folder
  // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

  app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
    hostname: Environment.get("DATABASE_HOST") ?? "localhost",
    port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
    username: Environment.get("DATABASE_USERNAME") ?? "postgres",
    password: Environment.get("DATABASE_PASSWORD") ?? "",
    database: Environment.get("DATABASE_NAME") ?? "exercisedb",
    tls: .prefer(try .init(configuration: .clientDefault)))
  ), as: .psql)
  
  await app.jwt.keys.add(hmac: .init(stringLiteral: "secret"), digestAlgorithm: .sha256)
  
  try await setupMigrationConfiguration(app)

  app.views.use(.leaf)
  try routes(app)
}

fileprivate func setupMigrationConfiguration(_ app: Application) async throws {
  app.migrations
    .add(CreateExerciseTableMigration())
  app.migrations
    .add(CreateUserTableMigration())
  app.migrations
    .add(CreateTokenTableMigration())
  app.migrations
    .add(AddExpiresAtAndCreatedAtToTokenMigration())
//  app.migrations
//    .add(AddPasswordHashToUserMigration())
  app.migrations
    .add(CreateWorkoutTableMigration())
  app.migrations
    .add(CreateWorkoutExerciseTableMigration())
    app.migrations
        .add(PopulateExercisesMigration(resourcesDirectory: app.directory.resourcesDirectory))

  try await app.autoMigrate()
}
