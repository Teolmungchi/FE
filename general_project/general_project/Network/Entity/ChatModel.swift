//
//  ChatModel.swift
//  general_project
//
//  Created by 이상엽 on 5/13/25.
//

import Foundation

// MARK: - 사용자 모델 (ChatRoom.user1, user2 에 매핑)
struct ChatUser: Codable, Identifiable {
    let id: Int
    let serialId: String?
    let name: String?

    enum CodingKeys: String, CodingKey {
        case id
        case serialId
        case name
    }
}

// MARK: - 채팅방 모델
struct ChatRoom: Codable, Identifiable {
    let id: Int
    let user1Id: Int
    let user2Id: Int
    let user1: ChatUser
    let user2: ChatUser
    let unreadCount: Int?
    let lastMessage: String?
    let lastMessageAt: Date?
    let lastMessageAgo: String?

    enum CodingKeys: String, CodingKey {
        case id
        case user1Id
        case user2Id
        case user1
        case user2
        case unreadCount
        case lastMessage
        case lastMessageAt
        case lastMessageAgo
    }
}

// MARK: - 채팅 메시지 모델
struct ChatMessage: Decodable, Identifiable {
    let id: String
    let message: String
    let senderId: String
    let receiverId: String
    let chatRoomId: String
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case _id          // REST payload
        case message
        case senderId
        case receiverId
        case chatRoomId
        case createdAt
    }
    
    init(from decoder: Decoder) throws {
           let container = try decoder.container(keyedBy: CodingKeys.self)

           // 1) id 또는 _id 중 있는 쪽으로 할당
           if let socketId = try? container.decode(String.self, forKey: .id) {
               id = socketId
           } else {
               id = try container.decode(String.self, forKey: ._id)
           }

           // 2) 나머지 문자열 필드
           message    = try container.decode(String.self, forKey: .message)
           senderId   = try container.decode(String.self, forKey: .senderId)
           receiverId = try container.decode(String.self, forKey: .receiverId)
           chatRoomId = try container.decode(String.self, forKey: .chatRoomId)

           // 3) createdAt (밀리초 포함 ISO8601)
           let dateStr = try container.decode(String.self, forKey: .createdAt)
           let formatter = ISO8601DateFormatter()
           formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
           guard let dt = formatter.date(from: dateStr) else {
               throw DecodingError.dataCorruptedError(
                   forKey: .createdAt, in: container,
                   debugDescription: "Invalid date format: \(dateStr)"
               )
           }
           createdAt = dt
       }
    
}
