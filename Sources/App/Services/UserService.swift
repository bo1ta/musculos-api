//
//  UserService.swift
//  Musculos
//
//  Created by Solomon Alexandru on 04.02.2025.
//

import Fluent
import JWT
import Vapor

// MARK: - UserServiceProtocol

protocol UserServiceProtocol: Sendable {
  func register(username: String, email: String, password: String) async throws -> UserSession
  func login(email: String, password: String) async throws -> UserSession
  func updateUser(
    _ user: User,
    weight: Double?,
    height: Double?,
    level: String?,
    isOnboarded: Bool?,
    primaryGoalID: UUID?) async throws -> User.Public
  func getByID(_ userID: UUID) async throws -> User.Public
  func getCurrentUser() async throws -> User.Public
}

// MARK: - UserService

struct UserService: UserServiceProtocol {
  let req: Request

  init(req: Request) {
    self.req = req
  }

  func register(username: String, email: String, password: String) async throws -> UserSession {
    let user = try User(
      username: username,
      email: email,
      passwordHash: Bcrypt.hash(password))
    try await user.save(on: req.db)

    let token = try Token.create(for: user)
    try await token.save(on: req.db)

    return UserSession(token: token.asPublic(), user: user.asPublic())
  }

  func login(email: String, password: String) async throws -> UserSession {
    guard
      let user = try await User.query(on: req.db)
        .filter(\.$email == email)
        .first()
    else {
      throw Abort(.notFound, reason: "User not found")
    }

    guard try Bcrypt.verify(password, created: user.passwordHash) else {
      throw Abort(.unauthorized, reason: "Invalid credentials")
    }

    let token = try Token.create(for: user)
    try await token.save(on: req.db)

    return UserSession(token: token.asPublic(), user: user.asPublic())
  }

  func updateUser(
    _ user: User,
    weight: Double?,
    height: Double?,
    level: String?,
    isOnboarded: Bool?,
    primaryGoalID: UUID?)
  async throws -> User.Public
  {
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

    try await user.update(on: req.db)
    return user.asPublic()
  }

  func getByID(_ userID: UUID) async throws -> User.Public {
    guard let user = try await User.query(on: req.db)
      .filter(\.$id == userID)
      .with(\.$userExperience)
      .first()
    else {
      throw Abort(.notFound, reason: "User not found")
    }
    return user.asPublic()
  }

  func getCurrentUser() async throws -> User.Public {
    guard let userID = try req.auth.require(User.self).id else {
      throw Abort(.unauthorized)
    }
    return try await getByID(userID)
  }
}

// MARK: - UserSession

struct UserSession: Content {
  let token: Token.Public
  let user: User.Public
}
