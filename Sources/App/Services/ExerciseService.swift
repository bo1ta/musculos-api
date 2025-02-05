//
//  ExerciseService.swift
//  Musculos
//
//  Created by Solomon Alexandru on 04.02.2025.
//

import Fluent
import Vapor

// MARK: - ExerciseServiceProtocol

protocol ExerciseServiceProtocol: Sendable {
  func getAll(limit: Int) async throws -> [Exercise]
  func getByID(_ id: UUID) async throws -> Exercise?
  func getExerciseForUser(_ user: User, exerciseID: UUID) async throws -> Exercise.Public
  func getExercisesForUser(_ user: User, limit: Int) async throws -> [Exercise.Public]
  func getFiltered(muscle: String?, muscleGroup: String?, name: String?) async throws -> [Exercise]
  func getByCategories(_ categories: [String], limit: Int) async throws -> [Exercise]
  func create(_ exercise: Exercise) async throws -> Exercise
  func delete(_ id: UUID) async throws
  func setIsFavorite(_ exerciseID: UUID, isFavorite: Bool, user: User) async throws -> Exercise
  func isFavorite(exerciseID: UUID, for user: User) async throws -> Bool
  func getUserFavorites(_ user: User) async throws -> [Exercise]
  func getByWorkoutGoal(_ workoutGoal: WorkoutGoal) async throws -> [Exercise.Public]
  func getByLevel(_ level: String, categories: [String], equipmentTypes: [String]) async throws -> [Exercise]
}

// MARK: - ExerciseService

struct ExerciseService: ExerciseServiceProtocol {
  let req: Request

  init(req: Request) {
    self.req = req
  }

  func getAll(limit: Int) async throws -> [Exercise] {
    try await Exercise.query(on: req.db).limit(limit).all()
  }

  func getByID(_ id: UUID) async throws -> Exercise? {
    try await Exercise.find(id, on: req.db)
  }

  func getExercisesForUser(_ user: User, limit: Int) async throws -> [Exercise.Public] {
    try await Exercise.query(on: req.db)
      .limit(limit)
      .all()
      .asyncMap { exercise in
        let isFavorite = try await user.isExerciseFavorite(exercise, on: req.db)
        return exercise.asPublic(isFavorite: isFavorite)
      }
  }

  func getExerciseForUser(_ user: User, exerciseID: UUID) async throws -> Exercise.Public {
    guard let exercise = try await Exercise.find(exerciseID, on: req.db) else {
      throw Abort(.notFound)
    }
    let isFavorite = try await user.$favoriteExercises.isAttached(to: exercise, on: req.db)
    return exercise.asPublic(isFavorite: isFavorite)
  }

  func getFiltered(muscle: String?, muscleGroup: String?, name: String?) async throws -> [Exercise] {
    var exercises = try await Exercise.query(on: req.db).all()

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

  func getByCategories(_ categories: [String], limit: Int) async throws -> [Exercise] {
    try await Exercise.query(on: req.db)
      .filter(\.$category ~~ categories)
      .limit(limit)
      .all()
  }

  func create(_ exercise: Exercise) async throws -> Exercise {
    try await exercise.save(on: req.db)
    return exercise
  }

  func delete(_ id: UUID) async throws {
    guard let exercise = try await Exercise.find(id, on: req.db) else {
      throw Abort(.notFound)
    }
    try await exercise.delete(on: req.db)
  }

  func setIsFavorite(_ exerciseID: UUID, isFavorite: Bool, user: User) async throws -> Exercise {
    guard let exercise = try await Exercise.find(exerciseID, on: req.db) else {
      throw Abort(.notFound)
    }

    let isCurrentlyFavorite = try await user.isExerciseFavorite(exercise, on: req.db)

    if isFavorite, !isCurrentlyFavorite {
      try await user.$favoriteExercises.attach(exercise, on: req.db)
    } else if isFavorite, isCurrentlyFavorite {
      try await user.$favoriteExercises.detach(exercise, on: req.db)
    }

    return exercise
  }

  func isFavorite(exerciseID: UUID, for user: User) async throws -> Bool {
    guard let exercise = try await Exercise.find(exerciseID, on: req.db) else {
      throw Abort(.notFound)
    }
    return try await user.isExerciseFavorite(exercise, on: req.db)
  }

  func getUserFavorites(_ user: User) async throws -> [Exercise] {
    try await user.$favoriteExercises.get(on: req.db)
  }

  func getByWorkoutGoal(_ workoutGoal: WorkoutGoal) async throws -> [Exercise.Public] {
    let categories = ExerciseConstants.goalToExerciseCategories[workoutGoal] ?? []

    guard !categories.isEmpty else {
      throw Abort(.notFound)
    }

    return try await Exercise.query(on: req.db)
      .filter(\.$category ~~ categories)
      .limit(25)
      .all()
      .map {
        $0.asPublic(isFavorite: false)
      }
  }

  func getByLevel(_ level: String, categories: [String], equipmentTypes: [String]) async throws -> [Exercise] {
    try await Exercise.query(on: req.db)
      .filter(\.$level == level)
      .filter(\.$category ~~ categories)
      .filter(\.$equipment ~~ equipmentTypes)
      .all()
  }
}
