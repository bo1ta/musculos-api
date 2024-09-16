//
//  AddOnboardingFieldsToUserMigration.swift
//  
//
//  Created by Solomon Alexandru on 14.09.2024.
//

import Fluent

struct AddOnboardingFieldsToUserMigration: AsyncMigration {
  func prepare(on database: any Database) async throws {
    try await database.schema(User.schema)
      .field("weight", .double)
      .field("height", .double)
      .field("level", .string)
      .field("primary_goal", .string)
      .field("is_onboarded", .bool, .sql(.default(false)))
      .update()
  }

  func revert(on database: any Database) async throws {
    try await database.schema(User.schema)
      .deleteField("weight")
      .deleteField("height")
      .deleteField("level")
      .deleteField("goal")
      .update()
  }
}
