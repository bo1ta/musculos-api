//
//  ExerciseController.swift
//
//
//  Created by Solomon Alexandru on 06.05.2024.
//

import Fluent
import Foundation
import Vapor

struct ExerciseController: RouteCollection, Sendable {
  typealias API = ExercisesAPI

  private let repository: ExerciseRepositoryProtocol

  init(repository: ExerciseRepositoryProtocol = ExerciseRepository()) {
    self.repository = repository
  }

  func boot(routes: any RoutesBuilder) throws {
    let exerciseRoute = routes
      .apiV1Group(API.endpoint)
      .grouped(
        Token.authenticator())

    exerciseRoute.get(use: { try await self.index(req: $0) })
    exerciseRoute.get(API.GET.getByID, use: { try await self.getByID(req: $0) })
    exerciseRoute.get(API.GET.getByGoals, use: { try await self.getExercisesByGoal(req: $0) })
    exerciseRoute.get(API.GET.filtered, use: { try await self.getFilteredExercises(req: $0) })
    exerciseRoute.post(use: { try await self.create(req: $0) })

    let favoriteRoute = exerciseRoute.grouped("favorites")
    favoriteRoute.post(use: { try await self.favoriteExercise(req: $0) })
    favoriteRoute.get(use: { try await self.getFavorites(req: $0) })
  }

  func index(req: Request) async throws -> Response {
    let currentUser = try req.auth.require(User.self)
    let exercises = try await repository.getExercisesForUser(currentUser, limit: 20, on: req.db)
    return try Response.withCacheControl(maxAge: Constants.defaultCacheAge, data: exercises)
  }

  func getByID(req: Request) async throws -> Exercise.Public {
    let currentUser = try req.auth.require(User.self)

    guard let exerciseID = req.parameters.get("exerciseID", as: UUID.self) else {
      throw Abort(.badRequest)
    }
    return try await repository.getExerciseForUser(currentUser, exerciseID: exerciseID, on: req.db)
  }

  func getFilteredExercises(req: Request) async throws -> Response {
    let muscle = req.query["muscle"] as String?
    let muscleGroup = req.query["muscleGroup"] as String?
    let name = req.query["name"] as String?

    guard muscle != nil || muscleGroup != nil || name != nil else {
      throw Abort(.badRequest, reason: "At least one filter parameter (muscle, muscleGroup, or name) is required.")
    }

    let exercises = try await repository.getFiltered(muscle: muscle, muscleGroup: muscleGroup, name: name, on: req.db)
    return try Response.withCacheControl(maxAge: Constants.defaultCacheAge, data: exercises)
  }

  func create(req: Request) async throws -> Exercise {
    let exercise = try req.content.decode(Exercise.self)
    return try await repository.create(exercise, on: req.db)
  }

  func favoriteExercise(req: Request) async throws -> Exercise {
    let currentUser = try req.auth.require(User.self)
    let favoriteRequest = try req.content.decode(API.POST.FavoriteExercise.self)

    return try await repository.setIsFavorite(
      favoriteRequest.exerciseID,
      isFavorite: favoriteRequest.isFavorite,
      user: currentUser,
      on: req.db)
  }

  func isFavoriteExercise(req: Request) async throws -> (exerciseID: UUID, isFavorite: Bool) {
    let currentUser = try req.auth.require(User.self)
    let request = try req.content.decode(API.GET.IsFavoriteExercise.self)

    let isFavorite = try await repository.isFavorite(exerciseID: request.exerciseID, for: currentUser, on: req.db)
    return (exerciseID: request.exerciseID, isFavorite: isFavorite)
  }

  func getFavorites(req: Request) async throws -> [Exercise] {
    let currentUser = try req.auth.require(User.self)
    return try await repository.getUserFavorites(currentUser, on: req.db)
  }

  func delete(req: Request) async throws -> HTTPStatus {
    guard let uuidString = req.parameters.get("exerciseID"), let exerciseID = UUID(uuidString: uuidString) else {
      throw Abort(.notFound)
    }

    try await repository.delete(exerciseID, on: req.db)
    return .noContent
  }

  public func getExercisesByGoal(req: Request) async throws -> Response {
    let workoutGoal = try req.query.get(WorkoutGoal.self, at: "goal")
    let exercises = try await repository.getByWorkoutGoal(workoutGoal, on: req.db)
    return try Response.withCacheControl(maxAge: 1800, data: exercises)
  }
}
