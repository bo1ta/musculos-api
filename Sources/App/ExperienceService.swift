//
//  ExperienceService.swift
//  Musculos
//
//  Created by Solomon Alexandru on 15.12.2024.
//

import Fluent
import Vapor

enum ExperienceService {
  static func updateUserExperience(for session: ExerciseSession, on db: Database) async throws -> UserExperienceEntry {
    let userExperience = try await fetchOrCreateUserExperience(for: session.user, on: db)
    let xpEntry = try await createExperienceEntry(for: session, userExperience: userExperience, on: db)

    userExperience.totalExperience += xpEntry.xpGained
    try await userExperience.save(on: db)

    try await xpEntry.$userExperience.load(on: db)
    return xpEntry
  }

  private static func fetchOrCreateUserExperience(for user: User, on db: Database) async throws -> UserExperience {
    if let existingExperience = try await UserExperience.query(on: db)
      .filter(\.$user.$id == user.id!)
      .first() {
      return existingExperience
    } else {
      let userExperience = UserExperience()
      userExperience.$user.id = try user.requireID()
      userExperience.totalExperience = 0
      try await userExperience.save(on: db)
      return userExperience
    }
  }

  private static func createExperienceEntry(for session: ExerciseSession, userExperience: UserExperience, on db: Database) async throws -> UserExperienceEntry {
    let xpEntry = UserExperienceEntry(userExperienceID: try userExperience.requireID(), exerciseSessionID: try session.requireID(), xpGained: calculateExperience(for: session.exercise, session: session))
    try await xpEntry.save(on: db)
    return xpEntry
  }

  private static func calculateExperience(for exercise: Exercise, session: ExerciseSession) -> Int {
    var xp = 10

    switch exercise.level.lowercased() {
    case "beginner": xp *= 1
    case "intermediate": xp *= 2
    case "expert": xp *= 3
    default: break
    }

    let durationBonus = Int(session.duration / 10.0)
    return xp + durationBonus
  }
}
