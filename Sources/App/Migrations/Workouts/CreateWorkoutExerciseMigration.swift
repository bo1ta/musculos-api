//
//  CreateWorkoutExerciseMigration.swift
//
//
//  Created by Solomon Alexandru on 07.05.2024.
//

import Fluent
import Vapor

final class CreateWorkoutExerciseMigration: AsyncMigration {
  func prepare(on database: any Database) async throws {
    try await database.schema(WorkoutExercise.schema)
      .id()
      .field("daily_workout_id", .uuid, .required, .references(DailyWorkout.schema, "id", onDelete: .cascade))
      .field("exercise_id", .uuid, .required, .references(Exercise.schema, "id", onDelete: .cascade))
      .field("number_of_reps", .int, .required)
      .field("is_completed", .bool, .required, .sql(.default(false)))
      .field("min_value", .int, .required)
      .field("max_value", .int, .required)
      .field("measurement", .string, .required)
      .create()
  }

  func revert(on database: any Database) async throws {
    try await database.schema(WorkoutExercise.schema)
      .delete()
  }
}
