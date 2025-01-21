//
//  ExerciseConstants.swift
//  Musculos
//
//  Created by Solomon Alexandru on 28.09.2024.
//

public enum ExerciseConstants {
  public enum ForceType: String, CaseIterable {
    case pull, push, `static`
  }

  public enum LevelType: String, CaseIterable {
    case beginner, intermediate, expert
  }

  public enum MechanicType: String, CaseIterable {
    case compound, isolation
  }

  public enum EquipmentType: String, CaseIterable {
    case machine
    case other
    case kettlebells
    case dumbbell
    case cable
    case barbell
    case bands
    case bodyOnly = "body only"
    case foamRoll = "foam roll"
    case medicineBall = "medicine ball"
    case exerciseBall = "exercise ball"
    case ezCurlBar = "e-z curl bar"
  }

  public enum CategoryType: String, CaseIterable {
    case strength
    case stretching
    case plyometrics
    case strongman
    case powerlifting
    case cardio
    case olympicWeightlifting = "olympic weightlifting"
  }

  nonisolated(unsafe) static let goalToExerciseCategories: [WorkoutGoal: [String]] = [
    .general: [
      CategoryType.cardio.rawValue,
      CategoryType.stretching.rawValue,
      CategoryType.strength.rawValue,
    ],
    .flexibility: [
      CategoryType.stretching.rawValue,
    ],
    .improveEndurance: [
      CategoryType.cardio.rawValue,
    ],
    .increaseStrength: [
      CategoryType.strength.rawValue,
      CategoryType.powerlifting.rawValue,
      CategoryType.strongman.rawValue,
      CategoryType.olympicWeightlifting.rawValue,
    ],
    .growMuscles: [
      CategoryType.strength.rawValue,
      CategoryType.powerlifting.rawValue,
      CategoryType.strongman.rawValue,
      CategoryType.olympicWeightlifting.rawValue,
    ],
    .loseWeight: [
      CategoryType.cardio.rawValue,
      CategoryType.stretching.rawValue,
    ],
  ]
}
