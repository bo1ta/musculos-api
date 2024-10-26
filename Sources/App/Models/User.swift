//
//  User.swift
//
//
//  Created by Solomon Alexandru on 06.05.2024.
//

import Foundation
import Vapor
import Fluent
import JWT

final class User: Model, Content, @unchecked Sendable {
  static let schema: String = "users"
  
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

  @Field(key: "xp")
  var xp: Int

  @Children(for: \.$user)
  var goals: [Goal]

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
    isOnboarded: Bool = false,
    xp: Int = 0
  ) {
    self.id = id
    self.username = username
    self.email = email
    self.passwordHash = passwordHash
    self.weight = weight
    self.height = height
    self.level = level
    self.primaryGoalID = primaryGoalID
    self.isOnboarded = isOnboarded
    self.xp = xp
  }

  func asPublic() -> User.Public {
    return User.Public(
      username: self.username,
      email: self.email,
      id: self.id,
      weight: self.weight,
      height: self.height,
      level: self.level,
      isOnboarded: self.isOnboarded,
      xp: self.xp,
      primaryGoalID: self.primaryGoalID
    )
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
    var xp: Int
    var primaryGoalID: UUID?
  }
}

extension User: ModelAuthenticatable {
  static let usernameKey = \User.$email
  static let passwordHashKey = \User.$passwordHash

  func verify(password: String) throws -> Bool {
    try Bcrypt.verify(password, created: self.passwordHash)
  }
}
