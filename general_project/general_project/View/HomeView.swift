//
//  MainView.swift
//  general_project
//
//  Created by 이상엽 on 3/12/25.
//

import Foundation
import SwiftUI

struct PetInfo: Identifiable {
    let id = UUID()
    let imageName: String
    let headline: String
    let description: String
    let tags: [String]
}

struct HomeView: View {
    @State private var petList: [PetInfo] = [
        PetInfo(imageName: "dog_sample",
                headline: "Headline",
                description: "사용자가 작성한 설명에 해당하는 부분입니다.",
                tags: ["서울", "믹스견"]),
        PetInfo(imageName: "dog_sample",
                headline: "Headline 2",
                description: "두 번째로 등록된 반려견 정보야.",
                tags: ["부산", "포메라니안"]),
        PetInfo(imageName: "dog_sample",
                headline: "Headline 2",
                description: "두 번째로 등록된 반려견 정보야.",
                tags: ["부산", "포메라니안"])
    ]
    
    var body: some View {
        NavigationStack {
            List(petList) { pet in
                // 카드 형태 + 그림자
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                        .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        // 이미지
                        Image(pet.imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .clipped()
                        HStack(spacing: 8) {
                        // 헤드라인
                        Text(pet.headline)
                            .font(.headline)
                            .fontWeight(.bold)
                        Spacer()
                        // 태그
                            ForEach(pet.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.caption)
                                    .foregroundColor(.black)
                                    .padding(.vertical, 7)
                                    .padding(.horizontal, 14)
                                    .background(Color.paleMint)
                                    .cornerRadius(20)
                            }
                        }
                        
                        // 설명
                        Text(pet.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        
                    }
                    .padding()
                }
                .padding(.vertical, 8)
                // 리스트 구분선, 배경 제거
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
            .listStyle(.plain)
            // 네비게이션 바 타이틀(폰트 커스텀 위해 .inline)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // 중앙 커스텀 타이틀
                ToolbarItem(placement: .topBarLeading) {
                    Text("실종 동물 찾기")
                        .font(.system(size: 20, weight: .bold))
                }
                
                // 오른쪽 버튼들
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        // 검색 버튼 액션
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.black)
                    }
                    
                    Button {
                        // 알림 버튼 액션
                    } label: {
                        Image(systemName: "bell")
                            .foregroundColor(.black)
                    }
                }
            }
        }
    }
}
#Preview{
    HomeView()
}
