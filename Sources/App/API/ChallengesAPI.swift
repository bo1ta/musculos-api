//
//  ChallengesAPI.swift
//  Musculos
//
//  Created by Solomon Alexandru on 05.02.2025.
//

import Vapor

enum ChallengesAPI: EndpointAPI {
  public static let endpoint = "challenges"

  enum POST {
    static let generate: PathComponent = "generate"

    struct GenerateChallengeInput: Content {
      let title: String
      let description: String
      let level: String
      let durationInDays: Int
      let exerciseCategories: [String]
      let exercisesPerDay: Int
      let restDayFrequency: Int
      let equipmentTypes: [String]
    }
  }
}
