//
//  Exercise.swift
//
//
//  Created by Solomon Alexandru on 06.05.2024.
//

import Fluent
import NIOCore
import Vapor

// MARK: - Exercise

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

  @Siblings(through: UserFavoriteExercise.self, from: \.$exercise, to: \.$user)
  var favoritedBy: [User]

  @Children(for: \.$exercise)
  var ratings: [ExerciseRating]

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
    imageUrls: [String] = [])
  {
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

  public func asPublic(isFavorite: Bool = false) -> Public {
    Public(
      id: id,
      name: name,
      category: category,
      level: level,
      force: force,
      mechanic: mechanic,
      equipment: equipment,
      primaryMuscles: primaryMuscles,
      secondaryMuscles: secondaryMuscles,
      instructions: instructions,
      dateCreated: dateCreated,
      dateUpdated: dateUpdated,
      imageUrls: imageUrls,
      isFavorite: isFavorite)
  }
}

// MARK: DecodableModel

extension Exercise: DecodableModel { }

// MARK: Exercise.Public

extension Exercise {
  struct Public: Content, @unchecked Sendable {
    let id: UUID?
    let name: String
    let category: String
    let level: String
    let force: String?
    let mechanic: String?
    let equipment: String?
    let primaryMuscles: [String]
    let secondaryMuscles: [String]
    let instructions: [String]
    let dateCreated: Date?
    let dateUpdated: Date?
    let imageUrls: [String]?
    let isFavorite: Bool
  }
}
