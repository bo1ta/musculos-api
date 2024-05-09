//
//  File.swift
//  
//
//  Created by Solomon Alexandru on 07.05.2024.
//

import Vapor
import Fluent

struct CreateWorkoutTableMigration: Migration {
  func prepare(on database: any Database) -> EventLoopFuture<Void> {
    return database.schema(Workout.schema)
      .id()
      .field("name", .string, .required)
      .field("target_muscles", .array(of: .string))
      .field("user_id", .uuid, .required, .references(User.schema, "id", onDelete: .cascade))
      .create()
  }
  
  func revert(on database: any Database) -> EventLoopFuture<Void> {
    return database.schema("workouts")
      .delete()
  }
}
