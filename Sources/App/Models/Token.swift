//
//  Token.swift
//
//
//  Created by Solomon Alexandru on 07.05.2024.
//

import Fluent
import Vapor

final class Token: Model, Content, @unchecked Sendable {
  static let schema = "tokens"
  
  @ID
  var id: UUID?
  
  @Field(key: "token_value")
  var tokenValue: String
  
  @Parent(key: "user_id")
  var user: User
  
  init() { }
  
  init(id: UUID? = nil, tokenValue: String, userID: User.IDValue) {
  self.id = id
  self.tokenValue = tokenValue
  self.$user.id = userID
  }
  
  static func generate(for user: User) throws -> Token {
  let randomToken = [UInt8].random(count: 32).base64
  let userID = try user.requireID()
  
  return Token(tokenValue: randomToken, userID: userID)
  }
}

extension Token: ModelTokenAuthenticatable {
  typealias User = App.User
  
  static let valueKey = \Token.$tokenValue
  static let userKey = \Token.$user
  
  var isValid: Bool {
  true
  }
}
