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
  typealias API = UsersAPI

  private let repository: UserRepositoryProtoocol

  init(repository: UserRepositoryProtoocol = UserRepository()) {
    self.repository = repository
  }

  func boot(routes: any RoutesBuilder) throws {
    let users = routes.apiV1Group(API.endpoint)

    users.post(API.POST.register) { request in
      try await register(request)
    }

    users.post(API.POST.login) { request in
      try await login(request)
    }

    let protectedRoute = users.grouped(Token.authenticator()).grouped("me")
    protectedRoute.get { request in
      try await getMyProfile(request)
    }
    protectedRoute.post(API.POST.updateProfile) { request in
      try await updateProfile(request)
    }
  }

  func updateProfile(_ req: Request) async throws -> User.Public {
    let user = try req.auth.require(User.self)
    let request = try req.content.decode(API.POST.UpdateUser.self)

    return try await repository.updateUser(user, weight: request.weight, height: request.height, level: request.level, isOnboarded: request.isOnboarded, primaryGoalID: request.primaryGoalID, on: req.db)
  }

  func register(_ req: Request) async throws -> UserSession {
    try API.POST.SignUp.validate(content: req)

    let request = try req.content.decode(User.SignUp.self)
    return try await repository.register(username: request.username, email: request.email, password: request.password, on: req.db)
  }

  func login(_ req: Request) async throws -> UserSession {
    let request = try req.content.decode(User.SignIn.self)
    return try await repository.login(email: request.email, password: request.password, on: req.db)
  }

  func getMyProfile(_ req: Request) async throws -> User.Public {
    try req.auth.require(User.self).asPublic()
  }
}
