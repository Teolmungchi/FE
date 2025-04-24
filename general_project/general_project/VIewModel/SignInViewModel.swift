//
//  SignInViewModel.swift
//  general_project
//
//  Created by 이상엽 on 3/11/25.
//

import Foundation
import SwiftUI

class SignInViewModel: ObservableObject {
    
    @Published var userId: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String? = nil
    @Published var loginSucceeded: Bool = false
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @Published var loginFailed: Bool = false // 추가


    private let authService = AuthService()

    func completeSignIn() {
        self.errorMessage = nil
        authService.completeSignIn(userId: userId, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success {
                        print("로그인 성공!")
                        self.loginSucceeded = true
                        self.isLoggedIn = true
                        self.errorMessage = nil // 성공 시 메시지 숨김
                    } else {
                        let message = response.message?.joined(separator: "\n") ?? "알 수 없는 에러"
                        print("회원가입 실패: \(message)")
                        self.errorMessage = message

                    }
                case .failure(let error):
                    print("에러 발생: \(error)")
                    self.errorMessage = error.localizedDescription

                }
            }
        }
    }
}
