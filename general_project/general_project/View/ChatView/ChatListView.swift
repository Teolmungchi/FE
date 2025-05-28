//
//  ChatListView.swift
//  general_project
//
//  Created by 이상엽 on 5/13/25.
//

import SwiftUI

struct ChatListView: View {
    @StateObject private var viewModel = ChatRoomsViewModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.rooms) { room in
                    NavigationLink(destination: ChatRoomView(roomId: room.id)) {
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                let otherName = (room.user1Id == ChatSocketManager.shared.currentUserId ?
                                                 room.user2.name : room.user1.name) ?? "알 수 없는 사용자"
                                Text("\(otherName)님과의 채팅")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)

                                if let last = room.lastMessage {
                                    Text(last)
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 4) {
                                if let ago = room.lastMessageAgo {
                                    Text(ago)
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                }

                                if let count = room.unreadCount, count > 0 {
                                    Text("\(count)")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(6)
                                        .background(Circle().fill(Color.red))
                                }
                            }
                        }                        .padding(.vertical, 8)
                    }
                }
            }
            .listStyle(PlainListStyle())
            .navigationTitle("채팅")
            .onReceive(NotificationCenter.default.publisher(for: .didLeaveChatRoom)) { note in
                viewModel.loadRooms()
            }
            .onReceive(NotificationCenter.default.publisher(for: .didReceiveNewMessage)) { _ in
                withAnimation {
                    viewModel.loadRooms()
                }
            }
            .onAppear {
                withAnimation {
                    viewModel.loadRooms()
                }
            }
            .alert(item: $viewModel.errorMessage) { msg in
                Alert(title: Text("오류"), message: Text(msg), dismissButton: .default(Text("확인")))
            }
        }
    }
}

// String을 Identifiable로 써주면 Alert에 바로 바인딩 가능
extension String: Identifiable {
    public var id: String { self }
}
