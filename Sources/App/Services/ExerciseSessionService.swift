//
//  ExerciseSessionService.swift
//  Musculos
//
//  Created by Solomon Alexandru on 04.02.2025.
//

import Fluent
import Vapor

// MARK: - ExerciseSessionServiceProtocol

protocol ExerciseSessionServiceProtocol: Sendable {
  func getAllForUser(_ user: User) async throws -> [ExerciseSession.Public]
  func createExerciseSession(
    _ sessionID: UUID,
    dateAdded: Date,
    duration: Double,
    exerciseID: UUID,
    user: User) async throws -> UserExperienceEntry
}

// MARK: - ExerciseSessionService

struct ExerciseSessionService: ExerciseSessionServiceProtocol {
  let req: Request

  init(req: Request) {
    self.req = req
  }

  func getAllForUser(_ user: User) async throws -> [ExerciseSession.Public] {
    let userID = try user.requireID()
    return try await ExerciseSession.query(on: req.db)
      .filter(\.$user.$id == userID)
      .with(\.$user)
      .with(\.$exercise)
      .all()
      .map { try $0.asPublic() }
  }

  func createExerciseSession(
    _ sessionID: UUID,
    dateAdded: Date,
    duration: Double,
    exerciseID: UUID,
    user: User)
    async throws -> UserExperienceEntry
  {
    let session = ExerciseSession(
      id: sessionID,
      dateAdded: dateAdded,
      duration: duration,
      userID: try user.requireID(),
      exerciseID: exerciseID)
    try await session.save(on: req.db)

    try await session.$user.load(on: req.db)
    try await session.$exercise.load(on: req.db)

    return try await ExperienceService.updateUserExperience(for: session, on: req.db)
  }
}
