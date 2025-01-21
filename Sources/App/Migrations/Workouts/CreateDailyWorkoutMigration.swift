//
//  CreateDailyWorkoutMigration.swift
//  Musculos
//
//  Created by Solomon Alexandru on 19.01.2025.
//

import Fluent
import Vapor

final class CreateDailyWorkoutMigration: AsyncMigration {
  func prepare(on database: any Database) async throws {
    try await database.schema(DailyWorkout.schema)
      .id()
      .field("workout_challenge_id", .uuid, .required, .references(WorkoutChallenge.schema, "id", onDelete: .cascade))
      .field("day_number", .int, .required, .sql(.default(0)))
      .field("is_rest_day", .bool, .required, .sql(.default(false)))
      .create()
  }

  func revert(on database: any Database) async throws {
    try await database.schema(DailyWorkout.schema)
      .delete()
  }
}
