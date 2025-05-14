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
                            // 2) 제목·미리보기·시간
                            VStack(alignment: .leading, spacing: 4) {
                                // 상대방 이름으로 표시
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
                            
                            // 3) 마지막 수신 시간 (예: "2분 전")
                            if let ago = room.lastMessageAgo {
                                Text(ago)
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .listStyle(PlainListStyle())
            .navigationTitle("채팅")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { /* 알림 액션 */ }
                    label: {
                        Image(systemName: "bell")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("테스트 방 만들기") {
                        viewModel.createRoom(with: 25) { newRoom in
                            if let room = newRoom {
                                print("▶️ 새로 만든 방:", room)
                                viewModel.loadRooms()
                            } else {
                                print("▶️ 방 생성 실패")
                            }
                        }
                    }
                }
            }
            .onAppear {
                viewModel.loadRooms()
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
