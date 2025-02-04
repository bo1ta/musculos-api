//
//  ExercisesAPI.swift
//  Musculos
//
//  Created by Solomon Alexandru on 04.02.2025.
//

import Vapor

enum ExercisesAPI: EndpointAPI {
  public static let endpoint = "exercises"

  enum GET {
    static let getByID: PathComponent = ":exerciseID"
    static let getByGoals: PathComponent = "getByGoals"
    static let filtered: PathComponent = "filtered"

    struct IsFavoriteExercise: Content {
      let exerciseID: UUID
      enum CodingKeys: String, CodingKey {
        case exerciseID = "exercise_id"
      }
    }
  }

  enum POST {
    struct FavoriteExercise: Content {
      let exerciseID: UUID
      let isFavorite: Bool
      enum CodingKeys: String, CodingKey {
        case exerciseID = "exercise_id"
        case isFavorite = "is_favorite"
      }
    }
  }
}
