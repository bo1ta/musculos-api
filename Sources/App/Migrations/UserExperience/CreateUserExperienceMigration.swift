//
//  CreateUserExperienceMigration.swift
//  Musculos
//
//  Created by Solomon Alexandru on 15.12.2024.
//

import Fluent
import Foundation
import Vapor

final class CreateUserExperienceMigration: AsyncMigration {
  func prepare(on database: any Database) async throws {
    try await database.schema(UserExperience.schema)
      .id()
      .field("user_id", .uuid, .required, .references(User.schema, "id", onDelete: .cascade))
      .field("total_experience", .int, .required, .sql(.default(0)))
      .create()
  }

  func revert(on database: any Database) async throws {
    try await database.schema(UserExperience.schema).delete()
  }
}
