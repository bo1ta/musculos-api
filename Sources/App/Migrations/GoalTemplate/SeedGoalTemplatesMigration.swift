//
//  SeedGoalTemplatesMigration.swift
//  Musculos
//
//  Created by Solomon Alexandru on 25.10.2024.
//

import Fluent
import Vapor

final class SeedGoalTemplatesMigration: AsyncMigration {
  func prepare(on database: any Database) async throws {
    let templates = [
      GoalTemplate(title: "Lose Weight", description: "Burn fat & get lean", iconName: "rope-icon"),
      GoalTemplate(title: "Get Fitter", description: "Tone up & feel healthy", iconName: "barbell-icon"),
      GoalTemplate(title: "Gain Muscles", description: "Build mass & strength", iconName: "muscle-icon"),
    ]

    for template in templates {
      if try await GoalTemplate.find(template.id, on: database) == nil {
        try await template.save(on: database)
      }
    }
  }

  func revert(on database: any Database) async throws {
    try await GoalTemplate.query(on: database).delete()
  }
}
