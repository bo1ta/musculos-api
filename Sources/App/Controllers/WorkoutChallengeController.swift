//
//  WorkoutChallengeController.swift
//  Musculos
//
//  Created by Solomon Alexandru on 19.01.2025.
//

import Fluent
import Vapor

// MARK: - WorkoutChallengeController

struct WorkoutChallengeController: RouteCollection {
  func boot(routes: any RoutesBuilder) throws {
    let route = routes.apiV1Group("challenges")
      .grouped(Token.authenticator())

    route.get(use: { try await self.index(req: $0) })
    route.post("generate", use: { try await self.generateFromJSON(req: $0) })
  }

  func index(req _: Request) async throws -> HTTPResponseStatus {
    .ok
  }

  func generateFromJSON(req: Request) async throws -> WorkoutChallenge {
    let jsonInput = """
      {
          "title": "30-Day Full Body Challenge",
          "description": "A comprehensive full-body workout program",
          "level": "intermediate",
          "durationInDays": 30,
          "exerciseCategories": ["strength", "cardio", "flexibility"],
          "exercisesPerDay": 5,
          "restDayFrequency": 7
      }
      """

    let decoder = JSONDecoder()
    let input = try decoder.decode(WorkoutChallengeInput.self, from: jsonInput.data(using: .utf8)!)
    return try await WorkoutChallenge.generate(from: input, on: req.db)
  }
}

// MARK: - WorkoutChallengeInput

struct WorkoutChallengeInput: Codable, DecodableModel {
  let title: String
  let description: String
  let level: String
  let durationInDays: Int
  let exerciseCategories: [String]
  let exercisesPerDay: Int
  let restDayFrequency: Int // e.g., 1 rest day every X days
}

extension WorkoutChallenge {
  static func generate(
    from input: WorkoutChallengeInput,
    on database: Database)
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
    try await challenge.save(on: database)

    // Fetch suitable exercises from the database
    let exercises = try await Exercise.query(on: database)
      .filter(\.$level == input.level)
      .filter(\.$category ~~ input.exerciseCategories)
      .all()

    guard !exercises.isEmpty else {
      throw Abort(.notFound, reason: "No exercises found matching the specified criteria")
    }

    var dailyWorkouts: [DailyWorkout] = []

    // Generate daily workouts
    for day in 1...input.durationInDays {
      let isRestDay = day % input.restDayFrequency == 0

      let dailyWorkout = try DailyWorkout(workoutChallengeID: challenge.requireID(), dayNumber: day, isRestDay: isRestDay)

      try await dailyWorkout.save(on: database)
      dailyWorkouts.append(dailyWorkout)

      if !isRestDay {
        // Randomly select exercises for this day
        let shuffledExercises = exercises.shuffled()
        let dayExercises = Array(shuffledExercises.prefix(input.exercisesPerDay))

        for exercise in dayExercises {
          let workoutExercise = try WorkoutExercise(
            dailyWorkoutID: dailyWorkout.requireID(),
            exerciseID: exercise.requireID(),
            numberOfReps: generateReps(for: exercise, level: input.level),
            isCompleted: false,
            minValue: generateMinValue(for: exercise, level: input.level),
            maxValue: generateMaxValue(for: exercise, level: input.level),
            measurement: determineMeasurement(for: exercise))

          try await workoutExercise.create(on: database)
        }
      }
    }

    challenge.dailyWorkouts = dailyWorkouts

    return challenge
  }

  private static func generateReps(for _: Exercise, level: String) -> Int {
    // Custom logic to determine appropriate number of reps based on exercise type and level
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

  private static func generateMinValue(for _: Exercise, level: String) -> Int {
    // Custom logic for minimum values (e.g., weights, duration)
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

  private static func generateMaxValue(for _: Exercise, level: String) -> Int {
    // Custom logic for maximum values
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

  private static func determineMeasurement(for exercise: Exercise) -> String {
    // Determine appropriate measurement based on exercise category
    if exercise.category.contains("cardio") {
      "minutes"
    } else if exercise.equipment?.contains("dumbbell") ?? false {
      "lbs"
    } else {
      "reps"
    }
  }
}
