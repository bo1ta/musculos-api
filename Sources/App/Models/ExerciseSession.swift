//
//  ExerciseSession.swift
//  Musculos
//
//  Created by Solomon Alexandru on 12.10.2024.
//

import Vapor
import Fluent

final class ExerciseSession: Model, Content, @unchecked Sendable {
  static let schema = "exerciseSessions"

  @ID(key: .id)
  var id: UUID?

  @Field(key: "date_added")
  var dateAdded: Date

  @Field(key: "duration")
  var duration: Double

  @Parent(key: "user_id")
  var user: User

  @Parent(key: "exercise_id")
  var exercise: Exercise

  init() {}

  init(id: UUID = UUID(), dateAdded: Date, duration: Double, userID: User.IDValue, exerciseID: Exercise.IDValue) {
    self.id = id
    self.dateAdded = dateAdded
    self.duration = duration
    self.$user.id = userID
    self.$exercise.id = exerciseID
  }
}
