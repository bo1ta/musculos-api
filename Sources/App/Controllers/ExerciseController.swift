//
//  ExerciseController.swift
//
//
//  Created by Solomon Alexandru on 06.05.2024.
//

import Fluent
import Vapor

struct ExerciseController: RouteCollection {
  func boot(routes: any RoutesBuilder) throws {
    let exerciseRoute = routes
      .apiV1Group("exercises")
      .grouped(
        Token.authenticator()
      )

    exerciseRoute.get(use: { try await self.index(req: $0) })
    exerciseRoute.post(use: { try await self.create(req: $0) })

    let favoriteRoute = exerciseRoute.grouped("favorites")
    favoriteRoute.post(use: { try await self.favoriteExercise(req: $0) })
    favoriteRoute.get(use: { try await self.getFavorites(req: $0) })
  }
  
  func index(req: Request) async throws -> [Exercise] {
    try await Exercise.query(on: req.db).all()
  }
  
  func create(req: Request) async throws -> Exercise {
    let exercise = try req.content.decode(Exercise.self)
    
    try await exercise.save(on: req.db)
    return exercise
  }

  func favoriteExercise(req: Request) async throws -> Exercise {
    let currentUser = try req.auth.require(User.self)

    struct FavoriteRequest: Content {
      let exerciseID: UUID
    }

    let favoriteRequest = try req.content.decode(FavoriteRequest.self)
    guard let exercise = try await Exercise.find(favoriteRequest.exerciseID, on: req.db) else {
      throw Abort(.notFound)
    }

    if try await currentUser.$favoriteExercises.isAttached(to: exercise, on: req.db) {
      try await currentUser.$favoriteExercises.detach(exercise, on: req.db)
      return exercise
    } else {
      try await currentUser.$favoriteExercises.attach(exercise, on: req.db)
      return exercise
    }
  }

  func getFavorites(req: Request) async throws -> [Exercise] {
    let currentUser = try req.auth.require(User.self)
    return try await currentUser.$favoriteExercises.get(on: req.db)
  }

  func delete(req: Request) async throws -> HTTPStatus {
    guard let exercise = try await Exercise.find(req.parameters.get("exerciseID"), on: req.db) else {
      throw Abort(.notFound)
    }
    
    try await exercise.delete(on: req.db)
    return .noContent
  }
}
