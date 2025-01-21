//
//  UserExperienceEntry.swift
//  Musculos
//
//  Created by Solomon Alexandru on 15.12.2024.
//

import Fluent
import Foundation
import Vapor

final class UserExperienceEntry: Model, Content, @unchecked Sendable {
  static let schema = "user_experience_entries"

  @ID(key: .id)
  var id: UUID?

  @Parent(key: "user_experience_id")
  var userExperience: UserExperience

  @Parent(key: "exercise_session_id")
  var exerciseSession: ExerciseSession

  @Field(key: "xp_gained")
  var xpGained: Int

  init() { }

  init(id: UUID? = UUID(), userExperienceID: UserExperience.IDValue, exerciseSessionID: ExerciseSession.IDValue, xpGained: Int) {
    self.id = id
    self.$userExperience.id = userExperienceID
    self.$exerciseSession.id = exerciseSessionID
    self.xpGained = xpGained
  }
}
