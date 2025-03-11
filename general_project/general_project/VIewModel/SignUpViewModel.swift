//
//  SignUpViewModel.swift
//  general_project
//
//  Created by 이상엽 on 3/11/25.
//

import Foundation
import SwiftUI

class SignUpViewModel: ObservableObject {
    @Published var currentStep: SignUpStep = .enterID
    @Published var userId: String = ""
    @Published var password: String = ""
    @Published var nickname: String = ""
    @Published var showCompletionModal: Bool = false
    @Published var errorMessage: String? = nil

    private let authService = AuthService()
    
    enum SignUpStep {
        case enterID
        case enterPassword
        case enterNickname
    }
    
    func goToNextStep() {
        switch currentStep {
        case .enterID:
            currentStep = .enterPassword
        case .enterPassword:
            currentStep = .enterNickname
        case .enterNickname:
            completeSignUp()
        }
    }
    
    func goToPreviousStep() {
        switch currentStep {
        case .enterID:
            break
        case .enterPassword:
            currentStep = .enterID
        case .enterNickname:
            currentStep = .enterPassword
        }
    }
    
    func completeSignUp() {
        self.errorMessage = nil

        authService.completeSignUp(userId: userId, password: password, nickname: nickname) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success {
                        print("회원가입 성공!")
                        self.showCompletionModal = true

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
