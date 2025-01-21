//
//  UserExperience.swift
//  Musculos
//
//  Created by Solomon Alexandru on 15.12.2024.
//

import Fluent
import Foundation
import Vapor

final class UserExperience: Model, Content, @unchecked Sendable {
  static let schema = "user_experience"

  @ID(key: .id)
  var id: UUID?

  @Parent(key: "user_id")
  var user: User

  @Field(key: "total_experience")
  var totalExperience: Int

  @Children(for: \.$userExperience)
  var experienceEntries: [UserExperienceEntry]

  init() { }
}
