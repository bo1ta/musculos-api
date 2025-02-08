//
//  ChallengeService.swift
//  Musculos
//
//  Created by Solomon Alexandru on 05.02.2025.
//

import Fluent
import Vapor

// MARK: - ChallengeServiceProtocol

protocol ChallengeServiceProtocol: Sendable {
  func generateFromInput(_ input: ChallengesAPI.POST.GenerateChallengeInput) async throws -> WorkoutChallenge
}

// MARK: - ChallengeService

struct ChallengeService: ChallengeServiceProtocol {
  let req: Request

  init(req: Request) {
    self.req = req
  }

  func generateFromInput(_ input: ChallengesAPI.POST.GenerateChallengeInput) async throws -> WorkoutChallenge {
    let exercises = try await req.exerciseService.getByLevel(
      input.level,
      categories: input.exerciseCategories,
      equipmentTypes: input.equipmentTypes)

    return try await req.db.transaction { transaction in
      let challenge = try await createWorkoutChallenge(from: input, on: transaction)

      try await generateDailyWorkouts(for: challenge, exercises: exercises, input: input, on: transaction)

      try await challenge.$dailyWorkouts.load(on: transaction)

      for dailyWorkout in challenge.dailyWorkouts {
        try await dailyWorkout.$workoutExercises.load(on: transaction)
      }

      return challenge
    }
  }
}

// MARK: - Helper methods

extension ChallengeService {
  private func createWorkoutChallenge(
    from input: ChallengesAPI.POST.GenerateChallengeInput,
    on db: Database)
    async throws -> WorkoutChallenge
  {
    let challenge = WorkoutChallenge(
      title: input.title,
      description: input.description,
      level: input.level,
      durationInDays: input.durationInDays,
      currentDay: 0,
      startDate: nil,
      completionDate: nil)
    try await challenge.save(on: db)
    return challenge
  }

  private func generateDailyWorkouts(
    for challenge: WorkoutChallenge,
    exercises: [Exercise],
    input: ChallengesAPI.POST.GenerateChallengeInput,
    on db: Database)
    async throws
  {
    for day in 1...input.durationInDays {
      let isRestDay = day % input.restDayFrequency == 0

      let dailyWorkout = try DailyWorkout(workoutChallengeID: challenge.requireID(), dayNumber: day, isRestDay: isRestDay)
      try await dailyWorkout.save(on: db)

      if !isRestDay {
        try await addExercisesToDailyWorkout(exercises, dailyWorkout: dailyWorkout, input: input, on: db)
      }
    }
  }

  private func addExercisesToDailyWorkout(
    _ exercises: [Exercise],
    dailyWorkout: DailyWorkout,
    input: ChallengesAPI.POST.GenerateChallengeInput,
    on db: Database)
    async throws
  {
    let shuffledExercises = exercises.shuffled()
    let dayExercises = Array(shuffledExercises.prefix(input.exercisesPerDay))

    var workoutExercises: [WorkoutExercise] = []
    for exercise in dayExercises {
      let workoutExercise = try WorkoutExercise(
        dailyWorkoutID: dailyWorkout.requireID(),
        exerciseID: exercise.requireID(),
        numberOfReps: generateReps(level: input.level),
        isCompleted: false,
        minValue: generateMinValue(level: input.level),
        maxValue: generateMaxValue(level: input.level),
        measurement: determineMeasurement(for: exercise))
      workoutExercises.append(workoutExercise)
    }

    try await workoutExercises.create(on: db)
  }

  // MARK: Utility methods

  private func generateReps(level: String) -> Int {
    switch level {
    case "beginner":
      Int.random(in: 5...12)
    case "intermediate":
      Int.random(in: 8...15)
    case "advanced":
      Int.random(in: 12...20)
    default:
      10
    }
  }

  private func generateMinValue(level: String) -> Int {
    switch level {
    case "beginner":
      5
    case "intermediate":
      10
    case "advanced":
      15
    default:
      5
    }
  }

  private func generateMaxValue(level: String) -> Int {
    switch level {
    case "beginner":
      15
    case "intermediate":
      25
    case "advanced":
      35
    default:
      15
    }
  }

  private func determineMeasurement(for exercise: Exercise) -> String {
    if exercise.category.contains("cardio") {
      "minutes"
    } else if exercise.equipment?.contains("dumbbell") ?? false {
      "lbs"
    } else {
      "reps"
    }
  }
}
