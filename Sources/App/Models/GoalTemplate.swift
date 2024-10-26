//
//  GoalTemplate.swift
//  Musculos
//
//  Created by Solomon Alexandru on 25.10.2024.
//

import Vapor
import Fluent

final class GoalTemplate: Model, Content, @unchecked Sendable {
  static let schema = "goalTemplates"

  @ID(key: .id)
  var id: UUID?

  @Field(key: "title")
  var title: String

  @Field(key: "description")
  var description: String

  @Field(key: "icon_name")
  var iconName: String

  init() {}

  init(id: UUID = UUID(), title: String, description: String, iconName: String) {
    self.id = id
    self.title = title
    self.description = description
    self.iconName = iconName
  }
}
