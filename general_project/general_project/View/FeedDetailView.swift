//
//  FeedDetailView.swift
//  general_project
//
//  Created by 이상엽 on 5/12/25.
//

import SwiftUI
import Kingfisher

struct FeedDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("shouldRefreshFeed") private var shouldRefreshFeed = false
    @AppStorage("userId") private var currentUserId: Int = 0
    @StateObject private var viewModel: FeedDetailViewModel
    
    @State private var showOptions = false
    @State private var showDeleteAlert = false
    @State private var navigateToEdit = false
    
    init(feed: Feed) {
        _viewModel = StateObject(wrappedValue: FeedDetailViewModel(feed: feed))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                KFImage.url(URL(string: viewModel.feed.fileName ?? ""))
                    .placeholder {
                        ProgressView().frame(height: 220)
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 220)
                    .clipped()
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(viewModel.feed.title)
                        .font(.title2).fontWeight(.bold).padding(.top, 16)
                    
                    Text(viewModel.feed.content)
                        .font(.subheadline).foregroundColor(.secondary)
                    
                    Divider().padding(.vertical, 10)
                    
                    Group {
                        Text("분실장소 정보").font(.headline).padding(.bottom, 6)
                        infoRow(label: "분실날짜", value: viewModel.feed.lostDate)
                        infoRow(label: "분실장소", value: viewModel.feed.lostPlace)
                        infoRow(label: "특징",     value: viewModel.feed.placeFeature)
                    }
                    
                    Divider().padding(.vertical, 10)
                    
                    Group {
                        Text("분실동물 정보").font(.headline).padding(.bottom, 6)
                        infoRow(label: "품종", value: viewModel.feed.dogType)
                        infoRow(label: "나이", value: viewModel.feed.dogAge.map(String.init))
                        infoRow(label: "성별", value: viewModel.feed.dogGender)
                        infoRow(label: "색상", value: viewModel.feed.dogColor)
                        infoRow(label: "특징", value: viewModel.feed.dogFeature)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("상세 정보")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if viewModel.feed.author.id == currentUserId {
                    Button { showOptions = true } label: {
                        Image(systemName: "ellipsis")
                    }
                }
            }
        }
        .navigationDestination(isPresented: $navigateToEdit) {
            FeedEditView(viewModel: viewModel)
        }
        .confirmationDialog("게시글 옵션", isPresented: $showOptions) {
            Button("수정")    {
                navigateToEdit = true
            }
            Button("삭제", role: .destructive) { showDeleteAlert = true }
            Button("취소", role: .cancel)    { }
        }
        
        .alert("정말 삭제할까요?", isPresented: $showDeleteAlert) {
            Button("삭제", role: .destructive) {
                Task {
                    print("→ 삭제 API 실행")
                    await viewModel.deleteFeed()
                    print("→ deletionSuccess:", viewModel.deletionSuccess)
                    print("→ errorMessage:", viewModel.errorMessage ?? "없음")
                }
            }
            Button("취소", role: .cancel) { }
        }
        .onChange(of: viewModel.deletionSuccess) { _, success in
            if success {
                shouldRefreshFeed = true
                dismiss()
            }
        }
        .onDisappear {
            if viewModel.deletionSuccess {
                return
            }
            shouldRefreshFeed = true
        }
        .onChange(of: viewModel.errorMessage) { _, msg in
            if let m = msg { print("⚠️", m) }
        }
    }
}


@ViewBuilder
private func infoRow(label: String, value: String?) -> some View {
    HStack {
        Text(label).fontWeight(.semibold)
        Spacer()
        Text(value ?? "-")
    }
}

