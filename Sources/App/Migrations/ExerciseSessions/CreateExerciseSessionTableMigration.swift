//
//  File.swift
//  Musculos
//
//  Created by Solomon Alexandru on 12.10.2024.
//

import Vapor
import Fluent

struct CreateExerciseSessionTableMigration: AsyncMigration {
  func prepare(on database: any Database) async throws {
    return try await database.schema(ExerciseSession.schema)
      .field("session_id", .uuid, .identifier(auto: false))
      .field("date_added", .date, .required)
      .field("duration", .double, .required)
      .field("user_id", .uuid, .required, .references(User.schema, "id", onDelete: .cascade))
      .field("exercise_id", .uuid, .required, .references(Exercise.schema, "id", onDelete: .cascade))
      .create()
  }

  func revert(on database: any Database) async throws {
    return try await database.schema(ExerciseSession.schema)
      .delete()
  }
}
