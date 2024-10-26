//
//  Goal.swift
//  Musculos
//
//  Created by Solomon Alexandru on 25.10.2024.
//

import Vapor
import Fluent

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

  init() {}

  init(id: UUID = UUID(), name: String, userID: User.IDValue, frequency: String, dateAdded: Date = Date(), endDate: Date? = nil, isCompleted: Bool = false) {
    self.id = id
    self.name = name
    self.$user.id = userID
    self.frequency = frequency
    self.dateAdded = dateAdded
    self.endDate = endDate
    self.isCompleted = isCompleted
  }
}
