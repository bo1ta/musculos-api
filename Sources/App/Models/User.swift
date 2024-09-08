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
  
  init() { }
  
  init(
    id: UUID? = nil,
    username: String,
    email: String,
    passwordHash: String
  ) {
    self.id = id
    self.username = username
    self.email = email
    self.passwordHash = passwordHash
  }

  func asPublic() -> User.Public {
    return User.Public(username: self.username, email: self.email, id: self.id)
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
  }
}

extension User: ModelAuthenticatable {
  static let usernameKey = \User.$email
  static let passwordHashKey = \User.$passwordHash

  func verify(password: String) throws -> Bool {
    try Bcrypt.verify(password, created: self.passwordHash)
  }
}
