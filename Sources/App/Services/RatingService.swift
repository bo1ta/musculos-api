//
//  RatingService.swift
//  Musculos
//
//  Created by Solomon Alexandru on 04.02.2025.
//

import Fluent
import Vapor

// MARK: - RatingServiceProtocol

protocol RatingServiceProtocol: Sendable {
  func getForExerciseID(_ exerciseID: UUID) async throws -> [ExerciseRating.Public]
  func getAllForUser(_ user: User) async throws -> [ExerciseRating.Public]
  func addRatingFromContent(_ content: RatingsAPI.POST.CreateExerciseRating, user: User) async throws
}

// MARK: - RatingService

struct RatingService: RatingServiceProtocol {
  let req: Request

  init(req: Request) {
    self.req = req
  }

  func getForExerciseID(_ exerciseID: UUID) async throws -> [ExerciseRating.Public] {
    try await ExerciseRating.query(on: req.db)
      .filter(\.$exercise.$id == exerciseID)
      .all()
      .map { try $0.asPublic() }
  }

  func getAllForUser(_ user: User) async throws -> [ExerciseRating.Public] {
    try await ExerciseRating.query(on: req.db)
      .filter(\.$user.$id == user.requireID())
      .all()
      .map { try $0.asPublic() }
  }

  func addRatingFromContent(_ content: RatingsAPI.POST.CreateExerciseRating, user: User) async throws {
    let exerciseRating = ExerciseRating(
      userID: try user.requireID(),
      exerciseID: content.exerciseID,
      rating: content.rating,
      comment: content.comment,
      isPublic: content.isPublic)
    try await exerciseRating.save(on: req.db)
  }
}
