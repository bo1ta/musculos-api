//
//  ExerciseController.swift
//
//
//  Created by Solomon Alexandru on 06.05.2024.
//

import Fluent
import Vapor

struct ExerciseController: RouteCollection {
  func boot(routes: any RoutesBuilder) throws {
    var exerciseRoutes = routes
      .grouped(
        Token.authenticator(),
        User.guardMiddleware()
      )
      .grouped("exercises")
    
    
    exerciseRoutes.get(use: { try await self.index(req: $0) })
    exerciseRoutes.post(use: { try await self.create(req: $0) })
  }
  
  func index(req: Request) async throws -> [Exercise] {
    try await Exercise.query(on: req.db).all()
  }
  
  func create(req: Request) async throws -> Exercise {
    let exercise = try req.content.decode(Exercise.self)
    
    try await exercise.save(on: req.db)
    return exercise
  }
  
  func delete(req: Request) async throws -> HTTPStatus {
    guard let exercise = try await Exercise.find(req.parameters.get("exerciseID"), on: req.db) else {
      throw Abort(.notFound)
    }
    
    try await exercise.delete(on: req.db)
    return .noContent
  }
}
