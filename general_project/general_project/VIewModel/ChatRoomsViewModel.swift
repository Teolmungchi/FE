//
//  ChatRoomsViewModel.swift
//  general_project
//
//  Created by 이상엽 on 5/13/25.
//

import Foundation
import Combine

final class ChatRoomsViewModel: ObservableObject {
    @Published var rooms: [ChatRoom] = []
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false

    private var cancellables = Set<AnyCancellable>()

    /// 채팅방 목록 불러오기
    func loadRooms() {
        isLoading = true
        ChatService.shared.loadChatRooms { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false

            switch result {
            case .success(let rooms):
                self.rooms = rooms
            case .failure(let error):
                self.errorMessage = "채팅방 로드 실패: \(error.localizedDescription)"
            }
        }
    }

    /// 새로운 1:1 채팅방 만들기
    func createRoom(with user2Id: Int, completion: @escaping (ChatRoom?) -> Void) {
        ChatService.shared.createRoom(with: user2Id) { result in
            switch result {
            case .success(let room):
                // 방 생성 후 목록 갱신
                self.rooms.append(room)
                completion(room)
            case .failure:
                completion(nil)
            }
        }
    }
}
