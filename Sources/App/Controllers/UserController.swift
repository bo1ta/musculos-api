//
//  UserController.swift
//
//
//  Created by Solomon Alexandru on 06.05.2024.
//

import Fluent
import Vapor

struct UserController: RouteCollection {
  func boot(routes: any RoutesBuilder) throws {
    let users = routes.grouped("api", "v1", "users")
    
    users.post("register") { request in
      try await register(request)
    }
  }
  
  func register(_ req: Request) async throws -> User.Public {
    let user = try req.content.decode(User.self)
    user.password = try Bcrypt.hash(user.password)
    
    try await user.save(on: req.db)
    return user.toPublic()
  }
  
  func login(_ req: Request) async throws -> Token {
    let user = try req.auth.require(User.self)
    let token = try Token.generate(for: user)
    
    try await token.save(on: req.db)
    return token
  }
}
