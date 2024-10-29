//
//  CreateGoalTableMigration.swift
//  Musculos
//
//  Created by Solomon Alexandru on 25.10.2024.
//

import Vapor
import Fluent

final class CreateGoalTableMigration: AsyncMigration {
  func prepare(on database: any Database) async throws {
    try await database.schema(Goal.schema)
      .field("goal_id", .uuid, .identifier(auto: false))
      .field("user_id", .uuid, .required, .references(User.schema, "id", onDelete: .cascade))
      .field("name", .string, .required)
      .field("frequency", .string, .required)
      .field("date_added", .date, .required)
      .field("category", .string)
      .field("end_date", .date)
      .field("is_completed", .bool, .required, .sql(.default(false)))
      .field("target_value", .int, .required)
      .create()
  }

  func revert(on database: any Database) async throws {
    try await database.schema(Goal.schema)
      .delete()
  }
}
