//
//  Response+Extension.swift
//  Musculos
//
//  Created by Solomon Alexandru on 08.12.2024.
//

import Fluent
import Vapor

extension Response {
  static func withCacheControl<T: Content>(maxAge: Int, data: T, contentType: HTTPMediaType = .json) throws -> Response {
    let response = Response()
    response.headers.replaceOrAdd(name: .cacheControl, value: "max-age=\(maxAge), public")
    response.headers.replaceOrAdd(name: .contentType, value: contentType.description)
    try response.content.encode(data)
    return response
  }
}
