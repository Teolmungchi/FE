//
//  ContentView.swift
//  general_project
//
//  Created by 이상엽 on 2/23/25.
//

import SwiftUI

struct LoginView: View {
    @State private var userId: String = ""
    @State private var password: String = ""
    
    var body: some View {
        NavigationView {
            
            VStack {
                Spacer()
                
                Image("hairtuft")
                //                .resizable()
                //                .scaledToFit()
                //                .frame(width: 100, height: 100)
                
                
                Spacer().frame(height: 90)
                
                // 아이디 입력 필드
                UnderlinedTextField(label: "아이디", text: $userId)
                    .padding(.horizontal, 40)
                
                // 비밀번호 입력 필드
                UnderlinedTextField(label: "비밀번호", text: $password, isSecure: true)
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
                
                Spacer().frame(height: 40)
                
                Button(action: {
                    // 로그인 액션 구현
                }) {
                    Text("로그인하기")
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.brown)
                        .cornerRadius(50)
                }
                .padding(.horizontal, 40)
                HStack{
                    Spacer()

                    NavigationLink(destination: SignUpView()) {
                        Text("계정이 없으신가요?")
                            .font(.footnote)
                            .foregroundColor(Color.brown)
                    }
                    .padding(.top, 8)
                    .padding(.trailing, 58)
                }
                
                Spacer()
            }
            .background(Color.white.ignoresSafeArea()) // 전체 배경 흰색
        }
    }
}
#Preview{
    LoginView()
}


