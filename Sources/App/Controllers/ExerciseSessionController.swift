//
//  File.swift
//  Musculos
//
//  Created by Solomon Alexandru on 12.10.2024.
//

import Fluent
import Vapor

struct ExerciseSessionController: RouteCollection {
  func boot(routes: any RoutesBuilder) throws {
    let route = routes.apiV1Group("exercise-session")
      .grouped(
        Token.authenticator()
      )

    route.get(use:  { try await getAll(req: $0) })
    route.post(use: { try await create(req: $0) })
  }

  func getAll(req: Request) async throws -> [ExerciseSession] {
    let currentUser = try req.auth.require(User.self)
    return try await ExerciseSession.query(on: req.db)
      .filter(\.$user.$id == currentUser.id!)
      .all()
  }

  func create(req: Request) async throws -> ExerciseSession {
    let currentUser = try req.auth.require(User.self)
    let content = try req.content.decode(CreateContent.self)

    let session = ExerciseSession()
    session.dateAdded = content.dateAdded
    session.duration = content.duration

    session.$user.id = try currentUser.requireID()
    session.$exercise.id  = content.exerciseID

    try await session.save(on: req.db)
    return session
  }

  private struct CreateContent: Content {
      var dateAdded: Date
      var duration: Double
      var exerciseID: UUID
  }
}
