//
//  HomeFeedRow.swift
//  general_project
//
//  Created by 이상엽 on 5/12/25.
//


import SwiftUI
import Kingfisher

struct HomeFeedRow: View {
    let feed: Feed
    let imageBaseURL = "http://tmc.kro.kr:9000/tmc/"
    @State private var isPressed = false
    
    var tags: [String] {
        [feed.lostPlace ?? "", feed.dogType ?? ""].filter { !$0.isEmpty }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 이미지 섹션
            imageSection
            
            // 컨텐츠 섹션
            contentSection
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .padding(.horizontal, 4)
        .padding(.vertical, 8)
    }
    
    // MARK: - Image Section
    private var imageSection: some View {
        GeometryReader { geometry in
            let imageURLString = "\(feed.presignedUrl ?? "")"
            
            KFImage.url(URL(string: imageURLString))
                .placeholder {
                    placeholderView
                }
                .retry(maxCount: 3, interval: .seconds(5))
                .cacheOriginalImage()
                .fade(duration: 0.3)
                .resizable()
                .scaledToFill()
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipped()
                .overlay(
                    // 이미지 위 그라데이션 오버레이
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.0),
                            Color.black.opacity(0.1)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    // 우측 상단 상태 배지
                    statusBadge,
                    alignment: .topTrailing
                )
        }
        .frame(height: 220)
        .clipShape(
            .rect(
                topLeadingRadius: 16,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 16
            )
        )
    }
    
    // MARK: - Placeholder View
    private var placeholderView: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.systemGray6),
                        Color(.systemGray5)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                VStack(spacing: 12) {
                    Image(systemName: "photo.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary.opacity(0.6))
                    
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(.secondary)
                    
                    Text("이미지 로딩 중...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            )
    }
    
    // MARK: - Status Badge
    private var statusBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.system(size: 12, weight: .bold))
            Text("실종")
                .font(.system(size: 11, weight: .bold))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color.red)
                .shadow(color: .red.opacity(0.3), radius: 4, x: 0, y: 2)
        )
        .padding(.top, 12)
        .padding(.trailing, 12)
    }
    
    // MARK: - Content Section
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 제목과 태그
            titleAndTagsSection
            
            // 내용
            contentTextSection
            
            // 메타 정보
            metaInfoSection
        }
        .padding(20)
    }
    
    // MARK: - Title and Tags Section
    private var titleAndTagsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(feed.title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            if !tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(tags.enumerated()), id: \.offset) { index, tag in
                            TagView(
                                text: tag,
                                backgroundColor: tagColor(for: index),
                                textColor: tagTextColor(for: index)
                            )
                        }
                    }
                    .padding(.horizontal, 1) // 그림자가 잘리지 않도록
                }
            }
        }
    }
    
    // MARK: - Content Text Section
    private var contentTextSection: some View {
        Text(feed.content)
            .font(.system(size: 15, weight: .regular))
            .foregroundColor(.secondary)
            .lineLimit(3)
            .multilineTextAlignment(.leading)
            .lineSpacing(2)
    }
    
    // MARK: - Meta Info Section
    private var metaInfoSection: some View {
        HStack(spacing: 16) {
            // 위치 정보
            if let location = feed.lostPlace, !location.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.blue)
                    
                    Text(location)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.blue)
                }
            }
            
            Spacer()
            
            // 시간 정보 (실제 데이터에 맞게 수정 필요)
            HStack(spacing: 6) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                
                Text("2시간 전") // 실제로는 feed.createdAt 등을 사용
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            // 더보기 화살표
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.tertiary)
        }
    }
    
    // MARK: - Helper Methods
    private func tagColor(for index: Int) -> Color {
        let colors: [Color] = [
            Color.blue.opacity(0.1),
            Color.green.opacity(0.1),
            Color.orange.opacity(0.1),
            Color.purple.opacity(0.1)
        ]
        return colors[index % colors.count]
    }
    
    private func tagTextColor(for index: Int) -> Color {
        let colors: [Color] = [
            Color.blue,
            Color.green,
            Color.orange,
            Color.purple
        ]
        return colors[index % colors.count]
    }
}

// MARK: - Supporting Views

struct TagView: View {
    let text: String
    let backgroundColor: Color
    let textColor: Color
    
    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(textColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(backgroundColor)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(textColor.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: textColor.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}
