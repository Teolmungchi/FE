//
//  AuthService.swift
//  general_project
//
//  Created by 이상엽 on 3/10/25.
//

import Foundation

class AuthService {
    private let apiService = APIService()
    
    func completeSignUp(userId: String, password: String, nickname: String, completion: @escaping (Result<SignUpResponse, APIError>) -> Void) {
        let newUser = User(userId: userId, password: password, name: nickname)
        apiService.createUser(user: newUser, completion: completion)
    }
    
    func completeSignIn(userId: String, password: String, completion: @escaping (Result<SignInResponse, APIError>) -> Void) {
        let login = SignInRequest(userId: userId, password: password)
        apiService.Signin(userInfo: login, completion: completion)
    }
    
    func logout(completion: @escaping (Result<Void, APIError>) -> Void) {
            apiService.logout { result in
                switch result {
                case .success:
                    // ✅ 토큰 정리 등 부가 로직
                    KeychainHelper.shared.delete(service: "com.syproj.general-project", account: "accessToken")
                    KeychainHelper.shared.delete(service: "com.syproj.general-project", account: "refreshToken")
                    completion(.success(()))
                case .failure(let error):
                    // ✅ 필요한 경우 error 매핑
                    completion(.failure(.customError("Logout failed: \(error)")))
                }
            }
        }
}
