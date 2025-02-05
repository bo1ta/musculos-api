//
//  WorkoutChallengeController.swift
//  Musculos
//
//  Created by Solomon Alexandru on 19.01.2025.
//

import Fluent
import Vapor

// MARK: - WorkoutChallengeController

struct WorkoutChallengeController: RouteCollection {
  typealias API = ChallengesAPI

  func boot(routes: any RoutesBuilder) throws {
    let route = routes.apiV1Group(API.endpoint)
      .grouped(Token.authenticator())

    route.post(API.POST.generate, use: { try await self.generateWorkoutChallenge(req: $0) })
  }

  func generateWorkoutChallenge(req: Request) async throws -> WorkoutChallenge {
    let jsonInput = """
      {
          "title": "30-Day Full Body Challenge",
          "description": "A comprehensive full-body workout program",
          "level": "intermediate",
          "durationInDays": 30,
          "exerciseCategories": ["strength", "cardio", "flexibility"],
          "equipmentTypes": ["dumbbell", "barbell"],
          "exercisesPerDay": 5,
          "restDayFrequency": 7
      }
      """
    let input = try JSONDecoder().decode(API.POST.GenerateChallengeInput.self, from: jsonInput.data(using: .utf8)!)
    return try await req.challengeService.generateFromInput(input)
  }
}
