//
//  CreateWorkoutExerciseTableMigration.swift
//
//
//  Created by Solomon Alexandru on 07.05.2024.
//

import Vapor
import Fluent

struct CreateWorkoutExerciseTableMigration: Migration {
  func prepare(on database: any Database) -> EventLoopFuture<Void> {
    return database.schema(WorkoutExercise.schema)
      .id()
      .field("number_of_reps", .int, .required)
      .field("workout_id", .uuid, .references(Workout.schema, "id"), .required)
      .field("exercise_id", .uuid, .references(Exercise.schema, "id", onDelete: .cascade), .required)
      .create()
  }
  
  func revert(on database: any Database) -> EventLoopFuture<Void> {
    return database.schema(WorkoutExercise.schema)
      .delete()
  }
}
