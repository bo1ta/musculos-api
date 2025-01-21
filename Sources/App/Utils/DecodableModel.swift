//
//  File.swift
//
//
//  Created by Solomon Alexandru on 06.05.2024.
//

import Foundation

// MARK: - DecodableModel

/// Utility that decodes Data into  a Codable object
/// Supports single objects or arrays
///
protocol DecodableModel {
  static func createFrom(_ data: Data) async throws -> Self
  static func createArrayFrom(_ data: Data) async throws -> [Self]
}

extension DecodableModel where Self: Codable {
  static func createFrom(_ data: Data) throws -> Self {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return try decoder.decode(Self.self, from: data)
  }

  static func createArrayFrom(_ data: Data) throws -> [Self] {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return try decoder.decode([Self].self, from: data)
  }
}
