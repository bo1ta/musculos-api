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
    let exercises = try await req.exerciseService.getExercisesForUser(currentUser, limit: 20)
    return try Response.withCacheControl(maxAge: Constants.defaultCacheAge, data: exercises)
  }

  func getByID(req: Request) async throws -> Exercise.Public {
    let currentUser = try req.auth.require(User.self)

    guard let exerciseID = req.parameters.get("exerciseID", as: UUID.self) else {
      throw Abort(.badRequest)
    }
    return try await req.exerciseService.getExerciseForUser(currentUser, exerciseID: exerciseID)
  }

  func getFilteredExercises(req: Request) async throws -> Response {
    let muscle = req.query["muscle"] as String?
    let muscleGroup = req.query["muscleGroup"] as String?
    let name = req.query["name"] as String?

    guard muscle != nil || muscleGroup != nil || name != nil else {
      throw Abort(.badRequest, reason: "At least one filter parameter (muscle, muscleGroup, or name) is required.")
    }

    let exercises = try await req.exerciseService.getFiltered(muscle: muscle, muscleGroup: muscleGroup, name: name)
    return try Response.withCacheControl(maxAge: Constants.defaultCacheAge, data: exercises)
  }

  func create(req: Request) async throws -> Exercise {
    let exercise = try req.content.decode(Exercise.self)
    return try await req.exerciseService.create(exercise)
  }

  func favoriteExercise(req: Request) async throws -> Exercise {
    let currentUser = try req.auth.require(User.self)
    let favoriteRequest = try req.content.decode(API.POST.FavoriteExercise.self)

    return try await req.exerciseService.setIsFavorite(
      favoriteRequest.exerciseID,
      isFavorite: favoriteRequest.isFavorite,
      user: currentUser)
  }

  func isFavoriteExercise(req: Request) async throws -> (exerciseID: UUID, isFavorite: Bool) {
    let currentUser = try req.auth.require(User.self)
    let request = try req.content.decode(API.GET.IsFavoriteExercise.self)

    let isFavorite = try await req.exerciseService.isFavorite(exerciseID: request.exerciseID, for: currentUser)
    return (exerciseID: request.exerciseID, isFavorite: isFavorite)
  }

  func getFavorites(req: Request) async throws -> [Exercise] {
    let currentUser = try req.auth.require(User.self)
    return try await req.exerciseService.getUserFavorites(currentUser)
  }

  func delete(req: Request) async throws -> HTTPStatus {
    guard let uuidString = req.parameters.get("exerciseID"), let exerciseID = UUID(uuidString: uuidString) else {
      throw Abort(.notFound)
    }

    try await req.exerciseService.delete(exerciseID)
    return .noContent
  }

  public func getExercisesByGoal(req: Request) async throws -> Response {
    let workoutGoal = try req.query.get(WorkoutGoal.self, at: "goal")
    let exercises = try await req.exerciseService.getByWorkoutGoal(workoutGoal)
    return try Response.withCacheControl(maxAge: 1800, data: exercises)
  }
}
