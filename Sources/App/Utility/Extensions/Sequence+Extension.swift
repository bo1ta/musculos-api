//
//  File.swift
//
//
//  Created by Solomon Alexandru on 06.05.2024.
//

import Foundation

extension Sequence {
  func asyncMap<T>(_ transform: (Element) async throws -> T) async rethrows -> [T] {
    var values = [T]()
    for element in self {
      try await values.append(transform(element))
    }
    return values
  }

  func asyncCompactMap<T>(_ transform: (Element) async throws -> T?) async rethrows -> [T] {
    var values: [T] = []
    for element in self {
      if let transformed = try await transform(element) {
        values.append(transformed)
      }
    }
    return values
  }

  func asyncForEach(_ operation: (Element) async throws -> Void) async rethrows {
    for element in self {
      try await operation(element)
    }
  }
}
