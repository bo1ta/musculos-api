//
//  GoalController.swift
//  Musculos
//
//  Created by Solomon Alexandru on 25.10.2024.
//

import Vapor
import Fluent

struct GoalController: RouteCollection {
  func boot(routes: any RoutesBuilder) throws {
    let route = routes.apiV1Group("goals")
      .grouped(Token.authenticator())

    route.get(use: { try await self.index(req: $0) })
    route.get(":goalID", use: { try await self.getByID(req: $0) })

    route.post(use: { try await self.create(req: $0) })
    route.post("update-progress", use: { try await self.addProgressEntry(req: $0) })
  }

  func index(req: Request) async throws -> [Goal.Public] {
    let currentUser = try req.auth.require(User.self)
    return try await Goal.query(on: req.db)
      .filter(\.$user.$id  == currentUser.id!)
      .with(\.$user)
      .with(\.$progressEntries)
      .all()
      .map { try $0.asPublic() }
  }

  func getByID(req: Request) async throws -> Goal {
    try req.auth.require(User.self)
    guard let goalID = req.parameters.get("goalID", as: UUID.self) else {
      throw Abort(.badRequest)
    }

    guard let goal = try await Goal.find(goalID, on: req.db) else {
      throw Abort(.badRequest)
    }

    return goal
  }

  func create(req: Request) async throws -> Goal {
    let currentUser = try req.auth.require(User.self)
    let content = try req.content.decode(CreateContent.self)
    let goal =  Goal(
      id: content.goalID,
      name: content.name,
      userID: try currentUser.requireID(),
      frequency: content.frequency,
      dateAdded: content.dateAdded,
      endDate: content.endDate,
      isCompleted: content.isCompleted,
      category: content.category,
      targetValue: content.targetValue
    )
    try await goal.save(on: req.db)
    return goal
  }

  func addProgressEntry(req: Request) async throws -> HTTPStatus {
    let content = try req.content.decode(AddProgressEntryContent.self)
    guard let goal = try await Goal.find(content.goalID, on: req.db) else {
      throw Abort(.notFound, reason: "Goal with ID \(content.goalID) not found")
    }

    let progressEntry = ProgressEntry(dateAdded: content.dateAdded, value: content.value, goalID: try goal.requireID())
    try await progressEntry.save(on: req.db)
    return .created
  }

  private struct CreateContent: Content {
    var goalID: UUID
    var name: String
    var userID: UUID
    var frequency: String
    var dateAdded: Date
    var endDate: Date?
    var isCompleted: Bool
    var category: String?
    var targetValue: Int?
  }

  private struct AddProgressEntryContent: Content {
    var goalID: UUID
    var dateAdded: Date
    var value: Double
  }
}
