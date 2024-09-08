//
//  AddPasswordHashToUserMigration.swift
//  
//
//  Created by Solomon Alexandru on 07.09.2024.
//

import Fluent

struct AddPasswordHashToUserMigration: AsyncMigration {
  func prepare(on database: any Database) async throws {
    try await database.schema("users")
      .field("password_hash", .string, .required, .sql(.default("Your default value")))
      .update()
  }

  func revert(on database: any Database) async throws {
    try await database.schema("users")
      .deleteField("password_hash")
      .update()
  }
}
