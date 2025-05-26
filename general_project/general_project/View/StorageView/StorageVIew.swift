import SwiftUI
import Kingfisher

struct StorageView: View {
    @StateObject private var viewModel = StorageViewModel()
    @State private var navigateToChat = false
    @State private var newRoomId: Int?
    @State private var selectedItem: StorageItem?

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                } else if viewModel.items.isEmpty {
                    Text("현재 들어온 제보가 없어요!")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    List(viewModel.items, id: \.self) { item in
                        HStack(spacing: 12) {
                            KFImage(item.finderPresignedURL)
                                .placeholder { ProgressView() }
                                .retry(maxCount: 3, interval: .seconds(5))
                                .cacheOriginalImage()
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .clipped()
                                .cornerRadius(8)

                            Text(item.message)
                                .font(.subheadline)
                                .lineLimit(2)
                        }
                        .padding(.vertical, 8)
                        .onTapGesture {
                            selectedItem = item
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .onAppear { viewModel.loadItems() }
            .navigationTitle("보관함")
            .navigationDestination(isPresented: $navigateToChat) {
                if let roomId = newRoomId {
                    ChatRoomView(roomId: roomId)
                }
            }
            .sheet(item: $selectedItem) { item in
                VStack(spacing: 20) {
                    KFImage(item.finderPresignedURL)
                        .placeholder { ProgressView() }
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(12)

                    Text(item.message)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    HStack {
                        Button("취소") {
                            selectedItem = nil
                        }
                        .buttonStyle(.bordered)

                        Spacer()

                        Button("연결") {
                            // 바로 Int이므로 옵셔널 바인딩 불필요
                            ChatService.shared.createRoom(with: item.finderId) { result in
                                DispatchQueue.main.async {
                                    switch result {
                                    case .success(let chatRoom):
                                        newRoomId = chatRoom.id
                                        navigateToChat = true
                                    case .failure(let err):
                                        viewModel.errorMessage = err.localizedDescription
                                    }
                                    selectedItem = nil
                                }
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.horizontal)
                }
                .padding()
                .presentationDetents([.height(350)])
            }
        }
    }
}
