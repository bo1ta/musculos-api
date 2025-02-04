//
//  ExerciseSessionController.swift
//  Musculos
//
//  Created by Solomon Alexandru on 12.10.2024.
//

import Fluent
import Vapor

struct ExerciseSessionController: RouteCollection {
  typealias API = ExerciseSessionsAPI

  private let repository: ExerciseSessionRepositoryProtocol

  init(repository: ExerciseSessionRepositoryProtocol = ExerciseSessionRepository()) {
    self.repository = repository
  }

  func boot(routes: any RoutesBuilder) throws {
    let route = routes.apiV1Group("exercise-session")
      .grouped(
        Token.authenticator())

    route.get(use: { try await getAll(req: $0) })
    route.post(use: { try await create(req: $0) })
  }

  func getAll(req: Request) async throws -> [ExerciseSession.Public] {
    let currentUser = try req.auth.require(User.self)
    return try await repository.getAllForUser(currentUser, on: req.db)
  }

  func create(req: Request) async throws -> UserExperienceEntry {
    let currentUser = try req.auth.require(User.self)
    let request = try req.content.decode(API.POST.CreateExerciseSession.self)

    return try await repository.createExerciseSession(
      request.sessionID,
      dateAdded: request.dateAdded,
      duration: request.duration,
      exerciseID: request.exerciseID,
      user: currentUser,
      on: req.db)
  }
}
