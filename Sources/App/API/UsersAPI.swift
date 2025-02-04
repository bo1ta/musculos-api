//
//  UsersAPI.swift
//  Musculos
//
//  Created by Solomon Alexandru on 04.02.2025.
//

import Vapor

enum UsersAPI: EndpointAPI {
  public static let endpoint: String = "users"

  enum POST {
    static let register: PathComponent = "register"
    static let login: PathComponent = "login"
    static let updateProfile: PathComponent = "update-profile"

    struct SignUp: Content, Validatable {
      var username: String
      var email: String
      var password: String
      static func validations(_ validations: inout Validations) {
        validations.add("username", as: String.self, is: !.empty)
        validations.add("email", as: String.self, is: .email)
        validations.add("password", as: String.self, is: .count(8...))
      }
    }

    struct SignIn: Content {
      let email: String
      let password: String
    }

    struct UpdateUser: Content {
      let weight: Double?
      let height: Double?
      let level: String?
      let isOnboarded: Bool?
      let primaryGoalID: UUID?
    }
  }
}
