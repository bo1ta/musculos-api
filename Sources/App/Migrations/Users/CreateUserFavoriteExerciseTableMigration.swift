//
//  File.swift
//
//
//  Created by Solomon Alexandru on 12.09.2024.
//

import Fluent

struct CreateUserFavoriteExerciseTableMigration: AsyncMigration {
  func prepare(on database: Database) async throws {
    try await database.schema("user_favorite_exercises")
      .id()
      .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
      .field("exercise_id", .uuid, .required, .references("exercises", "id", onDelete: .cascade))
      .create()
  }

  func revert(on database: any Database) async throws {
    try await database.schema("user_favorite_exercises")
      .delete()
  }
}
