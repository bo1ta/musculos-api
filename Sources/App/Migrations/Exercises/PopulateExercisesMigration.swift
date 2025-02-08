//
//  PopulateExercisesMigration.swift
//
//
//  Created by Solomon Alexandru on 21.07.2024.
//

import Fluent
import Vapor

final class PopulateExercisesMigration: AsyncMigration {
  let resourcesDirectory: String

  init(resourcesDirectory: String) {
    self.resourcesDirectory = resourcesDirectory
  }

  func revert(on _: Database) async throws { }

  func prepare(on database: Database) async throws {
    let fileName = "exercises.json"
    let dataFilePath = resourcesDirectory + fileName

    let fileManager = FileManager.default
    guard fileManager.fileExists(atPath: dataFilePath) else {
      throw Abort(.badGateway)
    }

    do {
      let data = try Data(contentsOf: URL(fileURLWithPath: dataFilePath))
      let exercises = try Exercise.createArrayFrom(data)
      try await exercises.create(on: database)
    } catch {
      throw Abort(.notFound)
    }
  }
}
