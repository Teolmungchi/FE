//
//  UnderlinedTextField.swift
//  general_project
//
//  Created by 이상엽 on 2/23/25.
//

import SwiftUI

// UnderlinedTextField: 라벨 + 텍스트필드 + 아래 라인
struct UnderlinedTextField: View {
    let label: String
    @Binding var text: String
    var isSecure: Bool = false
    var placeholder: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            // 라벨(또는 플레이스홀더처럼 보이게)
            Text(label)
                .foregroundColor(.black)
                .font(.system(size: 14))
            
            // 일반 텍스트필드 or SecureField with placeholder
            if isSecure {
                SecureField(placeholder, text: $text)
                    .frame(height: 25)
                    .autocapitalization(.none)

            } else {
                TextField(placeholder, text: $text)
                    .frame(height: 25)
                    .autocapitalization(.none)

            }
            
            // 아래 라인
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.black)
        }
    }
}
