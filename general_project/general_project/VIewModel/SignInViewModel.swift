//
//  SignInViewModel.swift
//  general_project
//
//  Created by 이상엽 on 3/11/25.
//

import Foundation

class SignInViewModel: ObservableObject {
    
    @Published var userId: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String? = nil
    @Published var loginSucceeded: Bool = false

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

                        // 성공 후 추가 로직 (예: 화면 전환)
                    } else {
                        let message = response.message ?? "알 수 없는 에러"
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
