//
//  RegisterModalView.swift
//  general_project
//
//  Created by 이상엽 on 5/7/25.
//

import SwiftUI

struct RegisterModalView: View {
    var onDismiss: () -> Void
    var onRegister: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("실종 동물을 등록하시겠습니까?")
                .font(.body)
                .padding(.top, 24)

            HStack(spacing: 20) {
                Button("취소") {
                    onDismiss()
                }
                .foregroundColor(.red)

                Button("등록") {
                    onRegister()
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
