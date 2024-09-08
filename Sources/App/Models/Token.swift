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

  @Field(key: "expires_at")
  var expiresAt: Date?

  @Timestamp(key: "created_at", on: .create)
  var createdAt: Date?

  @Parent(key: "user_id")
  var user: User

  init() { }

  init(id: UUID? = nil, userID: User.IDValue, tokenValue: String, expiresAt: Date?) {
    self.id = id
    self.$user.id = userID
    self.expiresAt = expiresAt
    self.tokenValue = tokenValue
  }

  static func create(for user: User) throws -> Token {
    let userID = try user.requireID()
    let tokenValue = [UInt8].random(count: 32).base64
    let expiryDate = Calendar(identifier: .gregorian)
      .date(byAdding: .day, value: 1, to: Date())

    return Token(userID: userID, tokenValue: tokenValue, expiresAt: expiryDate)
  }

  func asPublic() -> Token.Public {
    return Token.Public(createdAt: self.createdAt, expiresAt: self.expiresAt, value: self.tokenValue)
  }
}

extension Token {
  struct Public: Content {
    let createdAt: Date?
    let expiresAt: Date?
    let value: String
  }
}

// MARK: - `ModelTokenAuthenticatable` conformance

extension Token: ModelTokenAuthenticatable {
  static let valueKey = \Token.$tokenValue
  static let userKey = \Token.$user

  var isValid: Bool {
    guard let expiresAt else {
      return true
    }
    return expiresAt > Date()
  }
}
