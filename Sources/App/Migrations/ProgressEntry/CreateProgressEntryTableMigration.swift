//
//  CreateProgressEntryTableMigration.swift
//  Musculos
//
//  Created by Solomon Alexandru on 26.10.2024.
//

import Fluent
import Vapor

final class CreateProgressEntryTableMigration: AsyncMigration {
  func prepare(on database: any Database) async throws {
    try await database.schema(ProgressEntry.schema)
      .field("entry_id", .uuid, .identifier(auto: false))
      .field("date_added", .date, .required)
      .field("value", .double, .required)
      .field("goal_id", .uuid, .required, .references(Goal.schema, "goal_id", onDelete: .cascade))
      .create()
  }

  func revert(on database: any Database) async throws {
    try await database.schema(ProgressEntry.schema)
      .delete()
  }
}
