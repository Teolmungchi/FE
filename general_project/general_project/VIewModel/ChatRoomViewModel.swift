//
//  ChatRoomViewModel.swift
//  general_project
//
//  Created by 이상엽 on 5/13/25.
//


import Foundation
import Combine

final class ChatRoomViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var errorMessage: String?
    @Published var isConnected: Bool = false

    private let roomId: Int
    private var cancellables = Set<AnyCancellable>()
    private var socketManager = ChatSocketManager.shared

    init(roomId: Int) {
        self.roomId = roomId
        attachSocketHandlers()
        socketManager.connect()
    }



    // MARK: - 소켓 재연결
        /// 이미 연결되어 있지 않다면 소켓 연결 시도
        func reconnectSocket() {
            guard !isConnected else { return }
            attachSocketHandlers()
            socketManager.connect()
        }
    
    // MARK: - 초기 메시지 로딩
     func loadHistory(limit: Int = 50) {
        ChatService.shared.loadMessages(in: roomId, limit: limit) { [weak self] result in
            switch result {
            case .success(let msgs):
                self?.messages = msgs.reversed()
            case .failure(let error):
                self?.errorMessage = "메시지 로드 실패: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - 채팅방 입장
    private func joinRoom() {
        socketManager.joinRoom(roomId: roomId)
    }

    // MARK: - 소켓 이벤트 바인딩
    private func attachSocketHandlers() {
        socketManager.onConnectSuccess = { [weak self] userId in
            DispatchQueue.main.async {
                self?.isConnected = true
                self?.joinRoom()
                self?.loadHistory()
            }
        }
        socketManager.onError = { [weak self] msg in
            print("❌ ChatRoomViewModel onError:", msg)
            DispatchQueue.main.async {
                self?.errorMessage = msg
            }
        }
        socketManager.onJoinedRoom = { joinedRoomId in
            print("✅ ChatRoomViewModel onJoinedRoom:", joinedRoomId)
        }
        socketManager.onNewMessage = { [weak self] newMsg in
            DispatchQueue.main.async {
                self?.messages.append(newMsg)
            }
            print("📨 ChatRoomViewModel onNewMessage:", newMsg)
            // 읽음 처리
            self?.markAsRead()
        }
    }

    // MARK: - 메시지 전송
    func sendMessage(_ text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        socketManager.sendMessage(roomId: roomId, message: text)
    }

    // MARK: - 읽음 처리
    func markAsRead() {
        ChatService.shared.markRoomAsRead(roomId) { _ in /* 결과 무시 */ }
    }
}
