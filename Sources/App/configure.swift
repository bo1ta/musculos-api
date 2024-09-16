import NIOSSL
import Fluent
import FluentPostgresDriver
import Leaf
import Vapor
import JWT

public func configure(_ app: Application) async throws {
  // uncomment to serve files from /Public folder
  // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

#if DEBUG && os(macOS)
  Bundle(path: "/Applications/InjectionIII.app/Contents/Resources/macOSInjection.bundle")?.load()
#endif

  app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
    hostname: Environment.get("DATABASE_HOST") ?? "postgres",
    port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
    username: Environment.get("DATABASE_USERNAME") ?? "postgres",
    password: Environment.get("DATABASE_PASSWORD") ?? "password",
    database: Environment.get("DATABASE_NAME") ?? "exercises",
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
    .add(CreateWorkoutTableMigration())
  app.migrations
    .add(CreateWorkoutExerciseTableMigration())
  app.migrations
    .add(PopulateExercisesMigration(resourcesDirectory: app.directory.resourcesDirectory))
  app.migrations
    .add(PopulateImageUrlsToExercisesMigration())
  app.migrations
    .add(CreateUserFavoriteExerciseTableMigration())
  app.migrations.add(AddOnboardingFieldsToUserMigration())

  try await app.autoMigrate()
}
