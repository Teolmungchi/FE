//
//  MyInfoView.swift
//  general_project
//
//  Created by 이상엽 on 4/15/25.
//

import SwiftUI

struct MyInfoView: View {
    
    var body: some View {
        VStack{
            userInfoText
                .padding(.top, 72)
            Spacer()
            logoutButton
        }
        .padding(.horizontal, 37)
    }
    private var userInfoText: some View {
        Group {
            VStack(alignment: .leading, spacing: 15) {
                Text("내 정보")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 80)
                Text("계정 정보")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.bottom, 3)

                
                Text("닉네임")
                    .font(.title3)
                Text("셜로기")
                    .foregroundStyle(.gray)
                    .padding(.bottom, 7)

                Text("이메일")
                    .font(.title3)
                Text("aaa@navercom")
                    .foregroundStyle(.gray)
                    .padding(.bottom, 92)

                Divider()
            }
        }
    }
    private var logoutButton: some View {
        Button(action: {
            print("로그아웃 버튼!")
        }){ Text("로그아웃")
                .padding()
                .frame(width: 152, height: 46)
                .foregroundStyle(.white)
                .background(.red)
                .clipShape(RoundedRectangle(cornerRadius: 99))
        }
        .padding(.bottom, 70)
    }
}

#Preview {
    MyInfoView()
}
