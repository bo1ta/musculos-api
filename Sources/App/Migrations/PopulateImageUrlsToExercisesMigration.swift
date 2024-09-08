//
//  PopulateImageUrlsToExercisesMigration.swift
//  
//
//  Created by Solomon Alexandru on 08.09.2024.
//

import Fluent

final class PopulateImageUrlsToExercisesMigration: Migration {
  func prepare(on database: Database) -> EventLoopFuture<Void> {
    return Exercise.query(on: database).all().flatMap { exercises in
      let updateFutures: [EventLoopFuture<Void>] = exercises.map { exercise in
        let formattedName = self.formatExerciseName(exercise.name)
        let imageUrls = [
          "http://49.13.172.88/images/\(formattedName)/0.jpg",
          "http://49.13.172.88/images/\(formattedName)/1.jpg"
        ]
        exercise.imageUrls = imageUrls
        return exercise.update(on: database)
      }

      // Return a future that completes when all updates are done
      return EventLoopFuture.andAllSucceed(updateFutures, on: database.eventLoop).transform(to: ())
    }
  }

  private func formatExerciseName(_ name: String) -> String {
    return name.lowercased()
      .replacingOccurrences(of: " ", with: "_")
      .replacingOccurrences(of: "/", with: "_")
  }

  func revert(on database: Database) -> EventLoopFuture<Void> {
    return database.eventLoop.makeSucceededVoidFuture()
  }
}

