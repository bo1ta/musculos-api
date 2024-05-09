//
//  Exercise.swift
//  
//
//  Created by Solomon Alexandru on 06.05.2024.
//

import Fluent
import Vapor
import NIOCore

final class Exercise: Model, Content, @unchecked Sendable {
  static let schema = "exercises"
  
  @ID(key: .id)
  var id: UUID?
  
  @Field(key: "name")
  var name: String
  
  @Field(key: "category")
  var category: String
  
  @Field(key: "level")
  var level: String
  
  @Field(key: "force")
  var force: String?
  
  @Field(key: "mechanic")
  var mechanic: String?
  
  @Field(key: "equipment")
  var equipment: String?
  
  @Field(key: "primary_muscles")
  var primaryMuscles: [String]
  
  @Field(key: "secondary_muscles")
  var secondaryMuscles: [String]
  
  @Field(key: "instructions")
  var instructions: [String]
  
  @Timestamp(key: "date_created", on: .create)
  var dateCreated: Date?
  
  @Timestamp(key: "date_updated", on: .update)
  var dateUpdated: Date?
  
  @Field(key: "image_urls")
  var imageUrls: [String]?
  
  init() { }
  
  init(
    id: UUID? = UUID(),
    name: String,
    category: String,
    level: String,
    force: String? = nil,
    mechanic: String? = nil,
    equipment: String? = nil,
    primaryMuscles: [String],
    secondaryMuscles: [String],
    instructions: [String],
    dateCreated: Date? = nil,
    dateUpdated: Date? = nil,
    imageUrls: [String] = []
  ) {
    self.id = id
    self.name = name
    self.category = category
    self.level = level
    self.force = force
    self.mechanic = mechanic
    self.equipment = equipment
    self.primaryMuscles = primaryMuscles
    self.secondaryMuscles = secondaryMuscles
    self.instructions = instructions
    self.dateCreated = dateCreated
    self.dateUpdated = dateUpdated
    self.imageUrls = imageUrls
  }
}

extension Exercise: DecodableModel { }
