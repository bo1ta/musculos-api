//
//  ImageController.swift
//  Musculos
//
//  Created by Solomon Alexandru on 28.12.2024.
//

import Vapor
import Foundation

struct ImageController: RouteCollection {
  func boot(routes: any RoutesBuilder) throws {
    let imagesRoute = routes
      .apiV1Group("images")
      .grouped(
        Token.authenticator()
      )

    imagesRoute.grouped("upload")
      .on(.POST, body: .collect(maxSize: "10mb"), use: { try await upload(req: $0) })
  }

  func upload(req: Request) async throws -> ImageUploadResponse {
    let data = try req.content.decode(ImageUploadData.self)
    let currentUser = try req.auth.require(User.self)
    let currentUserID = try currentUser.requireID()

    let fileName = "\(currentUserID)-\(UUID()).jpg"

    let imagesPath = req.application.directory.publicDirectory + "images"

    try FileManager.default.createDirectory(
      atPath: imagesPath,
      withIntermediateDirectories: true
    )

    let path = imagesPath + "/" + fileName
    try await req.fileio.writeFile(.init(data: data.picture), at: path)

    return ImageUploadResponse(fileName: fileName, filePath: "/images/\(fileName)")
  }
}

extension ImageController {
  struct ImageUploadResponse: Content {
    let fileName: String
    let filePath: String
  }

  struct ImageUploadData: Content {
    var picture: Data
  }
}
