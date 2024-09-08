//
//  Workout.swift
//
//
//  Created by Solomon Alexandru on 07.05.2024.
//

import Foundation
import Fluent
import Vapor

final class Workout: Model, Content, @unchecked Sendable {
  static let schema: String = "workouts"
  
  @ID(key: .id)
  var id: UUID?
  
  @Field(key: "name")
  var name: String
  
  @Field(key: "target_muscles")
  var targetMuscles: [String]
  
  @Parent(key: "user_id")
  var user: User
  
  @Children(for: \.$workout)
  var workoutExercises: [WorkoutExercise]
  
  init() { }

  init(id: UUID? = nil, name: String, targetMuscles: [String], userID: User.IDValue) {
    self.id = id
    self.name = name
    self.targetMuscles = targetMuscles
    self.$user.id = userID
  }
}
