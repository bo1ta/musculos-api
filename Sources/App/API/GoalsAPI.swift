//
//  GoalsAPI.swift
//  Musculos
//
//  Created by Solomon Alexandru on 04.02.2025.
//

import Vapor

enum GoalsAPI: EndpointAPI {
  public static let endpoint = "goals"

  enum GET {
    static let getByID: PathComponent = ":goalID"
  }

  enum POST {
    static let updateProgress: PathComponent = "update-progress"

    struct CreateGoal: Content {
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

    struct CreateProgressEntry: Content {
      var goalID: UUID
      var dateAdded: Date
      var value: Double
    }
  }
}
