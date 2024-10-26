//
//  CreateGoalTemplateMigration.swift
//  Musculos
//
//  Created by Solomon Alexandru on 25.10.2024.
//

import Fluent
import Vapor

final class CreateGoalTemplateMigration: AsyncMigration {
  func prepare(on database: any Database) async throws {
    try await database.schema(GoalTemplate.schema)
      .id()
      .field("title", .string, .required)
      .field("description", .string, .required)
      .field("icon_name", .string, .required)
      .create()
  }

  func revert(on database: any Database) async throws {
    try await database.schema(GoalTemplate.schema)
      .delete()
  }
}
