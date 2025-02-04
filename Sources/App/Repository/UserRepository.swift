//
//  UserRepository.swift
//  Musculos
//
//  Created by Solomon Alexandru on 04.02.2025.
//

import Fluent
import JWT
import Vapor

protocol UserRepositoryProtoocol: Sendable {
  func register(username: String, email: String, password: String, on db: Database) async throws -> UserSession
  func login(email: String, password: String, on db: Database) async throws -> UserSession
  func updateUser(_ user: User, weight: Double?, height: Double?, level: String?, isOnboarded: Bool?, primaryGoalID: UUID?, on db: Database) async throws -> User.Public
}

struct UserRepository: UserRepositoryProtoocol {
  func register(username: String, email: String, password: String, on db: Database) async throws -> UserSession {
    let user = try User(
      username: username,
      email: email,
      passwordHash: Bcrypt.hash(password))
    try await user.save(on: db)

    let token = try Token.create(for: user)
    try await token.save(on: db)

    return UserSession(token: token.asPublic(), user: user.asPublic())
  }

  func login(email: String, password: String, on db: Database) async throws -> UserSession {
    guard let user = try await User.query(on: db)
        .filter(\.$email == email)
        .first()
    else {
      throw Abort(.notFound, reason: "User not found")
    }

    guard try Bcrypt.verify(password, created: user.passwordHash) else {
      throw Abort(.unauthorized, reason: "Invalid credentials")
    }

    let token = try Token.create(for: user)
    try await token.save(on: db)

    return UserSession(token: token.asPublic(), user: user.asPublic())
  }

  func updateUser(_ user: User, weight: Double?, height: Double?, level: String?, isOnboarded: Bool?, primaryGoalID: UUID?, on db: Database) async throws -> User.Public {
    if let weight {
      user.weight = weight
    }
    if let height {
      user.height = height
    }
    if let level {
      user.level = level
    }
    if let isOnboarded {
      user.isOnboarded = isOnboarded
    }
    if let primaryGoalID {
      user.primaryGoalID = primaryGoalID
    }

    try await user.update(on: db)
    return user.asPublic()
  }
}

struct UserSession: Content {
  let token: Token.Public
  let user: User.Public
}
