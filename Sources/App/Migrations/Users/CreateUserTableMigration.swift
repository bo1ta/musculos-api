//
//  CreateUserTableMigration.swift
//
//
//  Created by Solomon Alexandru on 06.05.2024.
//

import Fluent
import Vapor

struct CreateUserTableMigration: AsyncMigration {
  func prepare(on database: any Database) async throws {
    try await database.schema("users")
      .id()
      .field("username", .string, .required)
      .field("email", .string, .required)
      .field("password_hash", .string, .required)
      .field("image_urls", .array(of: .string))
      .field("weight", .double)
      .field("height", .double)
      .field("level", .string)
      .field("primary_goal_id", .uuid)
      .field("is_onboarded", .bool, .sql(.default(false)))
      .unique(on: "email")
      .unique(on: "username")
      .create()
  }

  func revert(on database: any Database) async throws {
    try await database.schema("users").delete()
  }
}
