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

  @Field(key: "primary_goal")
  var primaryGoal: String?

  @Field(key: "is_onboarded")
  var isOnboarded: Bool

  @Siblings(through: UserFavoriteExercise.self, from: \.$user, to: \.$exercise)
  var favoriteExercises: [Exercise]

  init() { }
  
  init(
    id: UUID? = nil,
    username: String,
    email: String,
    passwordHash: String,
    weight: Double? = nil,
    height: Double? = nil,
    level: String? = nil,
    primaryGoal: String? = nil,
    isOnboarded: Bool = false
  ) {
    self.id = id
    self.username = username
    self.email = email
    self.passwordHash = passwordHash
    self.weight = weight
    self.height = height
    self.level = level
    self.primaryGoal = primaryGoal
    self.isOnboarded = isOnboarded
  }

  func asPublic() -> User.Public {
    return User.Public(
      username: self.username,
      email: self.email,
      id: self.id,
      weight: self.weight,
      height: self.height,
      primaryGoal: self.primaryGoal,
      level: self.level,
      isOnboarded: self.isOnboarded
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
    var primaryGoal: String?
    var level: String?
    var isOnboarded: Bool
  }
}

extension User: ModelAuthenticatable {
  static let usernameKey = \User.$email
  static let passwordHashKey = \User.$passwordHash

  func verify(password: String) throws -> Bool {
    try Bcrypt.verify(password, created: self.passwordHash)
  }
}
