//
//  Goal.swift
//  Musculos
//
//  Created by Solomon Alexandru on 25.10.2024.
//

import Fluent
import Vapor

final class Goal: Model, Content, @unchecked Sendable {
  static let schema = "goals"

  @ID(custom: "goal_id")
  var id: UUID?

  @Field(key: "name")
  var name: String

  @Parent(key: "user_id")
  var user: User

  @Field(key: "frequency")
  var frequency: String

  @Children(for: \.$goal)
  var progressEntries: [ProgressEntry]

  @Field(key: "date_added")
  var dateAdded: Date

  @OptionalField(key: "end_date")
  var endDate: Date?

  @Field(key: "is_completed")
  var isCompleted: Bool

  @Field(key: "target_value")
  var targetValue: Int?

  @Field(key: "category")
  var category: String?

  init() { }

  init(
    id: UUID = UUID(),
    name: String,
    userID: User.IDValue,
    frequency: String,
    dateAdded: Date = Date(),
    endDate: Date? = nil,
    isCompleted: Bool = false,
    category: String? = nil,
    targetValue: Int? = nil)
  {
    self.id = id
    self.name = name
    self.$user.id = userID
    self.frequency = frequency
    self.dateAdded = dateAdded
    self.endDate = endDate
    self.isCompleted = isCompleted
    self.category = category
    self.targetValue = targetValue
  }

  func asPublic() throws -> Goal.Public {
    Public(
      id: try self.requireID(),
      name: self.name,
      user: user.asPublic(),
      frequency: self.frequency,
      progressEntries: self.progressEntries,
      dateAdded: self.dateAdded,
      endDate: self.endDate,
      isCompleted: self.isCompleted,
      targetValue: self.targetValue,
      category: self.category)
  }

  struct Public: Content {
    let id: UUID?
    let name: String
    let user: User.Public
    let frequency: String
    let progressEntries: [ProgressEntry]?
    let dateAdded: Date
    let endDate: Date?
    let isCompleted: Bool
    let targetValue: Int?
    let category: String?
  }
}
