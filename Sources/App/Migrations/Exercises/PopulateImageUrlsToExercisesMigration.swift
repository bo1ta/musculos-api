//
//  PopulateImageUrlsToExercisesMigration.swift
//  
//
//  Created by Solomon Alexandru on 08.09.2024.
//

import Fluent

final class PopulateImageUrlsToExercisesMigration: AsyncMigration {
  func prepare(on database: Database) async throws {
    try await Exercise.query(on: database).all().asyncForEach { exercise in
      let formattedName = self.formatExerciseName(exercise.name)
      let imageUrls = [
        "http://49.13.172.88/images/\(formattedName)/0.jpg",
        "http://49.13.172.88/images/\(formattedName)/1.jpg"
      ]
      exercise.imageUrls = imageUrls
      return try await exercise.update(on: database)
    }
  }

  private func formatExerciseName(_ name: String) -> String {
    return name.lowercased()
      .replacingOccurrences(of: " ", with: "_")
      .replacingOccurrences(of: "/", with: "_")
  }

  func revert(on database: Database) async {
  }
}

