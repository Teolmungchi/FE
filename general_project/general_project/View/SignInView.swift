//
//  ContentView.swift
//  general_project
//
//  Created by 이상엽 on 2/23/25.
//

import SwiftUI

struct SignInView: View {
    @StateObject private var viewModel = SignInViewModel()

    
    
    var body: some View {
        NavigationView {
            
            VStack {
                Spacer()
                
                Image("loginlogo")
                //                .resizable()
                //                .scaledToFit()
                //                .frame(width: 100, height: 100)
                
                
                Spacer().frame(height: 50)
                
                // 아이디 입력 필드
                UnderlinedTextField(label: "아이디", text: $viewModel.userId)
                    .padding(.horizontal, 40)
                
                // 비밀번호 입력 필드
                UnderlinedTextField(label: "비밀번호", text: $viewModel.password, isSecure: true)
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
                
                Spacer().frame(height: 40)
                
                Button(action: {
                    viewModel.completeSignIn()
                }) {
                    Text("로그인")
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.black)
                        .cornerRadius(50)
                }
                .padding(.horizontal, 40)
                
                NavigationLink(destination: SignUpView()) {
                    Text("회원가입")
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.black)
                        .cornerRadius(50)
                }
                .padding(.horizontal, 40)
                .padding(.top, 8)
                
                Spacer()
            }
            .background(Color.white.ignoresSafeArea()) // 전체 배경 흰색
        }
    }
}
#Preview{
    SignInView()
}
