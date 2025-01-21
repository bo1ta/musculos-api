//
//  UserController.swift
//
//
//  Created by Solomon Alexandru on 06.05.2024.
//

import Fluent
import JWT
import Vapor

// MARK: - UserController

struct UserController: RouteCollection {
  func boot(routes: any RoutesBuilder) throws {
    let users = routes.apiV1Group("users")

    users.post("register") { request in
      try await register(request)
    }

    users.post("login") { request in
      try await login(request)
    }

    let protectedRoute = users.grouped(Token.authenticator()).grouped("me")
    protectedRoute.get { request in
      try await getMyProfile(request)
    }
    protectedRoute.post("update-profile") { request in
      try await updateProfile(request)
    }
  }

  func updateProfile(_ req: Request) async throws -> User.Public {
    let user = try req.auth.require(User.self)

    let updateData = try req.content.decode(UpdateProfileData.self)
    if let weight = updateData.weight {
      user.weight = weight
    }
    if let height = updateData.height {
      user.height = height
    }
    if let level = updateData.level {
      user.level = level
    }
    if let isOnboarded = updateData.isOnboarded {
      user.isOnboarded = isOnboarded
    }
    if let primaryGoalID = updateData.primaryGoalID {
      user.primaryGoalID = primaryGoalID
    }

    try await user.update(on: req.db)
    return user.asPublic()
  }

  func register(_ req: Request) async throws -> SessionResponse {
    try User.SignUp.validate(content: req)

    let create = try req.content.decode(User.SignUp.self)
    let user = try User(
      username: create.username,
      email: create.email,
      passwordHash: Bcrypt.hash(create.password))
    try await user.save(on: req.db)

    let token = try Token.create(for: user)
    try await token.save(on: req.db)

    return SessionResponse(token: token.asPublic(), user: user.asPublic())
  }

  func login(_ req: Request) async throws -> SessionResponse {
    let userAuth = try req.content.decode(User.SignIn.self)

    guard
      let user = try await User.query(on: req.db)
        .filter(\.$email == userAuth.email)
        .first()
    else {
      throw Abort(.notFound, reason: "User not found")
    }

    guard try Bcrypt.verify(userAuth.password, created: user.passwordHash) else {
      throw Abort(.unauthorized, reason: "Invalid credentials")
    }

    let token = try Token.create(for: user)
    try await token.save(on: req.db)

    return SessionResponse(token: token.asPublic(), user: user.asPublic())
  }

  func getMyProfile(_ req: Request) async throws -> User.Public {
    try req.auth.require(User.self).asPublic()
  }
}

extension UserController {
  struct SessionResponse: Content {
    let token: Token.Public
    let user: User.Public
  }

  struct UpdateProfileData: Content {
    let weight: Double?
    let height: Double?
    let level: String?
    let isOnboarded: Bool?
    let primaryGoalID: UUID?
  }
}
