//
//  WorkoutGoal.swift
//  Musculos
//
//  Created by Solomon Alexandru on 28.09.2024.
//

import Foundation

public enum WorkoutGoal: Int, Codable {
  case general = 0 // General fitness
  case growMuscles = 1 // Build muscle mass
  case loseWeight = 2 // Lose weight or fat
  case increaseStrength = 3 // Increase strength
  case improveEndurance = 4 // Cardio and stamina
  case flexibility = 5 // Improve flexibility/mobility
}
