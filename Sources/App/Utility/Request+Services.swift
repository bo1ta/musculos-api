//
//  Request+Services.swift
//  Musculos
//
//  Created by Solomon Alexandru on 05.02.2025.
//

import Vapor

extension Request {
  var userService: UserServiceProtocol {
    UserService(req: self)
  }

  var exerciseService: ExerciseServiceProtocol {
    ExerciseService(req: self)
  }

  var exerciseSessionService: ExerciseSessionServiceProtocol {
    ExerciseSessionService(req: self)
  }

  var goalService: GoalServiceProtocol {
    GoalService(req: self)
  }

  var ratingService: RatingServiceProtocol {
    RatingService(req: self)
  }

  var challengeService: ChallengeServiceProtocol {
    ChallengeService(req: self)
  }
}
