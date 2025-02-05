//
//  GoalController.swift
//  Musculos
//
//  Created by Solomon Alexandru on 25.10.2024.
//

import Fluent
import Vapor

struct GoalController: RouteCollection {
  typealias API = GoalsAPI

  func boot(routes: any RoutesBuilder) throws {
    let route = routes.apiV1Group(API.endpoint)
      .grouped(Token.authenticator())

    route.get(use: { try await self.index(req: $0) })
    route.get(API.GET.getByID, use: { try await self.getByID(req: $0) })

    route.post(use: { try await self.create(req: $0) })
    route.post(API.POST.updateProgress, use: { try await self.addProgressEntry(req: $0) })
  }

  func index(req: Request) async throws -> [Goal.Public] {
    let currentUser = try req.auth.require(User.self)
    return try await req.goalService.getAllForUser(currentUser)
  }

  func getByID(req: Request) async throws -> Goal {
    guard let goalID = req.parameters.get("goalID", as: UUID.self) else {
      throw Abort(.badRequest)
    }
    return try await req.goalService.getByID(goalID)
  }

  func create(req: Request) async throws -> Goal {
    let currentUser = try req.auth.require(User.self)
    let request = try req.content.decode(API.POST.CreateGoal.self)
    return try await req.goalService.addGoalForUser(currentUser, content: request)
  }

  func addProgressEntry(req: Request) async throws -> HTTPStatus {
    let content = try req.content.decode(API.POST.CreateProgressEntry.self)
    try await req.goalService.addProgressEntry(content: content)
    return .created
  }
}
