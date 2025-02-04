//
//  ExerciseSessionRepository.swift
//  Musculos
//
//  Created by Solomon Alexandru on 04.02.2025.
//

import Vapor
import Fluent

protocol ExerciseSessionRepositoryProtocol: Sendable {
  func getAllForUser(_ user: User, on db: Database) async throws -> [ExerciseSession.Public]
  func createExerciseSession(_ sessionID: UUID, dateAdded: Date, duration: Double, exerciseID: UUID, user: User, on db: Database) async throws -> UserExperienceEntry
}

struct ExerciseSessionRepository: ExerciseSessionRepositoryProtocol {
  func getAllForUser(_ user: User, on db: Database) async throws -> [ExerciseSession.Public] {
    let userID = try user.requireID()
    return try await ExerciseSession.query(on: db)
      .filter(\.$user.$id == userID)
      .with(\.$user)
      .with(\.$exercise)
      .all()
      .map { try $0.asPublic() }
  }
  
  func createExerciseSession(_ sessionID: UUID, dateAdded: Date, duration: Double, exerciseID: UUID, user: User, on db: Database) async throws -> UserExperienceEntry {
    let session = ExerciseSession(id: sessionID, dateAdded: dateAdded, duration: duration, userID: try user.requireID(), exerciseID: exerciseID)
    try await session.save(on: db)

    try await session.$user.load(on: db)
    try await session.$exercise.load(on: db)

    return try await ExperienceService.updateUserExperience(for: session, on: db)
  }
}
