//
//  MyInfoView.swift
//  general_project
//
//  Created by 이상엽 on 4/15/25.
//

import SwiftUI

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
    
    init() {
        _viewModel = StateObject(wrappedValue: UserViewModel())
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if viewModel.isLoading {
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("정보를 불러오는 중...")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 100)
                } else if user != nil {
                    VStack(spacing: 10) {
                        // 헤더
                        headerSection
                        
                        // 메인 콘텐츠
                        VStack(spacing: 24) {
                            accountInfoSection
                            passwordSection
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                        
                        Spacer(minLength: 40)
                        
                        // 로그아웃 버튼
                        logoutButton
                    }
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            viewModel.loadUserInfo()
        }
        .alert(item: $alertMessage) { msg in
            Alert(title: Text("알림"), message: Text(msg.value), dismissButton: .default(Text("확인")))
        }
    }
    
    // MARK: - 헤더 섹션
    private var headerSection: some View {
        VStack(spacing: 16) {
            Text("내 정보")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            // 프로필 아이콘
            Image(systemName: "person.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
        }
        .padding(.top, 20)
        .padding(.bottom, 30)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
    }
    
    // MARK: - 계정 정보 섹션
    private var accountInfoSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("계정 정보")
            
            VStack(spacing: 0) {
                // 닉네임 행
                VStack(spacing: 12) {
                    HStack {
                        Label("닉네임", systemImage: "person.fill")
                            .font(.body)
                            .fontWeight(.medium)
                        Spacer()
                        if !isEditingNickname {
                            Button("변경") {
                                newNickname = user?.name ?? ""
                                isEditingNickname = true
                            }
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .clipShape(Capsule())
                        }
                    }
                    
                    if isEditingNickname {
                        VStack(spacing: 12) {
                            TextField("새 닉네임을 입력하세요", text: $newNickname)
                                .textFieldStyle(.roundedBorder)
                                .font(.body)
                            
                            HStack(spacing: 12) {
                                Button("취소") {
                                    isEditingNickname = false
                                    newNickname = ""
                                }
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color(.systemGray5))
                                .clipShape(Capsule())
                                
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
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.blue)
                                .clipShape(Capsule())
                            }
                        }
                    } else {
                        HStack {
                            Text(user?.name ?? "없음")
                                .font(.body)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                    }
                }
                .padding(.vertical, 16)
                
                Divider()
                    .padding(.horizontal, -20)
                
                // 이메일 행
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label("이메일", systemImage: "envelope.fill")
                            .font(.body)
                            .fontWeight(.medium)
                        Spacer()
                    }
                    
                    HStack {
                        Text(user?.login_id ?? "없음")
                            .font(.body)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
                .padding(.vertical, 16)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - 비밀번호 섹션
    private var passwordSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("보안")
            
            VStack(spacing: 16) {
                if isChangingPassword {
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("현재 비밀번호")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            SecureField("현재 비밀번호를 입력하세요", text: $currentPassword)
                                .textFieldStyle(.roundedBorder)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("새 비밀번호")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            SecureField("새 비밀번호를 입력하세요", text: $newPassword)
                                .textFieldStyle(.roundedBorder)
                        }
                        
                        HStack(spacing: 12) {
                            Button("취소") {
                                isChangingPassword = false
                                currentPassword = ""
                                newPassword = ""
                            }
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(Color(.systemGray5))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            
                            Button("변경") {
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
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                } else {
                    Button(action: {
                        isChangingPassword = true
                    }) {
                        HStack {
                            Label("비밀번호 변경", systemImage: "lock.fill")
                                .font(.body)
                                .fontWeight(.medium)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.blue)
                        .padding(.vertical, 16)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - 로그아웃 버튼
    private var logoutButton: some View {
        Button(action: {
            viewModel.logout()
        }) {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.body)
                    .fontWeight(.medium)
                Text("로그아웃")
                    .font(.body)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(Color.red)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 30)
    }
    
    // MARK: - 섹션 헤더
    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }
}
