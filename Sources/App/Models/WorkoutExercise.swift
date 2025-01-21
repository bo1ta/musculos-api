//
//  WorkoutExercise.swift
//
//
//  Created by Solomon Alexandru on 07.05.2024.
//

import Fluent
import Vapor

final class WorkoutExercise: Model, Content, @unchecked Sendable {
  static let schema = "workoutExercises"

  @ID(key: .id)
  var id: UUID?

  @Parent(key: "daily_workout_id")
  var dailyWorkout: DailyWorkout

  @Parent(key: "exercise_id")
  var exercise: Exercise

  @Field(key: "number_of_reps")
  var numberOfReps: Int

  @Field(key: "is_completed")
  var isCompleted: Bool

  @Field(key: "min_value")
  var minValue: Int

  @Field(key: "max_value")
  var maxValue: Int

  @Field(key: "measurement")
  var measurement: String

  init() { }

  init(
    id: UUID? = nil,
    dailyWorkoutID: DailyWorkout.IDValue,
    exerciseID: Exercise.IDValue,
    numberOfReps: Int,
    isCompleted: Bool,
    minValue: Int,
    maxValue: Int,
    measurement: String)
  {
    self.id = id
    self.$dailyWorkout.id = dailyWorkoutID
    self.$exercise.id = exerciseID
    self.numberOfReps = numberOfReps
    self.isCompleted = isCompleted
    self.minValue = minValue
    self.maxValue = maxValue
    self.measurement = measurement
  }
}
