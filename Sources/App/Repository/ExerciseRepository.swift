//
//  ExerciseRepository.swift
//  Musculos
//
//  Created by Solomon Alexandru on 04.02.2025.
//

import Fluent
import Vapor

// MARK: - ExerciseRepositoryProtocol

protocol ExerciseRepositoryProtocol: Sendable {
  func getAll(limit: Int, on db: Database) async throws -> [Exercise]
  func getByID(_ id: UUID, on db: Database) async throws -> Exercise?
  func getExerciseForUser(_ user: User, exerciseID: UUID, on db: Database) async throws -> Exercise.Public
  func getExercisesForUser(_ user: User, limit: Int, on db: Database) async throws -> [Exercise.Public]
  func getFiltered(muscle: String?, muscleGroup: String?, name: String?, on db: Database) async throws -> [Exercise]
  func getByCategories(_ categories: [String], limit: Int, on db: Database) async throws -> [Exercise]
  func create(_ exercise: Exercise, on db: Database) async throws -> Exercise
  func delete(_ id: UUID, on db: Database) async throws
  func setIsFavorite(_ exerciseID: UUID, isFavorite: Bool, user: User, on db: Database) async throws -> Exercise
  func isFavorite(exerciseID: UUID, for user: User, on db: Database) async throws -> Bool
  func getUserFavorites(_ user: User, on db: Database) async throws -> [Exercise]
  func getByWorkoutGoal(_ workoutGoal: WorkoutGoal, on db: Database) async throws -> [Exercise.Public]
}

// MARK: - ExerciseRepository

struct ExerciseRepository: ExerciseRepositoryProtocol {
  func getAll(limit: Int, on db: Database) async throws -> [Exercise] {
    try await Exercise.query(on: db).limit(limit).all()
  }

  func getByID(_ id: UUID, on db: Database) async throws -> Exercise? {
    try await Exercise.find(id, on: db)
  }

  func getExercisesForUser(_ user: User, limit: Int, on db: Database) async throws -> [Exercise.Public] {
    try await Exercise.query(on: db)
      .limit(limit)
      .all()
      .asyncMap { exercise in
        let isFavorite = try await user.isExerciseFavorite(exercise, on: db)
        return exercise.asPublic(isFavorite: isFavorite)
      }
  }

  func getExerciseForUser(_ user: User, exerciseID: UUID, on db: Database) async throws -> Exercise.Public {
    guard let exercise = try await Exercise.find(exerciseID, on: db) else {
      throw Abort(.notFound)
    }
    let isFavorite = try await user.$favoriteExercises.isAttached(to: exercise, on: db)
    return exercise.asPublic(isFavorite: isFavorite)
  }

  func getFiltered(muscle: String?, muscleGroup: String?, name: String?, on db: Database) async throws -> [Exercise] {
    var exercises = try await Exercise.query(on: db).all()

    if let muscle {
      exercises = exercises.filter { $0.primaryMuscles.contains(muscle) }
    }

    if let muscleGroup, let muscleGroupType = MuscleGroup(rawValue: muscleGroup.lowercased()) {
      let groupMuscles = muscleGroupType.muscles.map(\.rawValue)
      exercises = exercises.filter { exercise in
        exercise.primaryMuscles.contains { groupMuscles.contains($0) }
      }
    }

    if let name {
      exercises = exercises.filter { $0.name.localizedCaseInsensitiveContains(name) }
    }

    return exercises
  }

  func getByCategories(_ categories: [String], limit: Int, on db: Database) async throws -> [Exercise] {
    try await Exercise.query(on: db)
      .filter(\.$category ~~ categories)
      .limit(limit)
      .all()
  }

  func create(_ exercise: Exercise, on db: Database) async throws -> Exercise {
    try await exercise.save(on: db)
    return exercise
  }

  func delete(_ id: UUID, on db: Database) async throws {
    guard let exercise = try await Exercise.find(id, on: db) else {
      throw Abort(.notFound)
    }
    try await exercise.delete(on: db)
  }

  func setIsFavorite(_ exerciseID: UUID, isFavorite: Bool, user: User, on db: Database) async throws -> Exercise {
    guard let exercise = try await Exercise.find(exerciseID, on: db) else {
      throw Abort(.notFound)
    }

    let isCurrentlyFavorite = try await user.isExerciseFavorite(exercise, on: db)

    if isFavorite, !isCurrentlyFavorite {
      try await user.$favoriteExercises.attach(exercise, on: db)
    } else if isFavorite, isCurrentlyFavorite {
      try await user.$favoriteExercises.detach(exercise, on: db)
    }

    return exercise
  }

  func isFavorite(exerciseID: UUID, for user: User, on db: Database) async throws -> Bool {
    guard let exercise = try await Exercise.find(exerciseID, on: db) else {
      throw Abort(.notFound)
    }
    return try await user.isExerciseFavorite(exercise, on: db)
  }

  func getUserFavorites(_ user: User, on db: Database) async throws -> [Exercise] {
    try await user.$favoriteExercises.get(on: db)
  }

  func getByWorkoutGoal(_ workoutGoal: WorkoutGoal, on db: Database) async throws -> [Exercise.Public] {
    let categories = ExerciseConstants.goalToExerciseCategories[workoutGoal] ?? []

    guard !categories.isEmpty else {
      throw Abort(.notFound)
    }

    return try await Exercise.query(on: db)
      .filter(\.$category ~~ categories)
      .limit(25)
      .all()
      .map {
        $0.asPublic(isFavorite: false)
      }
  }
}
