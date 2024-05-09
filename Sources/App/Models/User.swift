//
//  User.swift
//
//
//  Created by Solomon Alexandru on 06.05.2024.
//

import Foundation
import Vapor
import Fluent

final class User: Model, Content, @unchecked Sendable {
  static let schema: String = "users"
  
  @ID(key: .id)
  var id: UUID?
  
  @Field(key: "full_name")
  var fullName: String?
  
  @Field(key: "username")
  var username: String
  
  @Field(key: "email")
  var email: String
  
  @Field(key: "password")
  var password: String
  
  init() { }
  
  init(
    id: UUID? = nil,
    fullName: String? = nil,
    username: String,
    email: String,
    password: String
  ) {
    self.id = id
    self.fullName = fullName
    self.username = username
    self.email = email
    self.password = password
  }
}

extension User: Authenticatable { }

// MARK: - Public class

extension User {
  final class Public: Content {
    var id: UUID?
    var email: String
    var username: String
    var fullName: String?
    
    init(id: UUID? = nil, username: String, email: String, fullName: String? = nil) {
      self.id = id
      self.username = username
      self.email = email
      self.fullName = fullName
    }
  }
  
  func toPublic() -> Public {
    return Public(id: id, username: username, email: email, fullName: fullName)
  }
}
