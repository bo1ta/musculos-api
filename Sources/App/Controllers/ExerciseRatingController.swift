//
//  ExerciseRatingController.swift
//  Musculos
//
//  Created by Solomon Alexandru on 23.11.2024.
//

import Foundation
import Fluent
import Vapor

struct ExerciseRatingController: RouteCollection {
  func boot(routes: any RoutesBuilder) throws {
    let route = routes.apiV1Group("ratings")
      .grouped(Token.authenticator())

    route.get(":exerciseID", use: { try await self.getByExerciseID(req: $0) })
    route.get(use: { try await getAllForCurrentUser(req: $0) })
    route.post(use: { try await addRating(req: $0) })
  }

  func addRating(req: Request) async throws -> HTTPStatus {
    let currentUser = try req.auth.require(User.self)
    let content = try req.content.decode(CreateContent.self)

    let exerciseRating = ExerciseRating()
    exerciseRating.id = content.ratingID
    exerciseRating.isPublic = content.isPublic
    exerciseRating.rating = content.rating
    exerciseRating.comment = content.comment

    exerciseRating.$user.id = try currentUser.requireID()
    exerciseRating.$exercise.id = content.exerciseID

    try await exerciseRating.save(on: req.db)
    return .created
  }

  func getByExerciseID(req: Request) async throws -> [ExerciseRating.Public] {
    guard let exerciseID = req.parameters.get("exerciseID", as: UUID.self) else {
      throw Abort(.badRequest)
    }

    return try await ExerciseRating.query(on: req.db)
      .filter(\.$exercise.$id == exerciseID)
      .all()
      .map { try $0.asPublic() }
  }

  func getAllForCurrentUser(req: Request) async throws -> [ExerciseRating.Public] {
    let currentUser = try req.auth.require(User.self)
    return try await ExerciseRating.query(on: req.db)
      .filter(\.$user.$id == currentUser.requireID())
      .all()
      .map { try $0.asPublic() }
  }
}

extension ExerciseRatingController {
  struct CreateContent: Content {
    let ratingID: UUID
    let exerciseID: UUID
    let rating: Double
    let comment: String?
    let isPublic: Bool
  }
}
