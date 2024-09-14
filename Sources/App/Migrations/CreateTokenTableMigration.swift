//
//  File.swift
//  
//
//  Created by Solomon Alexandru on 07.05.2024.
//

import Fluent
import Vapor

struct CreateTokenTableMigration: AsyncMigration {
  func prepare(on database: any Database) async throws {
    try await database.schema("tokens")
      .id()
      .field("token_value", .string, .required)
      .field("user_id", .uuid, .required, .references(User.schema, "id", onDelete: .cascade))
      .field("created_at", .datetime)
      .field("expires_at", .datetime)
      .create()
  }
  
  func revert(on database: any Database) async throws {
    try await database.schema("tokens")
      .delete()
  }
}
