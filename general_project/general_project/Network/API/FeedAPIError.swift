//
//  FeedAPIError.swift
//  general_project
//
//  Created by 이상엽 on 5/12/25.
//

import Foundation

enum FeedAPIError: Error {
    case invalidURL
    case requestFailed
    case decodingFailed
    case unauthorized
    case invalidResponse
    case custom(String)
    
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
            case .custom(_):
                return ""
            }
        }
}
