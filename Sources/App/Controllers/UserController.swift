//
//  UserController.swift
//
//
//  Created by Solomon Alexandru on 06.05.2024.
//

import Fluent
import Vapor
import JWT

struct UserController: RouteCollection {
  func boot(routes: any RoutesBuilder) throws {
    let users = routes.apiV1Group("users")

    users.post("register") { request in
      try await register(request)
    }
    
    users.post("login") { request in
      try await login(request)
    }

    let protectedRoute = users.grouped(Token.authenticator())
    protectedRoute.get("me") { request in
      try await getMyProfile(request)
    }
  }

  func register(_ req: Request) async throws -> SessionResponse {
    try User.SignUp.validate(content: req)

    let create = try req.content.decode(User.SignUp.self)
    let user = try User(
      username: create.username,
      email: create.email,
      passwordHash: Bcrypt.hash(create.password)
    )
    try await user.save(on: req.db)

    let token = try Token.create(for: user)
    try await token.save(on: req.db)

    return SessionResponse(token: token.asPublic(), user: user.asPublic())
  }
  
  func login(_ req: Request) async throws -> SessionResponse {
    let userAuth = try req.content.decode(User.SignIn.self)

    guard let user = try await User.query(on: req.db)
      .filter(\.$email == userAuth.email)
      .first() else {
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
    return try req.auth.require(User.self).asPublic()
  }
}

extension UserController {
  struct SessionResponse: Content {
    let token: Token.Public
    let user: User.Public
  }
}
