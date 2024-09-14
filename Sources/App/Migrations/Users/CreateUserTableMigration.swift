//
//  CreateUserTableMigration.swift
//
//
//  Created by Solomon Alexandru on 06.05.2024.
//

import Fluent
import Vapor

struct CreateUserTableMigration: AsyncMigration {
  func revert(on database: any Database) async throws {
    try await database.schema("exercises").delete()
  }
  
  func prepare(on database: any Database) async throws {
    try await database.schema("users")
      .id()
      .field("username", .string, .required)
      .field("email", .string, .required)
      .field("password_hash", .string, .required)
      .field("image_urls", .array(of: .string))
      .unique(on: "email")
      .unique(on: "username")
      .create()
  }
}
