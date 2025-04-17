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
    }

