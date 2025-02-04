//
//  ExerciseSessionsAPI.swift
//  Musculos
//
//  Created by Solomon Alexandru on 04.02.2025.
//

import Vapor

enum ExerciseSessionsAPI: EndpointAPI {
  public static let endpoint = "exercise-session"

  enum POST {
    struct CreateExerciseSession: Content {
      var dateAdded: Date
      var duration: Double
      var exerciseID: UUID
      var sessionID: UUID
    }
  }
}
