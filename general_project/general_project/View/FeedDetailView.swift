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
    @State private var imageHeight: CGFloat = 300
    
    let imageBaseURL = "http://tmc.kro.kr:9000/tmc/"
    
    init(feed: Feed) {
        _viewModel = StateObject(wrappedValue: FeedDetailViewModel(feed: feed))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    // 이미지 섹션
                    imageSection(geometry: geometry)
                    
                    // 콘텐츠 섹션
                    VStack(spacing: 20) {
                        // 기본 정보 카드
                        basicInfoCard
                        
                        // 분실 장소 정보 카드
                        lostLocationCard
                        
                        // 분실 동물 정보 카드
                        animalInfoCard
                        
                        // 작성자 정보 카드 (옵션)
                        authorInfoCard
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("상세 정보")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if viewModel.feed.author.id == currentUserId {
                    Button { showOptions = true } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title3)
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .navigationDestination(isPresented: $navigateToEdit) {
            FeedEditView(viewModel: viewModel)
        }
        .confirmationDialog("게시글 옵션", isPresented: $showOptions) {
            Button("수정") {
                navigateToEdit = true
            }
            Button("삭제", role: .destructive) {
                showDeleteAlert = true
            }
            Button("취소", role: .cancel) { }
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
    
    // MARK: - 이미지 섹션
    private func imageSection(geometry: GeometryProxy) -> some View {
        let imageURLString = "\(imageBaseURL)\(viewModel.feed.fileName ?? "")"
        
        return ZStack(alignment: .bottomLeading) {
            KFImage.url(URL(string: imageURLString))
                .placeholder {
                    ZStack {
                        Rectangle()
                            .fill(Color(.systemGray5))
                        VStack(spacing: 12) {
                            ProgressView()
                                .scaleEffect(1.2)
                            Text("이미지 로딩 중...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: geometry.size.width, height: imageHeight)
                .clipped()
            
            // 그라데이션 오버레이
            LinearGradient(
                colors: [Color.black.opacity(0.6), Color.clear],
                startPoint: .bottom,
                endPoint: .center
            )
            .frame(height: 100)
            
        }
    }
    
    // MARK: - 기본 정보 카드
    private var basicInfoCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 16) {
                Text(viewModel.feed.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(viewModel.feed.content)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(nil)
                
                // 게시 정보
                HStack {
                    Label(formatDate(viewModel.feed.createdAt), systemImage: "calendar")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()

                }
                .padding(.top, 8)
            }
        }
    }
    
    // MARK: - 분실 장소 정보 카드
    private var lostLocationCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(
                    title: "분실 장소 정보",
                    icon: "location.fill",
                    color: .red
                )
                
                VStack(spacing: 12) {
                    InfoRow(
                        icon: "calendar.badge.clock",
                        label: "분실날짜",
                        value: viewModel.feed.lostDate,
                        color: .orange
                    )
                    
                    InfoRow(
                        icon: "mappin.circle",
                        label: "분실장소",
                        value: viewModel.feed.lostPlace,
                        color: .red
                    )
                    
                    InfoRow(
                        icon: "info.circle",
                        label: "장소 특징",
                        value: viewModel.feed.placeFeature,
                        color: .blue
                    )
                }
            }
        }
    }
    
    // MARK: - 분실 동물 정보 카드
    private var animalInfoCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(
                    title: "분실 동물 정보",
                    icon: "pawprint.fill",
                    color: .brown
                )
                
                VStack(spacing: 12) {
                    InfoRow(
                        icon: "heart.circle",
                        label: "품종",
                        value: viewModel.feed.dogType,
                        color: .pink
                    )
                    
                    InfoRow(
                        icon: "number.circle",
                        label: "나이",
                        value: viewModel.feed.dogAge.map { "\($0)살" },
                        color: .green
                    )
                    
                    InfoRow(
                        icon: "person.circle",
                        label: "성별",
                        value: viewModel.feed.dogGender,
                        color: .blue
                    )
                    
                    InfoRow(
                        icon: "paintpalette",
                        label: "색상",
                        value: viewModel.feed.dogColor,
                        color: .purple
                    )
                    
                    InfoRow(
                        icon: "star.circle",
                        label: "특징",
                        value: viewModel.feed.dogFeature,
                        color: .orange
                    )
                }
            }
        }
    }
    
    // MARK: - 작성자 정보 카드
    private var authorInfoCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(
                    title: "작성자 정보",
                    icon: "person.crop.circle",
                    color: .indigo
                )
                
                HStack(spacing: 12) {
                    Image(systemName: "person.circle.fill")
                        .font(.title2)
                        .foregroundColor(.indigo)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.feed.author.name ?? "")
                            .font(.body)
                            .fontWeight(.medium)
                        
                        Text("작성자")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - 날짜 포맷팅
    private func formatDate(_ dateString: String?) -> String {
        guard let dateString = dateString else { return "날짜 정보 없음" }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "yyyy년 MM월 dd일"
            return formatter.string(from: date)
        }
        
        return dateString
    }
}

// MARK: - 커스텀 컴포넌트들

struct CardView<Content: View>: View {
    let content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content()
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct SectionHeader: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.bottom, 4)
    }
}

struct InfoRow: View {
    let icon: String
    let label: String
    let value: String?
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(color)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Text(value ?? "정보 없음")
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
