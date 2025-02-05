//
//  ExerciseRatingController.swift
//  Musculos
//
//  Created by Solomon Alexandru on 23.11.2024.
//

import Fluent
import Foundation
import Vapor

// MARK: - ExerciseRatingController

struct ExerciseRatingController: RouteCollection {
  typealias API = RatingsAPI

  func boot(routes: any RoutesBuilder) throws {
    let route = routes.apiV1Group("ratings")
      .grouped(Token.authenticator())

    route.get(RatingsAPI.GET.getByExerciseID, use: { try await self.getByExerciseID(req: $0) })
    route.get(use: { try await getAllForCurrentUser(req: $0) })
    route.post(use: { try await addRating(req: $0) })
  }

  func addRating(req: Request) async throws -> HTTPStatus {
    let currentUser = try req.auth.require(User.self)
    let content = try req.content.decode(RatingsAPI.POST.CreateExerciseRating.self)

    try await req.ratingService.addRatingFromContent(content, user: currentUser)

    return .created
  }

  func getByExerciseID(req: Request) async throws -> [ExerciseRating.Public] {
    guard let exerciseID = req.parameters.get("exerciseID", as: UUID.self) else {
      throw Abort(.badRequest)
    }
    return try await req.ratingService.getForExerciseID(exerciseID)
  }

  func getAllForCurrentUser(req: Request) async throws -> [ExerciseRating.Public] {
    let currentUser = try req.auth.require(User.self)
    return try await req.ratingService.getAllForUser(currentUser)
  }
}
