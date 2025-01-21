//
//  WorkoutChallenge.swift
//  Musculos
//
//  Created by Solomon Alexandru on 19.01.2025.
//

import Fluent
import Foundation
import Vapor

final class WorkoutChallenge: Model, Content, @unchecked Sendable {
  static let schema = "workout_challenges"

  @ID(key: .id)
  var id: UUID?

  @Field(key: "title")
  var title: String

  @Field(key: "description")
  var description: String

  @Field(key: "level")
  var level: String

  @Field(key: "duration_in_days")
  var durationInDays: Int

  @Field(key: "current_day")
  var currentDay: Int

  @Field(key: "start_date")
  var startDate: Date?

  @Field(key: "completion_date")
  var completionDate: Date?

  @Children(for: \.$workoutChallenge)
  var dailyWorkouts: [DailyWorkout]

  init() { }

  init(
    id: UUID? = nil,
    title: String,
    description: String,
    level: String,
    durationInDays: Int,
    currentDay: Int = 0,
    startDate: Date?,
    completionDate: Date?)
  {
    self.id = id
    self.title = title
    self.description = description
    self.level = level
    self.durationInDays = durationInDays
    self.currentDay = currentDay
    self.startDate = startDate
    self.completionDate = completionDate
  }
}
