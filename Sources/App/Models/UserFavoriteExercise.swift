//
//  File.swift
//  
//
//  Created by Solomon Alexandru on 12.09.2024.
//

import Fluent
import Vapor

final class UserFavoriteExercise: Model, @unchecked Sendable {
  static let schema = "user_favorite_exercises"

  @ID(key: .id)
  var id: UUID?

  @Parent(key: "user_id")
  var user: User

  @Parent(key: "exercise_id")
  var exercise: Exercise

  init() {}

  init(id: UUID? = nil, userID: User.IDValue, exerciseID: Exercise.IDValue) {
    self.id = id
    self.$user.id = userID
    self.$exercise.id = exerciseID
  }
}
