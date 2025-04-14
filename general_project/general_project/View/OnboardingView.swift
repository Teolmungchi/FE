//
//  OnboadingView.swift
//  general_project
//
//  Created by 이상엽 on 4/8/25.
//

import SwiftUI

// 온보딩에서 보여줄 페이지 정보 모델
struct OnboardingPage {
    let title: String      // 상단 또는 중앙의 제목
    let imageName: String  // 이미지 에셋 이름
}

// 페이지 표시용 뷰
struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 44) {
            Spacer()
            
            Text(page.title)
                .font(.system(size: 20))
                .fontWeight(.bold)
            Image(page.imageName)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 300)
                .frame(maxWidth: 354)

            Spacer()
        }
    }
}

// 메인 온보딩 뷰
struct OnboardingView: View {
    // 온보딩 페이지들
    let pages: [OnboardingPage] = [
        OnboardingPage(title: "잃어버린 동물을\n찾을 수 있도록 도와드려요!",
                       imageName: "onboarding_map"), // 이미지 예시
        OnboardingPage(title: "사진을 등록하면",
                       imageName: "onboarding_post"),
        OnboardingPage(title: "냥즈들이 제보해줄 거예요",
                       imageName: "onboarding_camera"),
        OnboardingPage(title: "제보들 중에서\n유사한 사진이 있으면 알려드려요",
                       imageName: "onboarding_ac"),
        OnboardingPage(title: "제보자와 채팅",
                       imageName: "onboarding_chat")
    ]
    
    // 현재 페이지(탭) 인덱스
    @State private var currentTab = 0
    init() {
            UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.black
            UIPageControl.appearance().pageIndicatorTintColor = UIColor.lightGray
        }
    var body: some View {
        VStack {
            // TabView를 사용한 가로 스크롤
            TabView(selection: $currentTab) {
                ForEach(pages.indices, id: \.self) { index in
                    OnboardingPageView(page: pages[index])
                        .tag(index)
                }
            }
            // 페이징 스타일 (좌우 스와이프 + 하단 PageControl 점 표시)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            
            // 하단 "다음으로" 버튼
            Button(action: {
                    print("온보딩 완료!")
                
            }) {
                Text("시작하기")
                    .foregroundColor(.white)
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .background(Color.black)  // 원하는 색으로 교체 (예: Color.brown)
                    .cornerRadius(10)
                    .padding(.horizontal, 24)
            }
            .padding(.vertical, 16)
        }
        .background(Color.white.ignoresSafeArea())
    }
}

// 미리보기
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
