//
//  ExerciseRating.swift
//  Musculos
//
//  Created by Solomon Alexandru on 23.11.2024.
//

import Fluent
import Vapor

// MARK: - ExerciseRating

final class ExerciseRating: Model, Content, @unchecked Sendable {
  static let schema = "exercise_ratings"

  @ID(custom: "rating_id")
  var id: UUID?

  @Parent(key: "user_id")
  var user: User

  @Parent(key: "exercise_id")
  var exercise: Exercise

  @Field(key: "rating")
  var rating: Double

  @Field(key: "is_public")
  var isPublic: Bool

  @Field(key: "comment")
  var comment: String?

  init() { }

  init(id: UUID? = nil, userID: User.IDValue, exerciseID: Exercise.IDValue, rating: Double, comment: String? = nil) {
    self.id = id
    self.$user.id = userID
    self.$exercise.id = exerciseID
    self.rating = rating
    self.comment = comment
  }

  func asPublic() throws -> Public {
    try Public(
      ratingID: self.requireID(),
      userID: $user.id,
      exerciseID: $exercise.id,
      rating: rating,
      comment: comment)
  }
}

// MARK: ExerciseRating.Public

extension ExerciseRating {
  struct Public: Content {
    var ratingID: UUID
    var userID: UUID
    var exerciseID: UUID
    var rating: Double
    var comment: String?
  }
}
