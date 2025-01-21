//
//  ExerciseController.swift
//
//
//  Created by Solomon Alexandru on 06.05.2024.
//

import Fluent
import Foundation
import Vapor

// MARK: - ExerciseController

struct ExerciseController: RouteCollection {
  func boot(routes: any RoutesBuilder) throws {
    let exerciseRoute = routes
      .apiV1Group("exercises")
      .grouped(
        Token.authenticator())

    exerciseRoute.get(use: { try await self.index(req: $0) })
    exerciseRoute.get(":exerciseID", use: { try await self.getByID(req: $0) })
    exerciseRoute.get("getByGoals", use: { try await self.getExercisesByGoal(req: $0) })
    exerciseRoute.get("filtered", use: { try await self.getFilteredExercises(req: $0) })
    exerciseRoute.post(use: { try await self.create(req: $0) })

    let favoriteRoute = exerciseRoute.grouped("favorites")
    favoriteRoute.post(use: { try await self.favoriteExercise(req: $0) })
    favoriteRoute.get(use: { try await self.getFavorites(req: $0) })
  }

  func index(req: Request) async throws -> Response {
    let currentUser = try req.auth.require(User.self)
    let exercises = try await Exercise.query(on: req.db).limit(20).all()

    let publicExercises = try await exercises.asyncMap { exercise in
      let isFavorite = try await currentUser.$favoriteExercises.isAttached(to: exercise, on: req.db)
      return exercise.asPublic(isFavorite: isFavorite)
    }

    return try Response.withCacheControl(maxAge: 1800, data: publicExercises)
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

  func getFilteredExercises(req: Request) async throws -> Response {
    let muscle = req.query["muscle"] as String?
    let muscleGroup = req.query["muscleGroup"] as String?
    let name = req.query["name"] as String?

    guard muscle != nil || muscleGroup != nil || name != nil else {
      throw Abort(.badRequest, reason: "At least one filter parameter (muscle, muscleGroup, or name) is required.")
    }

    var exercises = try await Exercise.query(on: req.db).all()

    if let muscle {
      exercises = exercises.filter { $0.primaryMuscles.contains(muscle) }
    }

    if let muscleGroup, let muscleGroupType = MuscleGroup(rawValue: muscleGroup.lowercased()) {
      let groupMuscles = muscleGroupType.muscles.map(\.rawValue)

      exercises = exercises.filter { exercise in
        exercise.primaryMuscles.contains { groupMuscles.contains($0) }
      }
    }

    if let name {
      exercises = exercises.filter { $0.name.localizedCaseInsensitiveContains(name) }
    }

    let publicExercises = exercises.map { $0.asPublic() }
    return try Response.withCacheControl(maxAge: 1800, data: publicExercises)
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

    if favoriteRequest.isFavorite, !isCurrentlyFavorite {
      try await currentUser.$favoriteExercises.attach(exercise, on: req.db)
    } else if !favoriteRequest.isFavorite, isCurrentlyFavorite {
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
      isFavorite: isFavoriteExercise)
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

  public func getExercisesByGoal(req: Request) async throws -> Response {
    let goal = try req.query.get(WorkoutGoal.self, at: "goal")
    let categories = ExerciseConstants.goalToExerciseCategories[goal] ?? []
    guard !categories.isEmpty else {
      throw Abort(.notFound)
    }

    let exercises = try await Exercise.query(on: req.db)
      .filter(\.$category ~~ categories)
      .limit(25)
      .all()

    let publicExercises = exercises.map { $0.asPublic(isFavorite: false) }
    return try Response.withCacheControl(maxAge: 1800, data: publicExercises)
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
