//
//  ReportModalView.swift
//  general_project
//
//  Created by 이상엽 on 5/16/25.
//

import SwiftUI

struct ReportModalView: View {
    let onDismiss: () -> Void
    let onRegister: () -> Void
    @AppStorage("selectedTab") private var selectedTab: Int = 0   // 홈 탭 인덱스

    var body: some View {
        VStack(spacing: 20) {
            Text("실종 동물을 신고하시겠습니까?")
                .font(.body)
                .padding(.top, 24)

            HStack(spacing: 20) {
                Button("취소") {
                    onDismiss()
                }
                .foregroundColor(.red)

                Button("신고") {
                    onRegister()
                    onDismiss()
                    selectedTab = 0
                }
                
                .foregroundColor(.black)
            }
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(16)
        .padding(.horizontal, 40)
    }
}
