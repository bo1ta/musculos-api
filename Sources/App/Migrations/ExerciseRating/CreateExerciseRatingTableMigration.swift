//
//  CreateExerciseRatingTableMigration.swift
//  Musculos
//
//  Created by Solomon Alexandru on 23.11.2024.
//

import Fluent
import Vapor

struct CreateExerciseRatingTableMigration: AsyncMigration {
  func prepare(on database: any Database) async throws {
    try await database.schema("exercise_ratings")
      .field("rating_id", .uuid, .identifier(auto: false))
      .field("user_id", .uuid, .required, .references(User.schema, "id", onDelete: .cascade))
      .field("exercise_id", .uuid, .required, .references(Exercise.schema, "id", onDelete: .cascade))
      .field("rating", .double, .required)
      .field("comment", .string)
      .field("is_public", .bool, .required, .sql(.default(true)))
      .create()
  }

  func revert(on database: Database) async throws {
    try await database.schema("exercise_ratings").delete()
  }
}
