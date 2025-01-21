//
//  DailyWorkout.swift
//  Musculos
//
//  Created by Solomon Alexandru on 19.01.2025.
//

import Fluent
import Foundation
import Vapor

final class DailyWorkout: Model, Content, @unchecked Sendable {
  static let schema = "daily_workouts"

  @ID(key: .id)
  var id: UUID?

  @Field(key: "day_number")
  var dayNumber: Int

  @Children(for: \.$dailyWorkout)
  var workoutExercises: [WorkoutExercise]

  @Parent(key: "workout_challenge_id")
  var workoutChallenge: WorkoutChallenge

  @Field(key: "is_rest_day")
  var isRestDay: Bool

  init() { }

  init(id: UUID? = nil, workoutChallengeID: WorkoutChallenge.IDValue, dayNumber: Int, isRestDay: Bool) {
    self.id = id
    self.$workoutChallenge.id = workoutChallengeID
    self.dayNumber = dayNumber
    self.isRestDay = isRestDay
  }
}
