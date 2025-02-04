import APNS
import APNSCore
import Fluent
import FluentPostgresDriver
import JWT
import Leaf
import NIOSSL
import Vapor
import VaporAPNS

public func configure(_ app: Application) async throws {
  try setupDatabase(app)
  setupMiddlewares(app)

  await app.jwt.keys.add(hmac: .init(stringLiteral: "secret"), digestAlgorithm: .sha256)

  try await setupMigrationConfiguration(app)

  try routes(app)
}

private func setupMiddlewares(_ app: Application) {
  app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
}

private func setupDatabase(_ app: Application) throws {
  app.databases.use(DatabaseConfigurationFactory.postgres(
    configuration: .init(
      hostname: Environment.get("DATABASE_HOST") ?? "postgres",
      port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
      username: Environment.get("DATABASE_USERNAME") ?? "postgres",
      password: Environment.get("DATABASE_PASSWORD") ?? "password",
      database: Environment.get("DATABASE_NAME") ?? "exercises",
      tls: .prefer(try .init(configuration: .clientDefault)))), as: .psql)
}

private func setupMigrationConfiguration(_ app: Application) async throws {
  // MARK: User migrations

  app.migrations
    .add(CreateUserTableMigration())
  app.migrations
    .add(CreateTokenTableMigration())
  app.migrations
    .add(CreateUserExperienceMigration())

  // MARK: Exercise migrations

  app.migrations
    .add(CreateExerciseTableMigration())
  app.migrations
    .add(PopulateExercisesMigration(resourcesDirectory: app.directory.resourcesDirectory))
  app.migrations
    .add(PopulateImageUrlsToExercisesMigration())
  app.migrations
    .add(CreateUserFavoriteExerciseTableMigration())
  app.migrations
    .add(CreateExerciseSessionTableMigration())
  app.migrations
    .add(CreateExerciseRatingTableMigration())
  app.migrations
    .add(CreateUserExperienceEntryMigration())

  // MARK: Goal migrations

  app.migrations
    .add(CreateGoalTableMigration())
  app.migrations
    .add(CreateGoalTemplateMigration())
  app.migrations
    .add(SeedGoalTemplatesMigration())
  app.migrations
    .add(CreateProgressEntryTableMigration())

  // MARK: Workout migrations

  app.migrations
    .add(CreateWorkoutChallengeMigration())
  app.migrations
    .add(CreateDailyWorkoutMigration())
  app.migrations
    .add(CreateWorkoutExerciseMigration())

  try await app.autoMigrate()
}
