//
//  ChatService.swift
//  general_project
//
//  Created by 이상엽 on 5/13/25.
//

import Foundation

// 뷰모델에서 ChatService.shared.xxx 메서드를 호출하면 됨
final class ChatService {
    static let shared = ChatService(api: ChatAPI())

    private let api: ChatAPIProtocol
    private init(api: ChatAPIProtocol) {
        self.api = api
    }

    func loadChatRooms(completion: @escaping (Result<[ChatRoom], ChatAPIError>) -> Void) {
        api.fetchChatRooms { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    func loadMessages(in roomId: Int,
                      limit: Int = 50,
                      completion: @escaping (Result<[ChatMessage], ChatAPIError>) -> Void) {
        api.fetchMessages(roomId: roomId, limit: limit) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    func createRoom(with user2Id: Int,
                    completion: @escaping (Result<ChatRoom, ChatAPIError>) -> Void) {
        api.createChatRoom(user2Id: user2Id) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    func markRoomAsRead(_ roomId: Int,
                        completion: @escaping (Result<Void, ChatAPIError>) -> Void) {
        api.markAsRead(roomId: roomId) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
}

