//
//  UserExperience.swift
//  Musculos
//
//  Created by Solomon Alexandru on 15.12.2024.
//

import Fluent
import Foundation
import Vapor

// MARK: - UserExperience

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

extension UserExperience {
  func asPublic() -> UserExperience.Public {
    .init(
      id: id,
      totalExperience: totalExperience,
      experienceEntries: experienceEntries)
  }

  struct Public: Content {
    var id: UUID?
    var totalExperience: Int
    var experienceEntries: [UserExperienceEntry]
  }
}
