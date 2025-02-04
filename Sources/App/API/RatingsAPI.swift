//
//  RatingsAPI.swift
//  Musculos
//
//  Created by Solomon Alexandru on 04.02.2025.
//

import Vapor

enum RatingsAPI: EndpointAPI {
  public static let endpoint = "ratings"

  enum GET {
    static let getByExerciseID: PathComponent = ":exerciseID"
  }

  enum POST {
    struct CreateExerciseRating: Content {
      let ratingID: UUID
      let exerciseID: UUID
      let rating: Double
      let comment: String?
      let isPublic: Bool
    }
  }
}
