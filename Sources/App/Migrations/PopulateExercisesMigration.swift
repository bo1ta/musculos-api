//
//  PopulateExercisesMigration.swift
//  
//
//  Created by Solomon Alexandru on 21.07.2024.
//

import Fluent
import Vapor

final class PopulateExercisesMigration: Migration {
  let resourcesDirectory: String

  init(resourcesDirectory: String) {
    self.resourcesDirectory = resourcesDirectory
  }

  func revert(on database: Database) -> EventLoopFuture<Void> {
    return database.eventLoop.makeSucceededVoidFuture()
  }

  func prepare(on database: Database) -> EventLoopFuture<Void> {
    let fileName = "exercises.json"
    let dataFilePath = resourcesDirectory + fileName

    let fileManager = FileManager.default
    guard fileManager.fileExists(atPath: dataFilePath) else {
      return database.eventLoop.future()
    }

    do {
      let data = try Data(contentsOf: URL(fileURLWithPath: dataFilePath))
      let exercises = try Exercise.createArrayFrom(data)

      let futures = exercises.map { exercise in
        exercise.create(on: database)
      }

      return EventLoopFuture<Void>.andAllComplete(futures, on: database.eventLoop)
    } catch {
      return database.eventLoop.makeFailedFuture(error)
    }
  }
}
