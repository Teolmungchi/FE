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
}
