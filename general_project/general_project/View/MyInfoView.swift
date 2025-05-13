//
//  MyInfoView.swift
//  general_project
//
//  Created by 이상엽 on 4/15/25.
//

import SwiftUI

// String Alert를 위한 Identifiable 래퍼
struct IdentifiableString: Identifiable {
    let id = UUID()
    let value: String
}

struct MyInfoView: View {
    @StateObject private var viewModel: UserViewModel
    @State private var isEditingNickname = false
    @State private var newNickname = ""
    @State private var isChangingPassword = false
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var alertMessage: IdentifiableString?
    
    private var user: UserInfo? {
        return viewModel.userInfo
    }
    
    // 기본 생성자
    init() {
        _viewModel = StateObject(wrappedValue: UserViewModel())
    }
    
    // 프리뷰용 생성자
    init(previewViewModel: UserViewModel) {
        _viewModel = StateObject(wrappedValue: previewViewModel)
    }
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("로딩 중...")
            } else if user != nil {
                VStack(alignment: .leading, spacing: 15) {
                    Text("내 정보")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom, 80)
                    Text("계정 정보")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding(.bottom, 3)
                    
                    // 닉네임
                    HStack {
                        Text("닉네임")
                            .font(.title3)
                        Spacer()
                        if !isEditingNickname {
                            Button("변경") {
                                newNickname = user?.name ?? ""
                                isEditingNickname = true
                            }
                            .font(.caption)
                        }
                    }
                    
                    if isEditingNickname {
                        HStack {
                            TextField("새 닉네임", text: $newNickname)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Button("저장") {
                                if newNickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    alertMessage = IdentifiableString(value: "닉네임을 입력하세요.")
                                } else {
                                    viewModel.updateNickname(newNickname) { success, message in
                                        alertMessage = IdentifiableString(value: message)
                                        if success {
                                            isEditingNickname = false
                                        }
                                    }
                                }
                            }
                            Button("취소") {
                                isEditingNickname = false
                            }
                        }
                    } else {
                        Text(user?.name ?? "???")
                            .foregroundStyle(.gray)
                            .padding(.bottom, 7)
                    }
                    
                    // 이메일
                    Text("이메일")
                        .font(.title3)
                    Text("\(user?.login_id ?? "???")")
                        .foregroundStyle(.gray)
                        .padding(.bottom, 30)
                    
                    Divider()
                        .padding(.bottom, 10)
                    
                    if isChangingPassword {
                        VStack(alignment: .leading, spacing: 8) {
                            SecureField("현재 비밀번호", text: $currentPassword)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            SecureField("새 비밀번호", text: $newPassword)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            HStack {
                                Button("저장") {
                                    if currentPassword.isEmpty || newPassword.isEmpty {
                                        alertMessage = IdentifiableString(value: "비밀번호를 모두 입력하세요.")
                                    } else {
                                        viewModel.changePassword(currentPassword: currentPassword, newPassword: newPassword) { success, message in
                                            alertMessage = IdentifiableString(value: message)
                                            if success {
                                                isChangingPassword = false
                                                currentPassword = ""
                                                newPassword = ""
                                            }
                                        }
                                    }
                                }
                                .padding(.trailing, 8)
                                Button("취소") {
                                    isChangingPassword = false
                                    currentPassword = ""
                                    newPassword = ""
                                }
                            }
                        }
                        .padding(.bottom, 20)
                    } else {
                        HStack{
                            Spacer()
                            
                            Button("비밀번호 변경") {
                                isChangingPassword = true
                            }
                            .padding()
                            .frame(width: 152, height: 46)
                            .foregroundStyle(.white)
                            .background(.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 99))
                            .padding(.bottom, 20)
                            
                            Spacer()
                        }
                    }
                    
                    Spacer()
                    
                    // 로그아웃 버튼
                    Button(action: {
                        viewModel.logout()
                    }) {
                        Text("로그아웃")
                            .padding()
                            .frame(width: 152, height: 46)
                            .foregroundStyle(.white)
                            .background(.red)
                            .clipShape(RoundedRectangle(cornerRadius: 99))
                    }
                    .padding(.bottom, 70)
                    .frame(maxWidth: .infinity)

                }
            }
        }
        .padding(.horizontal, 37)
        .onAppear {
            viewModel.loadUserInfo()
        }
        .alert(item: $alertMessage) { msg in
            Alert(title: Text("알림"), message: Text(msg.value), dismissButton: .default(Text("확인")))
        }
    }
}
