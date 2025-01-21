//
//  CreateWorkoutChallengeMigration.swift
//  Musculos
//
//  Created by Solomon Alexandru on 19.01.2025.
//

import Fluent
import Vapor

final class CreateWorkoutChallengeMigration: AsyncMigration {
  func prepare(on database: any Database) async throws {
    try await database.schema(WorkoutChallenge.schema)
      .id()
      .field("title", .string, .required)
      .field("description", .string, .required)
      .field("level", .string, .required)
      .field("duration_in_days", .int, .required)
      .field("current_day", .int, .required)
      .field("start_date", .date)
      .field("completion_date", .date)
      .create()
  }

  func revert(on database: any Database) async throws {
    try await database.schema(WorkoutChallenge.schema)
      .delete()
  }
}
