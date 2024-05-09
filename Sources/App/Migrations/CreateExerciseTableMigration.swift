//
//  CreateExerciseTableMigration.swift
//
//
//  Created by Solomon Alexandru on 06.05.2024.
//

import Fluent
import Vapor
import SQLKit

struct CreateExerciseTableMigration: AsyncMigration {
  func prepare(on database: any Database) async throws {
    try await database.schema("exercises")
      .id()
      .field("name", .string, .required)
      .field("instructions", .array(of: .string), .required)
      .field("date_created", .datetime, .required)
      .field("date_updated", .datetime)
      .field("image_urls", .array(of: .string))
      .field("category", .string, .required)
      .field("primary_muscles", .array(of: .string), .required)
      .field("secondary_muscles", .array(of: .string), .required)
      .field("force", .string)
      .field("equipment", .string)
      .field("mechanic", .string)
      .field("level", .string)
      .create()
  }
  
  func revert(on database: any Database) async throws {
    try await database.schema("exercises").delete()
  }
}
