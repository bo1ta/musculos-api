//
//  ChatController.swift
//  Musculos
//
//  Created by Solomon Alexandru on 29.12.2024.
//

import Fluent
import Vapor

// MARK: - ChatController

struct ChatController: RouteCollection {
  func boot(routes: any RoutesBuilder) throws {
    let chatRoute = routes.apiV1Group("chat")

    chatRoute.webSocket("message", ":userId") { req, ws in
      guard let userId = req.parameters.get("userId") else {
        return
      }

      let chatManager = ChatManager()
      chatManager.connect(ws, userId: userId)

      ws.onText { [weak chatManager] _, text in
        guard
          let data = text.data(using: .utf8),
          let message = try? JSONDecoder().decode(ChatMessage.self, from: data)
        else { return }

        try? chatManager?.send(message: message)
      }

      ws.onClose.whenComplete { _ in
        chatManager.disconnect(userId: userId)
      }
    }
  }
}

// MARK: - ChatMessage

struct ChatMessage: Codable {
  let sender: String
  let recipient: String
  let content: String
  let timestamp: Date
}

// MARK: - ChatManager

final class ChatManager {
  /// Store active connections
  private var connections: [String: WebSocket] = [:]

  /// Connect a new user
  func connect(_ socket: WebSocket, userId: String) {
    connections[userId] = socket
  }

  /// Disconnect a user
  func disconnect(userId: String) {
    connections.removeValue(forKey: userId)
  }

  /// Send message to a specific user
  func send(message: ChatMessage) throws {
    guard let recipientSocket = connections[message.recipient] else {
      throw Abort(.notFound, reason: "Recipient not connected")
    }

    let jsonData = try JSONEncoder().encode(message)
    guard let jsonString = String(data: jsonData, encoding: .utf8) else {
      throw Abort(.internalServerError)
    }

    recipientSocket.send(jsonString)
  }
}
