//
//  UserAPI.swift
//  general_project
//
//  Created by 이상엽 on 4/15/25.
//

import Foundation

enum UserAPI {
    static let baseURL = "https://tmc.kro.kr"
    
    static var userInfoURL: URL? {
        return URL(string: baseURL + "/api/v1/user")
    }
}

enum UserAPIError: Error {
    case invalidURL
    case requestFailed
    case decodingFailed
    case unauthorized
    case invalidResponse
    
    var localizedDescription: String {
            switch self {
            case .invalidURL:
                return "유효하지 않은 URL입니다."
            case .requestFailed:
                return "요청에 실패했습니다. 네트워크 상태를 확인해주세요."
            case .decodingFailed:
                return "서버 응답을 해석하는 데 실패했습니다."
            case .unauthorized:
                return "인증이 필요합니다. 다시 로그인해주세요."
            case .invalidResponse:
                return "서버 응답이 잘못되었습니다."
            }
        }
}
