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
        errorMessage = nil
        switch currentStep {
        case .enterID:
                if !isValidEmail(userId) {
                    errorMessage = "이메일 형식으로 입력해주세요."
                    return
                }
            currentStep = .enterPassword
        case .enterPassword:
            if !isValidPassword(password) {
                        errorMessage = "비밀번호는 소문자 1개 이상, 숫자 1개 이상, 특수문자(!, @, #, %, $) 1개 이상으로 구성된 4~20자리여야 합니다."
                        return
                    }
            currentStep = .enterNickname
        case .enterNickname:
            if !isValidNickname(nickname) {
                errorMessage = "닉네임은 2~20자여야 합니다."
                return
            }
            completeSignUp()
        }
    }
    
    func goToPreviousStep() {
        errorMessage = nil
        switch currentStep {
        case .enterID:
            break
        case .enterPassword:
            currentStep = .enterID
        case .enterNickname:
            currentStep = .enterPassword
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email) && email.count >= 4 && email.count <= 50
    }

    func isValidPassword(_ password: String) -> Bool {
        let pwRegEx = "^(?=.*[a-z])(?=.*[0-9])(?=.*[!@#%$])[A-Za-z0-9!@#%$]{4,20}$"
        let pwPred = NSPredicate(format: "SELF MATCHES %@", pwRegEx)
        return pwPred.evaluate(with: password)
    }

    func isValidNickname(_ nickname: String) -> Bool {
        return nickname.count >= 2 && nickname.count <= 20
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
