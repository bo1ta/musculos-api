//
//  AddExpiresAtAndCreatedAtToTokenMigration.swift
//  
//
//  Created by Solomon Alexandru on 08.09.2024.
//

import Fluent

struct AddExpiresAtAndCreatedAtToTokenMigration: AsyncMigration {
  func prepare(on database: any Database) async throws {
    try await database.schema("tokens")
      .field("created_at", .datetime)
      .field("expires_at", .datetime)
      .update()
  }

  func revert(on database: any Database) async throws {
    try await database.schema("tokens")
      .deleteField("created_at")
      .deleteField("expires_at")
      .update()
  }
}
