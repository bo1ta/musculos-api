//
//  File.swift
//
//
//  Created by Solomon Alexandru on 08.09.2024.
//

import Vapor

extension RoutesBuilder {
  func apiV1Group(_ pathName: String) -> RoutesBuilder {
    self.grouped("api", "v1", PathComponent(stringLiteral: pathName))
  }
}
