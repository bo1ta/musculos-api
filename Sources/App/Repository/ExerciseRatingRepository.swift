//
//  ExerciseRatingRepository.swift
//  Musculos
//
//  Created by Solomon Alexandru on 04.02.2025.
//

import Fluent
import Vapor

// MARK: - ExerciseRatingRepositoryProtocol

protocol ExerciseRatingRepositoryProtocol: Sendable {
  func getForExerciseID(_ exerciseID: UUID, on db: Database) async throws -> [ExerciseRating.Public]
  func getAllForUser(_ user: User, on db: Database) async throws -> [ExerciseRating.Public]
  func addRatingFromContent(_ content: RatingsAPI.POST.CreateExerciseRating, user: User, on db: Database) async throws
}

// MARK: - ExerciseRatingRepository

struct ExerciseRatingRepository: ExerciseRatingRepositoryProtocol {
  func getForExerciseID(_ exerciseID: UUID, on db: Database) async throws -> [ExerciseRating.Public] {
    try await ExerciseRating.query(on: db)
      .filter(\.$exercise.$id == exerciseID)
      .all()
      .map { try $0.asPublic() }
  }

  func getAllForUser(_ user: User, on db: Database) async throws -> [ExerciseRating.Public] {
    try await ExerciseRating.query(on: db)
      .filter(\.$user.$id == user.requireID())
      .all()
      .map { try $0.asPublic() }
  }

  func addRatingFromContent(_ content: RatingsAPI.POST.CreateExerciseRating, user: User, on db: Database) async throws {
    let exerciseRating = ExerciseRating(
      userID: try user.requireID(),
      exerciseID: content.exerciseID,
      rating: content.rating,
      comment: content.comment,
      isPublic: content.isPublic)
    try await exerciseRating.save(on: db)
  }
}
