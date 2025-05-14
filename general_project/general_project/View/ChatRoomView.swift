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
    
    init(roomId: Int) {
        _viewModel = StateObject(wrappedValue: ChatRoomViewModel(roomId: roomId))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 1) 메시지 리스트
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
                // 새 메시지 수신 시 자동 스크롤
                .onChange(of: viewModel.messages.count) { _ in
                    if let lastId = viewModel.messages.last?.id {
                        proxy.scrollTo(lastId, anchor: .bottom)
                    }
                }
            }
            
            // 2) 입력 바
            HStack(spacing: 12) {
                Button {
                    // 추가 기능 (예: 사진 첨부)
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 24))
                }
                
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
        .alert(item: $viewModel.errorMessage) { msg in
            Alert(title: Text("오류"), message: Text(msg), dismissButton: .default(Text("확인")))
        }
    }
}


/// 메시지 버블 컴포넌트
struct ChatBubbleView: View {
    let message: ChatMessage
    
    // 현재 내 ID와 비교
    private var isCurrentUser: Bool {
        guard let myId = ChatSocketManager.shared.currentUserId else { return false }
        return message.senderId == "\(myId)"
    }
    
    var body: some View {
        HStack {
                  // 내 메시지는 오른쪽, 남의 메시지는 왼쪽
                  if isCurrentUser { Spacer(minLength: 50) }

                  // 실제 버블
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
                  // 최대 너비 제한과 얼라인먼트
                  .frame(maxWidth: UIScreen.main.bounds.width * 0.7,
                         alignment: isCurrentUser ? .trailing : .leading)

                  if !isCurrentUser { Spacer(minLength: 50) }
              }
              .padding(.horizontal, 8)
              .padding(.vertical, 4)
          }
    
}

/// 버블 모양 (왼/오 분기)
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
