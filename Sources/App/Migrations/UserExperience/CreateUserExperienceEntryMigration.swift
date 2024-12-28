//
//  CreateUserExperienceEntryMigration.swift
//  Musculos
//
//  Created by Solomon Alexandru on 15.12.2024.
//

import Vapor
import Fluent

struct CreateUserExperienceEntryMigration: AsyncMigration {
  func prepare(on database: any Database) async throws {
    return try await database.schema(UserExperienceEntry.schema)
      .id()
      .field("user_experience_id", .uuid, .required, .references(UserExperience.schema, "id", onDelete: .cascade))
      .field("exercise_session_id", .uuid, .required, .references(ExerciseSession.schema, "session_id", onDelete: .cascade))
      .field("xp_gained", .int, .required, .sql(.default(0)))
      .create()
  }

  func revert(on database: any Database) async throws {
    return try await database.schema(UserExperienceEntry.schema).delete()
  }
}
