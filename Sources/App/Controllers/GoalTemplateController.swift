//
//  GoalTemplateController.swift
//  Musculos
//
//  Created by Solomon Alexandru on 26.10.2024.
//

import Fluent
import Vapor

struct GoalTemplateController: RouteCollection {
  func boot(routes: any RoutesBuilder) throws {
    let route = routes.apiV1Group("templates")
      .grouped("goals")

    route.get(use: { try await self.index(req: $0) })
  }

  func index(req: Request) async throws -> [GoalTemplate] {
    try await GoalTemplate.query(on: req.db).all()
  }
}
