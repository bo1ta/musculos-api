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

  func getAll(req: Request) async throws -> [ExerciseSession.Public] {
    let currentUser = try req.auth.require(User.self)
    return try await ExerciseSession.query(on: req.db)
      .filter(\.$user.$id == currentUser.id!)
      .with(\.$user)
      .with(\.$exercise)
      .all()
      .map { try $0.asPublic() }
  }

  func create(req: Request) async throws -> UserExperienceEntry {
    let currentUser = try req.auth.require(User.self)
    let content = try req.content.decode(CreateContent.self)

    let session = ExerciseSession()
    session.id = content.sessionID
    session.dateAdded = content.dateAdded
    session.duration = content.duration

    session.$user.id = try currentUser.requireID()
    session.$exercise.id  = content.exerciseID

    try await session.save(on: req.db)

    try await session.$user.load(on: req.db)
    try await session.$exercise.load(on: req.db)

    return try await ExperienceService.updateUserExperience(for: session, req: req)
  }

  private struct CreateContent: Content {
    var dateAdded: Date
    var duration: Double
    var exerciseID: UUID
    var sessionID: UUID
  }
}
