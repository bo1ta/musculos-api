//
//  GoalService.swift
//  Musculos
//
//  Created by Solomon Alexandru on 04.02.2025.
//

import Fluent
import Vapor

// MARK: - GoalServiceProtocol

protocol GoalServiceProtocol: Sendable {
  func getByID(_ goalID: UUID) async throws -> Goal
  func getAllForUser(_ user: User) async throws -> [Goal.Public]
  func addGoalForUser(_ user: User, content: GoalsAPI.POST.CreateGoal) async throws -> Goal
  func addProgressEntry(content: GoalsAPI.POST.CreateProgressEntry) async throws
}

// MARK: - GoalService

struct GoalService: GoalServiceProtocol {
  let req: Request

  init(req: Request) {
    self.req = req
  }

  func getByID(_ goalID: UUID) async throws -> Goal {
    guard let goal = try await Goal.find(goalID, on: req.db) else {
      throw Abort(.notFound)
    }
    return goal
  }

  func getAllForUser(_ user: User) async throws -> [Goal.Public] {
    let userID = try user.requireID()
    return try await Goal.query(on: req.db)
      .filter(\.$user.$id == userID)
      .with(\.$user)
      .with(\.$progressEntries)
      .all()
      .map { try $0.asPublic() }
  }

  func addGoalForUser(_ user: User, content: GoalsAPI.POST.CreateGoal) async throws -> Goal {
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
    try await goal.save(on: req.db)
    return goal
  }

  func addProgressEntry(content: GoalsAPI.POST.CreateProgressEntry) async throws {
    guard let goal = try await Goal.find(content.goalID, on: req.db) else {
      throw Abort(.notFound, reason: "Goal with ID \(content.goalID) not found")
    }

    let progressEntry = ProgressEntry(dateAdded: content.dateAdded, value: content.value, goalID: try goal.requireID())
    try await progressEntry.save(on: req.db)
  }
}
