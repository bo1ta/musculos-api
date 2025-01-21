//
//  File.swift
//
//
//  Created by Solomon Alexandru on 07.05.2024.
//

import Fluent
import Vapor

// struct CreateWorkoutTableMigration: AsyncMigration {
//  func prepare(on database: any Database) async throws {
//    return try await database.schema(Workout.schema)
//      .id()
//      .field("name", .string, .required)
//      .field("target_muscles", .array(of: .string))
//      .field("user_id", .uuid, .required, .references(User.schema, "id", onDelete: .cascade))
//      .create()
//  }
//
//  func revert(on database: any Database) async throws {
//    return try await database.schema(Workout.schema)
//      .delete()
//  }
// }
