//
//  RootView.swift
//  general_project
//
//  Created by 이상엽 on 2/23/25.
//

import SwiftUI

struct RootView: View {
    @State private var showMainView = false
    
    var body: some View {
        ZStack {
            if showMainView {
                // 메인 콘텐츠나 이후의 뷰들을 여기에 작성합니다.
                SignInView()
            } else {
                SplashView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation {
                                showMainView = true
                            }
                        }
                    }
            }
        }
    }
}
