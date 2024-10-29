//
//  ExerciseController.swift
//
//
//  Created by Solomon Alexandru on 06.05.2024.
//

import Foundation
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
    exerciseRoute.get(":exerciseID", use: { try await self.getByID(req: $0) })
    exerciseRoute.get("getByGoals", use: { try await self.getExercisesByGoal(req: $0) })
    exerciseRoute.get("filtered", use: { try await self.getExercisesByMuscleGroup(req: $0) })
    exerciseRoute.post(use: { try await self.create(req: $0) })

    let favoriteRoute = exerciseRoute.grouped("favorites")
    favoriteRoute.post(use: { try await self.favoriteExercise(req: $0) })
    favoriteRoute.get(use: { try await self.getFavorites(req: $0) })
  }
  
  func index(req: Request) async throws -> [Exercise.Public] {
    let currentUser = try req.auth.require(User.self)
    let exercises = try await Exercise.query(on: req.db).limit(20).all()

    return try await exercises.asyncMap { exercise in
      let isFavorite = try await currentUser.$favoriteExercises.isAttached(to: exercise, on: req.db)
      return exercise.asPublic(isFavorite: isFavorite)
    }
  }

  func getByID(req: Request) async throws -> Exercise.Public {
    let currentUser = try req.auth.require(User.self)

    guard let exerciseID = req.parameters.get("exerciseID", as: UUID.self) else {
      throw Abort(.badRequest)
    }

    guard let exercise = try await Exercise.find(exerciseID, on: req.db) else {
      throw Abort(.notFound)
    }

    let isFavorite = try await currentUser.$favoriteExercises.isAttached(to: exercise, on: req.db)
    return exercise.asPublic(isFavorite: isFavorite)
  }

  func getExercisesByMuscleGroup(req: Request) async throws -> [Exercise.Public] {
      let currentUser = try req.auth.require(User.self)

      // Extract the muscle group query parameter if present
      guard let muscleGroup = req.query["muscleGroup"] as String? else {
          throw Abort(.badRequest, reason: "Muscle group query parameter is required.")
      }

      // Step 1: Fetch only `id`, `primaryMuscles`, and `secondaryMuscles` for filtering
      let exercises = try await Exercise.query(on: req.db)
      .field(\.$id)
      .field(\.$primaryMuscles)
      .all()

      // Step 2: Filter exercises based on `muscleGroup`
      let filteredIDs: [UUID] = exercises
          .filter { exercise in
              exercise.primaryMuscles.contains(muscleGroup)
          }
          .compactMap { $0.id }

      // Step 3: Retrieve full details of exercises that matched the muscle group
      let matchedExercises = try await Exercise.query(on: req.db)
          .filter(\.$id ~~ filteredIDs)
          .all()

      // Map to public representation with favorite status
      return try await matchedExercises.asyncMap { exercise in
          let isFavorite = try await currentUser.$favoriteExercises.isAttached(to: exercise, on: req.db)
          return exercise.asPublic(isFavorite: isFavorite)
      }
  }

  func create(req: Request) async throws -> Exercise {
    let exercise = try req.content.decode(Exercise.self)
    
    try await exercise.save(on: req.db)
    return exercise
  }

  func favoriteExercise(req: Request) async throws -> Exercise {
    let currentUser = try req.auth.require(User.self)

    let favoriteRequest = try req.content.decode(FavoriteExercise.self)
    guard let exercise = try await Exercise.find(favoriteRequest.exerciseID, on: req.db) else {
      throw Abort(.notFound)
    }

    let isCurrentlyFavorite = try await currentUser.$favoriteExercises.isAttached(to: exercise, on: req.db)

    if favoriteRequest.isFavorite && !isCurrentlyFavorite {
      try await currentUser.$favoriteExercises.attach(exercise, on: req.db)
    } else if !favoriteRequest.isFavorite && isCurrentlyFavorite {
      try await currentUser.$favoriteExercises.detach(exercise, on: req.db)
    }

    return exercise
  }

  func isFavoriteExercise(req: Request) async throws -> FavoriteExercise {
    let currentUser = try req.auth.require(User.self)
    let checkFavoriteRequest = try req.content.decode(IsFavoriteExercise.self)

    guard let exercise = try await Exercise.find(checkFavoriteRequest.exerciseID, on: req.db) else {
      throw Abort(.notFound)
    }

    let isFavoriteExercise = try await currentUser.$favoriteExercises.isAttached(to: exercise, on: req.db)
    return FavoriteExercise(
      exerciseID: checkFavoriteRequest.exerciseID,
      isFavorite: isFavoriteExercise
    )
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

  public func getExercisesByGoal(req: Request) async throws -> [Exercise.Public] {
    let goal = try req.query.get(WorkoutGoal.self, at: "goal")
    let categories = ExerciseConstants.goalToExerciseCategories[goal] ?? []
    guard !categories.isEmpty else {
      return []
    }

    let exercises = try await Exercise.query(on: req.db)
      .filter(\.$category ~~ categories)
      .limit(25)
      .all()

    return exercises.map { $0.asPublic(isFavorite: false) }
  }
}

// MARK: - Internal Models

extension ExerciseController {
  struct FavoriteExercise: Content {
    let exerciseID: UUID
    let isFavorite: Bool

    enum CodingKeys: String, CodingKey {
      case exerciseID = "exercise_id"
      case isFavorite = "is_favorite"
    }
  }

  struct IsFavoriteExercise: Content {
    let exerciseID: UUID

    enum CodingKeys: String, CodingKey {
      case exerciseID = "exercise_id"
    }
  }
}
