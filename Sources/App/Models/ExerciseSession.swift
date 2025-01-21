//
//  ExerciseSession.swift
//  Musculos
//
//  Created by Solomon Alexandru on 12.10.2024.
//

import Fluent
import Vapor

final class ExerciseSession: Model, Content, @unchecked Sendable {
  static let schema = "exerciseSessions"

  @ID(custom: "session_id")
  var id: UUID?

  @Field(key: "date_added")
  var dateAdded: Date

  @Field(key: "duration")
  var duration: Double

  @Parent(key: "user_id")
  var user: User

  @Parent(key: "exercise_id")
  var exercise: Exercise

  init() { }

  init(id: UUID = UUID(), dateAdded: Date, duration: Double, userID: User.IDValue, exerciseID: Exercise.IDValue) {
    self.id = id
    self.dateAdded = dateAdded
    self.duration = duration
    self.$user.id = userID
    self.$exercise.id = exerciseID
  }

  func asPublic() throws -> Public {
    try Public(
      sessionId: self.requireID(),
      dateAdded: self.dateAdded,
      user: self.user.asPublic(),
      exercise: exercise.asPublic(isFavorite: false),
      duration: self.duration)
  }

  struct Public: Content {
    let sessionId: UUID
    let dateAdded: Date
    let user: User.Public
    let exercise: Exercise.Public
    let duration: Double
  }
}
