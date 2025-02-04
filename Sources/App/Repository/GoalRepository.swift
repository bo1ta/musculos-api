//
//  GoalRepository.swift
//  Musculos
//
//  Created by Solomon Alexandru on 04.02.2025.
//

import Fluent
import Vapor

// MARK: - GoalRepositoryProtocol

protocol GoalRepositoryProtocol: Sendable {
  func getByID(_ goalID: UUID, on db: Database) async throws -> Goal
  func getAllForUser(_ user: User, on db: Database) async throws -> [Goal.Public]
  func addGoalForUser(_ user: User, content: GoalsAPI.POST.CreateGoal, on db: Database) async throws -> Goal
  func addProgressEntry(content: GoalsAPI.POST.CreateProgressEntry, on db: Database) async throws
}

// MARK: - GoalRepository

struct GoalRepository: GoalRepositoryProtocol {
  func getByID(_ goalID: UUID, on db: Database) async throws -> Goal {
    guard let goal = try await Goal.find(goalID, on: db) else {
      throw Abort(.notFound)
    }
    return goal
  }

  func getAllForUser(_ user: User, on db: Database) async throws -> [Goal.Public] {
    let userID = try user.requireID()
    return try await Goal.query(on: db)
      .filter(\.$user.$id == userID)
      .with(\.$user)
      .with(\.$progressEntries)
      .all()
      .map { try $0.asPublic() }
  }

  func addGoalForUser(_ user: User, content: GoalsAPI.POST.CreateGoal, on db: Database) async throws -> Goal {
    let goal = Goal(
      id: content.goalID,
      name: content.name,
      userID: try user.requireID(),
      frequency: content.frequency,
      dateAdded: content.dateAdded,
      endDate: content.endDate,
      isCompleted: content.isCompleted,
      category: content.category,
      targetValue: content.targetValue)
    try await goal.save(on: db)
    return goal
  }

  func addProgressEntry(content: GoalsAPI.POST.CreateProgressEntry, on db: Database) async throws {
    guard let goal = try await Goal.find(content.goalID, on: db) else {
      throw Abort(.notFound, reason: "Goal with ID \(content.goalID) not found")
    }

    let progressEntry = ProgressEntry(dateAdded: content.dateAdded, value: content.value, goalID: try goal.requireID())
    try await progressEntry.save(on: db)
  }
}
