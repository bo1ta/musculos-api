//
//  AddImageUrlsToUserMigration.swift
//  
//
//  Created by Solomon Alexandru on 08.09.2024.
//

import Fluent

struct AddImageUrlsToUserMigration: AsyncMigration {
  func prepare(on database: any Database) async throws {
    try await database.schema("users")
      .field("image_urls", .array(of: .string))
      .update()
  }

  func revert(on database: any Database) async throws {
    try await database.schema("users")
      .deleteField("image_urls")
      .update()
  }
}
