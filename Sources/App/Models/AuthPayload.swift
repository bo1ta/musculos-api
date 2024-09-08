//
//  AuthPayload.swift
//  
//
//  Created by Solomon Alexandru on 05.07.2024.
//

import JWT

struct AuthPayload: JWTPayload {
  enum CodingKeys: String, CodingKey {
      case subject = "sub"
      case expiration = "exp"
  }

  var subject: SubjectClaim
  var expiration: ExpirationClaim

  func verify(using algorithm: some JWTAlgorithm) async throws {
      try self.expiration.verifyNotExpired()
  }
}
