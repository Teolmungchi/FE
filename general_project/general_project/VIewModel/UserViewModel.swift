//
//  UserViewModel.swift
//  general_project
//
//  Created by 이상엽 on 4/15/25.
//

import SwiftUI

final class UserViewModel: ObservableObject {
    
    @Published var userInfo: UserInfo? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    // 닉네임 변경용
    @Published var newName: String = ""
    @Published var nameUpdateMessage: String? = nil
    
    // 비밀번호 변경용
    @Published var currentPassword: String = ""
    @Published var newPassword: String = ""
    @Published var passwordUpdateMessage: String? = nil
    
    private let userService = UserService()
    private let authService = AuthService()
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = true
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = true
    
    func loadUserInfo() {
        self.isLoading = true
        self.errorMessage = nil
        
        userService.fetchUserInfo { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let userInfo):
                    self?.userInfo = userInfo
                    //                    print("✅ 유저 정보 조회 성공: \(userInfo)")
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("❌ 유저 정보 조회 실패: \(error)")
                }
            }
        }
    }
    func logout() {
        authService.logout { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.isLoggedIn = false
                    self?.hasCompletedOnboarding = false
                case .failure(let error):
                    print("❌ 로그아웃 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    func updateNickname(_ newName: String, completion: @escaping (Bool, String) -> Void) {
        isLoading = true
        userService.updateNickname(newName: newName) { result in
            self.isLoading = false
            switch result {
            case .success(let data):
                self.userInfo?.name = data.name
                completion(true, "닉네임이 변경되었습니다.")
            case .failure(let error):
                let message: String
                if let apiError = error as? UserAPIError {
                    message = apiError.localizedDescription
                } else {
                    message = error.localizedDescription
                }
                completion(false, "닉네임 변경 실패: \(message)")
            }
        }
    }

    func changePassword(currentPassword: String, newPassword: String, completion: @escaping (Bool, String) -> Void) {
        isLoading = true
        userService.changePassword(currentPassword: currentPassword, newPassword: newPassword) { result in
            self.isLoading = false
            switch result {
            case .success:
                completion(true, "비밀번호가 변경되었습니다.")
            case .failure(let error):
                let message: String
                if let apiError = error as? UserAPIError {
                    message = apiError.localizedDescription
                } else {
                    message = error.localizedDescription
                }
                completion(false, "비밀번호 변경 실패: \(message)")
            }
        }
    }
}

