//
//  ProgressEntry.swift
//  Musculos
//
//  Created by Solomon Alexandru on 26.10.2024.
//

import Fluent
import Vapor

final class ProgressEntry: Model, Content, @unchecked Sendable {
  static let schema = "progressEntries"

  @ID(custom: "entry_id")
  var id: UUID?

  @Field(key: "date_added")
  var dateAdded: Date

  @Field(key: "value")
  var value: Double

  @Parent(key: "goal_id")
  var goal: Goal

  init() { }

  init(id: UUID? = nil, dateAdded: Date, value: Double, goalID: UUID) {
    self.id = id
    self.dateAdded = dateAdded
    self.value = value
    self.$goal.id = goalID
  }
}
