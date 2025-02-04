//
//  File.swift
//  Musculos
//
//  Created by Solomon Alexandru on 04.02.2025.
//

import Vapor

public protocol EndpointAPI {
  static var endpoint: String { get }
}
