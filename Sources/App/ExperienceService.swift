//
//  ExperienceService.swift
//  Musculos
//
//  Created by Solomon Alexandru on 15.12.2024.
//

import Fluent
import Vapor

enum ExperienceService {
  static func updateUserExperience(for session: ExerciseSession, req: Request) async throws -> UserExperienceEntry {
    let userExperience = try await UserExperience.query(on: req.db)
      .filter(\.$user.$id == session.user.id!)
      .first()

    if userExperience == nil {
      let newUserExperience = UserExperience()
      newUserExperience.$user.id = session.user.id!
      newUserExperience.totalExperience = 0
      try await newUserExperience.save(on: req.db)

      let xpEntry = UserExperienceEntry()
      xpEntry.$exerciseSession.id = try session.requireID()
      xpEntry.$userExperience.id = try newUserExperience.requireID()
      xpEntry.xpGained = calculateExperience(for: session.exercise, session: session)

      try await xpEntry.save(on: req.db)

      newUserExperience.totalExperience += xpEntry.xpGained
      try await newUserExperience.save(on: req.db)

      try await xpEntry.$userExperience.load(on: req.db)
      return xpEntry
    } else {
      let xpEntry = UserExperienceEntry()
      xpEntry.$exerciseSession.id = try session.requireID()
      xpEntry.$userExperience.id = try userExperience!.requireID()
      xpEntry.xpGained = calculateExperience(for: session.exercise, session: session)

      try await xpEntry.save(on: req.db)

      userExperience!.totalExperience += xpEntry.xpGained
      try await userExperience!.save(on: req.db)

      try await xpEntry.$userExperience.load(on: req.db)
      return xpEntry
    }
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
