//
//  User.swift
//
//
//  Created by Solomon Alexandru on 06.05.2024.
//

import Fluent
import Foundation
import JWT
import Vapor

// MARK: - User

final class User: Model, Content, @unchecked Sendable {
  static let schema = "users"

  @ID(key: .id)
  var id: UUID?

  @Field(key: "username")
  var username: String

  @Field(key: "email")
  var email: String

  @Field(key: "password_hash")
  var passwordHash: String

  @Field(key: "weight")
  var weight: Double?

  @Field(key: "height")
  var height: Double?

  @Field(key: "level")
  var level: String?

  @Field(key: "primary_goal_id")
  var primaryGoalID: UUID?

  @Field(key: "is_onboarded")
  var isOnboarded: Bool

  @Siblings(through: UserFavoriteExercise.self, from: \.$user, to: \.$exercise)
  var favoriteExercises: [Exercise]

  @Children(for: \.$user)
  var goals: [Goal]

  @Children(for: \.$user)
  var ratings: [ExerciseRating]

  @OptionalChild(for: \.$user)
  var userExperience: UserExperience?

  init() { }

  init(
    id: UUID? = nil,
    username: String,
    email: String,
    passwordHash: String,
    weight: Double? = nil,
    height: Double? = nil,
    level: String? = nil,
    primaryGoalID: UUID? = nil,
    isOnboarded: Bool = false)
  {
    self.id = id
    self.username = username
    self.email = email
    self.passwordHash = passwordHash
    self.weight = weight
    self.height = height
    self.level = level
    self.primaryGoalID = primaryGoalID
    self.isOnboarded = isOnboarded
  }

  func asPublic() -> User.Public {
    User.Public(
      username: self.username,
      email: self.email,
      id: self.id,
      weight: self.weight,
      height: self.height,
      level: self.level,
      isOnboarded: self.isOnboarded,
      primaryGoalID: self.primaryGoalID,
      totalExperience: self.$userExperience.value??.totalExperience ?? 0,
      userExperience: $userExperience.value??.asPublic())
  }

  func isExerciseFavorite(_ exercise: Exercise, on db: Database) async throws -> Bool {
    try await $favoriteExercises.isAttached(to: exercise, on: db)
  }
}

extension User {
  struct SignIn: Content {
    let email: String
    let password: String
  }

  struct SignUp: Content, Validatable {
    var username: String
    var email: String
    var password: String

    static func validations(_ validations: inout Validations) {
      validations.add("username", as: String.self, is: !.empty)
      validations.add("email", as: String.self, is: .email)
      validations.add("password", as: String.self, is: .count(8...))
    }
  }

  struct Public: Content {
    var username: String
    var email: String
    var id: UUID?
    var weight: Double?
    var height: Double?
    var level: String?
    var isOnboarded: Bool
    var primaryGoalID: UUID?
    var totalExperience: Int
    var userExperience: UserExperience.Public?
  }
}

// MARK: ModelAuthenticatable

extension User: ModelAuthenticatable {
  static let usernameKey = \User.$email
  static let passwordHashKey = \User.$passwordHash

  func verify(password: String) throws -> Bool {
    try Bcrypt.verify(password, created: self.passwordHash)
  }
}
