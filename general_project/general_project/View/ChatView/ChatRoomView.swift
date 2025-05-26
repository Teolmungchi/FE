//
//  ChatRoomView.swift
//  general_project
//
//  Created by 이상엽 on 5/13/25.
//

import SwiftUI

struct ChatRoomView: View {
    @StateObject private var viewModel: ChatRoomViewModel
    @State private var inputText: String = ""
    let roomId: Int = 0
    @Environment(\.dismiss) private var dismiss
    
    init(roomId: Int) {
        _viewModel = StateObject(wrappedValue: ChatRoomViewModel(roomId: roomId))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.messages) { msg in
                            ChatBubbleView(message: msg)
                                .id(msg.id)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
                .onChange(of: viewModel.messages.count) { oldCount, newCount in
                    guard newCount > oldCount, let lastId = viewModel.messages.last?.id else { return }
                    proxy.scrollTo(lastId, anchor: .bottom)
                }
            }
            
            HStack(spacing: 12) {
                
                
                TextField("메시지를 입력하세요", text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(minHeight: 36)
                
                Button {
                    viewModel.sendMessage(inputText)
                    inputText = ""
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 24))
                }
                .disabled(!viewModel.isConnected
                          || inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(12)
            .background(Color(UIColor.systemBackground))
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("채팅")
        .onAppear {
            // ViewModel init 에서 이미 connect, join, history 호출됨
        }
        .onDisappear {
            NotificationCenter.default.post(
                name: .didLeaveChatRoom,
                object: self.roomId
            )
        }
        .alert(item: $viewModel.errorMessage) { msg in
            Alert(title: Text("오류"), message: Text(msg), dismissButton: .default(Text("확인")))
        }
    }
}


struct ChatBubbleView: View {
    let message: ChatMessage
    
    private var isCurrentUser: Bool {
        guard let myId = ChatSocketManager.shared.currentUserId else { return false }
        return message.senderId == "\(myId)"
    }
    
    var body: some View {
        HStack {
                  if isCurrentUser { Spacer(minLength: 50) }

                  VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                      Text(message.message)
                          .padding(10)
                          .background(isCurrentUser ? Color.blue : Color(UIColor.systemGray5))
                          .foregroundColor(isCurrentUser ? .white : .primary)
                          .clipShape(ChatBubbleShape(isFromMe: isCurrentUser))
                      Text(message.createdAt, style: .time)
                          .font(.caption2)
                          .foregroundColor(.secondary)
                  }
                  .frame(maxWidth: UIScreen.main.bounds.width * 0.7,
                         alignment: isCurrentUser ? .trailing : .leading)

                  if !isCurrentUser { Spacer(minLength: 50) }
              }
              .padding(.horizontal, 8)
              .padding(.vertical, 4)
          }
    
}

struct ChatBubbleShape: Shape {
    let isFromMe: Bool
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: isFromMe
            ? [.topLeft, .topRight, .bottomLeft]
            : [.topRight, .topLeft, .bottomRight],
            cornerRadii: CGSize(width: 16, height: 16)
        )
        return Path(path.cgPath)
    }
}
