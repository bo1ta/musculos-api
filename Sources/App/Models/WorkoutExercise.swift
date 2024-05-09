//
//  WorkoutExercise.swift
//
//
//  Created by Solomon Alexandru on 07.05.2024.
//

import Vapor
import Fluent

final class WorkoutExercise: Model, Content, @unchecked Sendable {
  static let schema: String = "workoutExercises"
  
  @ID(key: .id)
  var id: UUID?
  
  @Parent(key: "workout_id")
  var workout: Workout
  
  @Parent(key: "exercise_id")
  var exercise: Exercise
  
  @Field(key: "number_of_reps")
  var numberOfReps: Int
  
  init() { }
  
  init(id: UUID? = nil, workoutID: Workout.IDValue, exerciseID: Exercise.IDValue, numberOfReps: Int) {
    self.id = id
    self.$workout.id = workoutID
    self.$exercise.id = exerciseID
    self.numberOfReps = numberOfReps
  }
}
