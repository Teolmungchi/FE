//
//  AuthModels.swift
//  general_project
//
//  Created by 이상엽 on 3/11/25.
//

import Foundation

struct User: Codable, Identifiable {
    let userId: String
    let password: String
    let name: String
    var id: String { userId }
}

// 회원가입 응답 모델
struct SignUpResponse: Codable {
    let httpStatus: Int?      // 성공 시 status code (예: 201)
    let success: Bool         // 성공 여부
    let data: User?           // 성공 시 서버가 유저 정보를 보내준다면 여기에 담기 (없으면 null)
    let message: String?    // 실패 시 에러 메시지 리스트
    let error: String?        // 실패 시 에러 타입 (예: "Bad Request")
    let statusCode: Int?      // 실패 시 status code (예: 400)
}

struct Token: Codable {
    let accessToken: String
    let refreshToken: String
}

struct SignInResponse: Codable {
    let success: Bool
    let data: Token?
    let error: String?
    let statusCode: Int?
    let message: String?
}

struct SignInRequest: Codable {
    let userId: String
    let password: String
}
